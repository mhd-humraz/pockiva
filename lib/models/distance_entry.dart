
class DistanceEntry {
  final int? id;
  final int vehicleId;
  final int distanceM;
  final String journeyId;
  final DateTime recordedAt;
  final String? notes;
  final DateTime createdAt;

  DistanceEntry({
    this.id,
    required this.vehicleId,
    required this.distanceM,
    required this.journeyId,
    required this.recordedAt,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Validation returns null if ok, otherwise error message
  String? validate() {
    if (distanceM <= 0) return 'Distance must be positive';
    if (journeyId.isEmpty) return 'Journey ID cannot be empty';
    return null;
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'vehicle_id': vehicleId,
        'distance_m': distanceM,
        'journey_id': journeyId,
        'recorded_at': recordedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory DistanceEntry.fromMap(Map<String, dynamic> map) => DistanceEntry(
        id: map['id'] as int?,
        vehicleId: map['vehicle_id'] as int,
        distanceM: map['distance_m'] as int,
        journeyId: map['journey_id'] as String,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  DistanceEntry copyWith({
    int? id,
    int? vehicleId,
    int? distanceM,
    String? journeyId,
    DateTime? recordedAt,
    String? notes,
    DateTime? createdAt,
  }) =>
      DistanceEntry(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        distanceM: distanceM ?? this.distanceM,
        journeyId: journeyId ?? this.journeyId,
        recordedAt: recordedAt ?? this.recordedAt,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}

