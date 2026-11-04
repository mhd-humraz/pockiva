import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../models/savings_goal.dart';
import '../models/saving_entry.dart';
import '../widgets/money_text.dart';

class GoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  List<SavingEntry> entries = [];
  bool loading = true;

  SavingsGoal get goal => widget.goal;
  Map<int, SavingEntry> get byDay => {for (final e in entries) e.dayNumber: e};
  int get saved => entries.fold<int>(0, (sum, e) => sum + e.amountPaise);
  int get completedDays => entries.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await AppDatabase.instance.getEntries(goal.id!);
    if (!mounted) return;
    setState(() {
      entries = result;
      loading = false;
    });
  }

  Future<void> _recordDay(int day) async {
    final existing = byDay[day];
    final suggested = existing?.amountPaise ??
        (goal.savingMode == 'fixed' ? goal.plannedPaiseForDay(day) : 0);
    final controller = TextEditingController(
      text: suggested > 0 ? (suggested / 100).toStringAsFixed(2) : '',
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Record day $day' : 'Edit day $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount saved (₹)', prefixIcon: Icon(Icons.currency_rupee)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes)),
            ),
            if (goal.savingMode == 'fixed')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Suggested fixed amount: ${formatRupees(goal.plannedPaiseForDay(day), decimals: true)}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          if (existing != null)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, -1),
              child: const Text('Uncheck day'),
            ),
          FilledButton(
            onPressed: () {
              final parsed = parseRupeesToPaise(controller.text);
              if (parsed == null) return;
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (amount == null) return;
    if (amount == -1) {
      await AppDatabase.instance.deleteEntry(goal.id!, day);
    } else {
      final date = DateTime.parse(goal.startDate).add(Duration(days: day - 1));
      await AppDatabase.instance.saveEntry(SavingEntry(
        goalId: goal.id!,
        dayNumber: day,
        entryDate: DateFormat('yyyy-MM-dd').format(date),
        amountPaise: amount,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      ));
    }
    await _load();
  }

  Future<void> _deleteGoal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this goal?'),
        content: const Text('This permanently deletes this goal and its savings history from this phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await AppDatabase.instance.deleteGoal(goal.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (goal.targetPaise - saved).clamp(0, goal.targetPaise).toInt();
    final progress = (saved / goal.targetPaise).clamp(0.0, 1.0).toDouble();
    final start = DateTime.parse(goal.startDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(onPressed: _deleteGoal, tooltip: 'Delete goal', icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SAVED SO FAR', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(.7), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      const SizedBox(height: 5),
                      Text(formatRupees(saved), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      const SizedBox(height: 13),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(value: progress, minHeight: 9),
                      ),
                      const SizedBox(height: 8),
                      Text('${(progress * 100).round()}% · ${formatRupees(remaining)} left',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 18,
                        runSpacing: 8,
                        children: [
                          _stat('TARGET', formatRupees(goal.targetPaise)),
                          _stat('DAYS DONE', '$completedDays/${goal.durationDays}'),
                          _stat('METHOD', goal.savingMode == 'fixed' ? 'Fixed' : 'Flexible'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(child: Text('Daily checklist', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
                    Text('Tap a day to record', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(goal.durationDays, (index) {
                  final day = index + 1;
                  final entry = byDay[day];
                  final date = start.add(Duration(days: index));
                  final planned = goal.plannedPaiseForDay(day);
                  final isDone = entry != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isDone
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(.65)
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _recordDay(day),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isDone,
                                onChanged: (_) => _recordDay(day),
                              ),
                              Container(
                                width: 37,
                                height: 37,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Text('$day', style: const TextStyle(fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Day $day', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(DateFormat('EEE, d MMM').format(date),
                                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(isDone ? formatRupees(entry.amountPaise, decimals: true) : 'Not saved',
                                      style: TextStyle(fontWeight: FontWeight.w800, color: isDone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant)),
                                  if (!isDone && goal.savingMode == 'fixed')
                                    Text('Plan ${formatRupees(planned, decimals: true)}',
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, letterSpacing: .8, color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(.7))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onPrimaryContainer)),
        ],
      );
}
