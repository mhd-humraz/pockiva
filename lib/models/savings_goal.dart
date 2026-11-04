class SavingsGoal {
  final int? id;
  final String name;
  final int targetPaise;
  final int durationDays;
  final String startDate;
  final String savingMode; // flexible or fixed
  final String createdAt;

  const SavingsGoal({
    this.id,
    required this.name,
    required this.targetPaise,
    required this.durationDays,
    required this.startDate,
    required this.savingMode,
    required this.createdAt,
  });

  factory SavingsGoal.fromMap(Map<String, Object?> map) => SavingsGoal(
        id: map['id'] as int,
        name: map['name'] as String,
        targetPaise: map['target_paise'] as int,
        durationDays: map['duration_days'] as int,
        startDate: map['start_date'] as String,
        savingMode: map['saving_mode'] as String,
        createdAt: map['created_at'] as String,
      );

  Map<String, Object?> toMap() => {
        'name': name,
        'target_paise': targetPaise,
        'duration_days': durationDays,
        'start_date': startDate,
        'saving_mode': savingMode,
        'created_at': createdAt,
      };

  int plannedPaiseForDay(int dayNumber) {
    final base = targetPaise ~/ durationDays;
    final remainder = targetPaise % durationDays;
    return base + (dayNumber <= remainder ? 1 : 0);
  }
}
