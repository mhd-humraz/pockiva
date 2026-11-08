import 'package:flutter/material.dart';

import '../../data/vehicle_repository.dart';
import '../../models/vehicle.dart';

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({
    super.key,
    this.vehicle,
  });

  final Vehicle? vehicle;

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _notesController = TextEditingController();

  final _repository = VehicleRepository();

  String _category = 'motorcycle';
  String _fuelType = 'petrol';
  bool _saving = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();

    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _nameController.text = vehicle.name;
      _manufacturerController.text = vehicle.manufacturer ?? '';
      _modelController.text = vehicle.model ?? '';
      _nicknameController.text = vehicle.nickname ?? '';
      _notesController.text = vehicle.notes ?? '';
      _category = vehicle.category;
      _fuelType = vehicle.fuelType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _nicknameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final existing = widget.vehicle;

      final vehicle = Vehicle(
        id: existing?.id,
        name: _nameController.text.trim(),
        category: _category,
        manufacturer: _optionalValue(_manufacturerController.text),
        model: _optionalValue(_modelController.text),
        fuelType: _fuelType,
        nickname: _optionalValue(_nicknameController.text),
        notes: _optionalValue(_notesController.text),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _repository.updateVehicle(vehicle);
      } else {
        await _repository.createVehicle(vehicle);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save vehicle: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _decoration('Vehicle name *', Icons.directions_car),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a vehicle name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration('Vehicle category', Icons.category),
                items: const [
                  DropdownMenuItem(
                    value: 'motorcycle',
                    child: Text('Motorcycle'),
                  ),
                  DropdownMenuItem(value: 'car', child: Text('Car')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _fuelType,
                decoration: _decoration('Fuel type', Icons.local_gas_station),
                items: const [
                  DropdownMenuItem(value: 'petrol', child: Text('Petrol')),
                  DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'cng', child: Text('CNG')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _fuelType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufacturerController,
                decoration: _decoration('Manufacturer', Icons.factory_outlined),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: _decoration('Model', Icons.directions_car_outlined),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: _decoration('Nickname (optional)', Icons.label_outline),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: _decoration('Notes (optional)', Icons.notes),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _saveVehicle,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Update Vehicle' : 'Save Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
