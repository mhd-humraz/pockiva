import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../models/savings_goal.dart';
import '../widgets/money_text.dart';
import 'create_goal_screen.dart';
import 'goal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final Future<void> Function() onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavingsGoal> goals = [];
  Map<int, int> totals = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  
  Future<void> _load() async {
    final timer = Stopwatch()..start();

    try {
      final allGoals = await AppDatabase.instance.getGoals();
      debugPrint(
        'POCKIVA PERF: Goals: ${timer.elapsedMilliseconds} ms',
      );

      final map = await AppDatabase.instance.getAllGoalTotals();
      debugPrint(
        'POCKIVA PERF: Totals: ${timer.elapsedMilliseconds} ms',
      );

      if (!mounted) return;

      setState(() {
        goals = allGoals;
        totals = map;
        loading = false;
      });

      debugPrint(
        'POCKIVA PERF: Home loaded: ${timer.elapsedMilliseconds} ms',
      );
    } catch (e, stack) {
      debugPrint('POCKIVA PERF ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }


  Future<void> _createGoal() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = goals.fold<int>(0, (s, g) => s + g.targetPaise);
    final totalSaved = totals.values.fold<int>(0, (s, v) => s + v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pockiva', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGoal,
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _headerCard(totalSaved, totalTarget, goals.length),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Your savings goals',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      ),
                      Text('${goals.length} goals',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (goals.isEmpty) _emptyState() else ...goals.map(_goalCard),
                ],
              ),
      ),
    );
  }

  Widget _headerCard(int saved, int target, int count) {
    final progress = target == 0 ? 0.0 : (saved / target).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF137A52), Color(0xFF20B878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL SAVED', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(formatRupees(saved), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: Text('$count active ${count == 1 ? 'goal' : 'goals'}', style: const TextStyle(color: Colors.white))),
              Text('Target ${formatRupees(target)}', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(Icons.savings_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            const Text('Your first goal starts here', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Set your target, choose your deadline and let Pockiva guide your savings journey.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _createGoal, icon: const Icon(Icons.add), label: const Text('Create a goal')),
          ],
        ),
      );

  Widget _goalCard(SavingsGoal goal) {
    final saved = totals[goal.id] ?? 0;
    final progress = (saved / goal.targetPaise).clamp(0.0, 1.0).toDouble();
    final remaining = (goal.targetPaise - saved).clamp(0, goal.targetPaise).toInt();
    final date = DateTime.parse(goal.startDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
            );
            _load();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.flag_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(goal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatRupees(saved), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                    Text('of ${formatRupees(goal.targetPaise)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(value: progress, minHeight: 7),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('${(progress * 100).round()}% saved', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${goal.durationDays} days · ${DateFormat('d MMM').format(date)}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${formatRupees(remaining)} remaining · ${goal.savingMode == 'fixed' ? 'Fixed plan' : 'Flexible savings'}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
