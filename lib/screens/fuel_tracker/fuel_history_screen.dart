
import 'package:flutter/material.dart';

import '../../data/fuel_repository.dart';
import '../../data/vehicle_repository.dart';
import '../../models/fuel_entry.dart';
import '../../models/vehicle.dart';
import 'add_fuel_screen.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  final _fuelRepository = FuelRepository();
  final _vehicleRepository = VehicleRepository();

  List<FuelEntry> _entries = [];
  List<Vehicle> _vehicles = [];

  int? _selectedVehicleId;
  DateTimeRange? _dateRange;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final results = await Future.wait([
        _fuelRepository.getFuelEntries(),
        _vehicleRepository.getAllVehicles(),
      ]);

      if (!mounted) return;

      setState(() {
        _entries = results[0] as List<FuelEntry>;
        _vehicles = results[1] as List<Vehicle>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load fuel history: $error')),
      );
    }
  }

  List<FuelEntry> get _filteredEntries {
    return _entries.where((entry) {
      if (_selectedVehicleId != null &&
          entry.vehicleId != _selectedVehicleId) {
        return false;
      }

      if (_dateRange != null) {
        final date = DateTime.tryParse(entry.entryDate);
        if (date == null) return false;

        final start = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );

        final end = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
          23,
          59,
          59,
        );

        if (date.isBefore(start) || date.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Vehicle? _vehicleFor(int vehicleId) {
    for (final vehicle in _vehicles) {
      if (vehicle.id == vehicleId) return vehicle;
    }
    return null;
  }

  String _vehicleName(int vehicleId) {
    final vehicle = _vehicleFor(vehicleId);

    if (vehicle == null) return 'Unknown vehicle';

    final nickname = vehicle.nickname?.trim();

    return nickname != null && nickname.isNotEmpty
        ? nickname
        : vehicle.name;
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMoney(int paise) {
    return '₹${(paise / 100).toStringAsFixed(2)}';
  }

  String _pricePerLitre(FuelEntry entry) {
    if (entry.quantityMl <= 0) return '—';

    final price = entry.amountPaise / entry.quantityMl * 10;
    return '₹${price.toStringAsFixed(2)}/L';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null && mounted) {
      setState(() => _dateRange = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedVehicleId = null;
      _dateRange = null;
    });
  }
Future<void> _editFuelEntry(FuelEntry entry) async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddFuelScreen(entry: entry),
    ),
  );

  if (updated == true && mounted) {
    await _loadHistory();
  }
}

Future<void> _deleteFuelEntry(FuelEntry entry) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete fuel entry?'),
      content: const Text(
        'This fuel record will be permanently deleted. '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm != true || !mounted) return;

  try {
    await _fuelRepository.deleteFuelEntry(entry.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fuel entry deleted successfully')),
    );

    await _loadHistory();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not delete fuel entry: $error')),
    );
  }
}
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int?>(
          initialValue: _selectedVehicleId,
          decoration: const InputDecoration(
            labelText: 'Filter by vehicle',
            prefixIcon: Icon(Icons.directions_car),
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All vehicles'),
            ),
            ..._vehicles.map((vehicle) {
              return DropdownMenuItem<int?>(
                value: vehicle.id,
                child: Text(_vehicleName(vehicle.id!)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedVehicleId = value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _dateRange == null
                      ? 'Select date range'
                      : '${_formatDate(_dateRange!.start.toIso8601String())}'
                          ' - '
                          '${_formatDate(_dateRange!.end.toIso8601String())}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (_selectedVehicleId != null || _dateRange != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear filters',
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFuelCard(FuelEntry entry) {
    final litres = entry.quantityMl / 1000;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.local_gas_station,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _vehicleName(entry.vehicleId),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${entry.fuelType.toUpperCase()} • '
                        '${_formatDate(entry.entryDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatMoney(entry.amountPaise),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detail('Quantity', '${litres.toStringAsFixed(3)} L'),
                _detail('Price / litre', _pricePerLitre(entry)),
                _detail(
                  'Refill',
                  entry.refillType == 'full' ? 'Full tank' : 'Partial',
                ),
              ],
            ),
            if (entry.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                entry.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editFuelEntry(entry),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteFuelEntry(entry),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            ],
           
        ),
      ),
    );
    
  }

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel History'),
        actions: [
          IconButton(
            onPressed: _loadHistory,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFilters(),
                  const SizedBox(height: 20),
                  Text(
                    '${entries.length} fuel ${entries.length == 1 ? 'entry' : 'entries'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No fuel records found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your fuel entries will appear here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...entries.map(_buildFuelCard),
                ],
              ),
            ),
    );
  }
}
