import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/fuel_repository.dart';
import '../../data/vehicle_repository.dart';
import '../../models/fuel_entry.dart';
import '../../models/vehicle.dart';

class AddFuelScreen extends StatefulWidget {
  final FuelEntry? entry;

  const AddFuelScreen({
    super.key,
    this.entry,
  });

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  final _vehicleRepository = VehicleRepository();
  final _fuelRepository = FuelRepository();

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;

  String _refillType = 'partial';
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  bool _saving = false;

  int? get _amountPaise {
    final value = double.tryParse(_amountController.text.trim());
    if (value == null || !value.isFinite || value <= 0) return null;
    final paise = (value * 100).round();
    return paise > 0 ? paise : null;
  }

  int? get _quantityMl {
    final value = double.tryParse(_quantityController.text.trim());
    if (value == null || !value.isFinite || value <= 0) return null;
    final ml = (value * 1000).round();
    return ml > 0 ? ml : null;
  }

  double? get _pricePerLitre {
    final amount = _amountPaise;
    final quantity = _quantityMl;

    if (amount == null || quantity == null) return null;

    return (amount / 100) / (quantity / 1000);
  }

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleRepository.getAllVehicles();

      if (!mounted) return;

      final existingEntry = widget.entry;

      Vehicle? selectedVehicle;

      if (existingEntry != null) {
        for (final vehicle in vehicles) {
          if (vehicle.id == existingEntry.vehicleId) {
            selectedVehicle = vehicle;
            break;
          }
        }
      }

      selectedVehicle ??= vehicles.isNotEmpty ? vehicles.first : null;

      if (existingEntry != null) {
        _amountController.text =
            (existingEntry.amountPaise / 100).toStringAsFixed(2);

        _quantityController.text =
            (existingEntry.quantityMl / 1000).toStringAsFixed(3);

        _notesController.text = existingEntry.notes ?? '';

        _refillType = existingEntry.refillType;

        _selectedDate =
            DateTime.tryParse(existingEntry.entryDate) ?? DateTime.now();
      }

      setState(() {
        _vehicles = vehicles;
        _selectedVehicle = selectedVehicle;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load vehicles: $error')),
      );
    }
  }

  void _selectAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveFuelEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = _selectedVehicle;
    final amount = _amountPaise;
    final quantity = _quantityMl;
    final existingEntry = widget.entry;

    if (vehicle == null ||
        vehicle.id == null ||
        amount == null ||
        quantity == null) {
      return;
    }

    setState(() => _saving = true);

    try {
      final entry = FuelEntry(
        id: existingEntry?.id,
        vehicleId: vehicle.id!,
        amountPaise: amount,
        quantityMl: quantity,
        fuelType: vehicle.fuelType,
        refillType: _refillType,
        entryDate: _formatDate(_selectedDate),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt:
            existingEntry?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (existingEntry == null) {
        await _fuelRepository.createFuelEntry(entry);
      } else {
        await _fuelRepository.updateFuelEntry(entry);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingEntry == null
                ? 'Fuel entry saved successfully!'
                : 'Fuel entry updated successfully!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save fuel entry: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _pricePerLitre;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Fuel' : 'Edit Fuel'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_car_outlined, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'No vehicles available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add a vehicle before recording a fuel refill.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionTitle('Vehicle'),
                      DropdownButtonFormField<Vehicle>(
                        initialValue: _selectedVehicle,
                        decoration: _decoration(
                          'Select vehicle',
                          Icons.directions_car,
                        ),
                        items: _vehicles.map((vehicle) {
                          return DropdownMenuItem(
                            value: vehicle,
                            child: Text(
                              vehicle.nickname?.trim().isNotEmpty == true
                                  ? vehicle.nickname!
                                  : vehicle.name,
                            ),
                          );
                        }).toList(),
                        onChanged: (vehicle) {
                          setState(() => _selectedVehicle = vehicle);
                        },
                        validator: (value) =>
                            value == null ? 'Select a vehicle' : null,
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Amount paid (₹)'),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [50, 100, 200, 500].map((amount) {
                          return OutlinedButton(
                            onPressed: () => _selectAmount(amount),
                            child: Text('₹$amount'),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: _decoration(
                          'Custom amount',
                          Icons.currency_rupee,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null ||
                              !amount.isFinite ||
                              amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          if ((amount * 100).round() <= 0) {
                            return 'Amount must be at least ₹0.01';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Fuel quantity'),

                      TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,3}'),
                          ),
                        ],
                        decoration: _decoration(
                          'Quantity in litres',
                          Icons.water_drop_outlined,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final quantity =
                              double.tryParse(value?.trim() ?? '');
                          if (quantity == null ||
                              !quantity.isFinite ||
                              quantity <= 0) {
                            return 'Enter a valid fuel quantity';
                          }
                          if ((quantity * 1000).round() <= 0) {
                            return 'Quantity must be at least 1 ml';
                          }
                          return null;
                        },
                      ),

                      if (price != null && price.isFinite)
                        Card(
                          margin: const EdgeInsets.only(top: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Calculated price per litre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                      _sectionTitle('Refill type'),

                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'partial',
                            label: Text('Partial'),
                            icon: Icon(Icons.local_gas_station),
                          ),
                          ButtonSegment(
                            value: 'full',
                            label: Text('Full Tank'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                        ],
                        selected: {_refillType},
                        onSelectionChanged: (selection) {
                          setState(() => _refillType = selection.first);
                        },
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Refill date'),

                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_formatDate(_selectedDate)),
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Notes (optional)'),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: _decoration(
                          'Add a note',
                          Icons.notes,
                        ),
                      ),

                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveFuelEntry,
                        icon: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _saving
                            ? (widget.entry == null ? 'Saving...' : 'Updating...')
                            : (widget.entry == null ? 'Save Fuel Entry' : 'Update Fuel Entry'),
                       ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

