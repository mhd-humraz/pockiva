
class GpsRide {
  final int? id;
  final int vehicleId;
  final int distanceM;
  final int durationS;
  final String journeyId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final DateTime createdAt;

  GpsRide({
    this.id,
    required this.vehicleId,
    required this.distanceM,
    required this.durationS,
    required this.journeyId,
    required this.startTime,
    required this.endTime,
    this.notes,
    DateTime? createdAt,
  })  : assert(endTime.isAfter(startTime), 'endTime must be after startTime'),
        createdAt = createdAt ?? DateTime.now();

  String? validate() {
    if (distanceM <= 0) return 'Distance must be positive';
    if (durationS <= 0) return 'Duration must be positive';
    if (journeyId.isEmpty) return 'Journey ID cannot be empty';
    return null;
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'vehicle_id': vehicleId,
        'distance_m': distanceM,
        'duration_s': durationS,
        'journey_id': journeyId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory GpsRide.fromMap(Map<String, dynamic> map) => GpsRide(
        id: map['id'] as int?,
        vehicleId: map['vehicle_id'] as int,
        distanceM: map['distance_m'] as int,
        durationS: map['duration_s'] as int,
        journeyId: map['journey_id'] as String,
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: DateTime.parse(map['end_time'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  GpsRide copyWith({
    int? id,
    int? vehicleId,
    int? distanceM,
    int? durationS,
    String? journeyId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    DateTime? createdAt,
  }) =>
      GpsRide(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        distanceM: distanceM ?? this.distanceM,
        durationS: durationS ?? this.durationS,
        journeyId: journeyId ?? this.journeyId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}

