import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../models/savings_goal.dart';
import '../widgets/money_text.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _days = TextEditingController(text: '40');
  DateTime _startDate = DateTime.now();
  String _mode = 'flexible';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final targetPaise = parseRupeesToPaise(_target.text)!;
    final days = int.parse(_days.text);
    setState(() => _saving = true);
    await AppDatabase.instance.createGoal(SavingsGoal(
      name: _name.text.trim(),
      targetPaise: targetPaise,
      durationDays: days,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      savingMode: _mode,
      createdAt: DateTime.now().toIso8601String(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final targetPaise = parseRupeesToPaise(_target.text) ?? 0;
    final days = int.tryParse(_days.text) ?? 0;
    final average = days > 0 && targetPaise > 0 ? targetPaise / days : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Create savings goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings_rounded, size: 38, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A goal worth saving for', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Give your money a purpose.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _label('Goal name'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. New phone fund', prefixIcon: Icon(Icons.flag_outlined)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a goal name' : null,
            ),
            const SizedBox(height: 18),
            _label('Target amount (₹)'),
            TextFormField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 1510', prefixIcon: Icon(Icons.currency_rupee)),
              onChanged: (_) => setState(() {}),
              validator: (v) => parseRupeesToPaise(v ?? '') == null ? 'Enter a valid amount greater than zero' : null,
            ),
            const SizedBox(height: 18),
            _label('Target duration (days)'),
            TextFormField(
              controller: _days,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 40', prefixIcon: Icon(Icons.calendar_month_outlined)),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 1 || n > 3650 ? 'Enter between 1 and 3650 days' : null;
              },
            ),
            const SizedBox(height: 18),
            _label('Start date'),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(DateFormat('EEE, d MMM yyyy').format(_startDate)),
            ),
            const SizedBox(height: 18),
            _label('Daily savings method'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'flexible', label: Text('Flexible'), icon: Icon(Icons.tune)),
                ButtonSegment(value: 'fixed', label: Text('Fixed plan'), icon: Icon(Icons.calculate_outlined)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == 'flexible'
                  ? 'Flexible: enter the actual amount you save each day.'
                  : 'Fixed plan: Save40 distributes the exact target across all days. You can still adjust the amount when recording a day.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 18),
            if (targetPaise > 0 && days > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your daily average', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(formatRupees(average.round(), decimals: true),
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                    Text('Across $days days · exact target distribution is calculated automatically',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create goal', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      );
}
