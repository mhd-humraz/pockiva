class Vehicle {
  final int? id;
  final String name;
  final String category;
  final String? manufacturer;
  final String? model;
  final String fuelType;
  final String? nickname;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const Vehicle({
    this.id,
    required this.name,
    required this.category,
    this.manufacturer,
    this.model,
    required this.fuelType,
    this.nickname,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String? validate() {
    if (name.trim().isEmpty) return 'Vehicle name is required';
    if (!['motorcycle', 'car'].contains(category)) {
      return 'Invalid vehicle category';
    }
    if (!['petrol', 'diesel', 'cng'].contains(fuelType)) {
      return 'Invalid fuel type';
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name.trim(),
      'category': category,
      'manufacturer': manufacturer,
      'model': model,
      'fuel_type': fuelType,
      'nickname': nickname,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      manufacturer: map['manufacturer'] as String?,
      model: map['model'] as String?,
      fuelType: map['fuel_type'] as String,
      nickname: map['nickname'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Vehicle copyWith({
    int? id,
    String? name,
    String? category,
    String? manufacturer,
    String? model,
    String? fuelType,
    String? nickname,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      nickname: nickname ?? this.nickname,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
