class SavingEntry {
  final int? id;
  final int goalId;
  final int dayNumber;
  final String entryDate;
  final int amountPaise;
  final String? note;

  const SavingEntry({
    this.id,
    required this.goalId,
    required this.dayNumber,
    required this.entryDate,
    required this.amountPaise,
    this.note,
  });

  factory SavingEntry.fromMap(Map<String, Object?> map) => SavingEntry(
        id: map['id'] as int,
        goalId: map['goal_id'] as int,
        dayNumber: map['day_number'] as int,
        entryDate: map['entry_date'] as String,
        amountPaise: map['amount_paise'] as int,
        note: map['note'] as String?,
      );

  Map<String, Object?> toMap() => {
        'goal_id': goalId,
        'day_number': dayNumber,
        'entry_date': entryDate,
        'amount_paise': amountPaise,
        'note': note,
      };
}
