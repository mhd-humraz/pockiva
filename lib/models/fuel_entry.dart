class FuelEntry {
  final int? id;
  final int vehicleId;
  final int amountPaise;
  final int quantityMl;
  final String fuelType;
  final String refillType;
  final String entryDate;
  final String? notes;
  final String createdAt;

  const FuelEntry({
    this.id,
    required this.vehicleId,
    required this.amountPaise,
    required this.quantityMl,
    required this.fuelType,
    required this.refillType,
    required this.entryDate,
    this.notes,
    required this.createdAt,
  });

  String? validate() {
    if (vehicleId <= 0) return 'Select a valid vehicle';
    if (amountPaise <= 0) return 'Fuel amount must be greater than zero';
    if (quantityMl <= 0) return 'Fuel quantity must be greater than zero';

    if (!['petrol', 'diesel', 'cng'].contains(fuelType)) {
      return 'Invalid fuel type';
    }

    if (!['full', 'partial'].contains(refillType)) {
      return 'Invalid refill type';
    }

    if (entryDate.trim().isEmpty) return 'Entry date is required';

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'amount_paise': amountPaise,
      'quantity_ml': quantityMl,
      'fuel_type': fuelType,
      'refill_type': refillType,
      'entry_date': entryDate,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      amountPaise: map['amount_paise'] as int,
      quantityMl: map['quantity_ml'] as int,
      fuelType: map['fuel_type'] as String,
      refillType: map['refill_type'] as String,
      entryDate: map['entry_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
