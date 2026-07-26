import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalPlannerScreen extends StatefulWidget {
  const GoalPlannerScreen({super.key});

  @override
  State<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends State<GoalPlannerScreen> {
  List<FinancialGoal> _goals = [];
  static const _storageKey = 'financial_goals';

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    setState(() {
      _goals = data
          .map((s) {
            try {
              return FinancialGoal.fromJson(jsonDecode(s) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<FinancialGoal>()
          .toList();
    });
  }

  void _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _goals.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_storageKey, data);
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (ctx) => _GoalFormDialog(
        onSave: (goal) {
          setState(() {
            _goals.add(goal);
          });
          _saveGoals();
        },
      ),
    );
  }

  void _deleteGoal(String id) {
    setState(() {
      _goals.removeWhere((g) => g.id == id);
    });
    _saveGoals();
  }

  void _editGoal(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => _GoalFormDialog(
        existingGoal: goal,
        onSave: (updated) {
          setState(() {
            final index = _goals.indexWhere((g) => g.id == goal.id);
            if (index >= 0) _goals[index] = updated;
          });
          _saveGoals();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Planner'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addGoal, tooltip: 'Add Goal'),
        ],
      ),
      body: _goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No goals yet', style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Add your financial goals to track progress',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Goal'),
                    onPressed: _addGoal,
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ..._goals.map((goal) => _GoalCard(
                      goal: goal,
                      onDelete: () => _deleteGoal(goal.id),
                      onEdit: () => _editGoal(goal),
                    )),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Goal'),
                    onPressed: _addGoal,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _GoalCard({
    required this.goal,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (goal.progress * 100).toStringAsFixed(0);
    final months = goal.remainingMonths;
    final requiredMonthly = goal.requiredMonthlyForTarget;
    final isOnTrack = goal.projectedCorpus >= goal.targetAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnTrack ? Icons.check_circle : Icons.flag,
                  size: 20,
                  color: isOnTrack ? Colors.green : colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: isOnTrack ? Colors.green : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text('$pct% of target', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _info('Target', curFormat.format(goal.targetAmount), colorScheme)),
                const SizedBox(width: 8),
                Expanded(child: _info('Projected', curFormat.format(goal.projectedCorpus), colorScheme,
                    valueColor: isOnTrack ? Colors.green : colorScheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _info('Monthly', '${curFormat.format(goal.monthlyContribution)}/mo', colorScheme)),
                const SizedBox(width: 8),
                Expanded(child: _info('Timeline', '$months months', colorScheme)),
              ],
            ),
            if (!isOnTrack && requiredMonthly > 0) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Increase monthly to ${curFormat.format(requiredMonthly)} to reach target',
                      style: TextStyle(fontSize: 12, color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value, ColorScheme cs, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? cs.onSurface)),
      ],
    );
  }
}

class _GoalFormDialog extends StatefulWidget {
  final FinancialGoal? existingGoal;
  final Function(FinancialGoal) onSave;

  const _GoalFormDialog({this.existingGoal, required this.onSave});

  @override
  State<_GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<_GoalFormDialog> {
  late final _nameCtrl = TextEditingController(text: widget.existingGoal?.name ?? '');
  late final _targetCtrl = TextEditingController(text: widget.existingGoal?.targetAmount.toInt().toString() ?? '');
  late final _currentCtrl = TextEditingController(text: widget.existingGoal?.currentSavings.toInt().toString() ?? '0');
  late final _monthlyCtrl = TextEditingController(text: widget.existingGoal?.monthlyContribution.toInt().toString() ?? '0');
  late DateTime _targetDate = widget.existingGoal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.existingGoal != null ? 'Edit Goal' : 'Add Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name', hintText: 'e.g. Retirement, Vacation'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              decoration: const InputDecoration(labelText: 'Target Amount (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentCtrl,
              decoration: const InputDecoration(labelText: 'Current Savings (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyCtrl,
              decoration: const InputDecoration(labelText: 'Monthly Contribution (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
                );
                if (date != null) {
                  setState(() => _targetDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Target Date'),
                child: Text(
                  '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final target = double.tryParse(_targetCtrl.text) ?? 0;
            final current = double.tryParse(_currentCtrl.text) ?? 0;
            final monthly = double.tryParse(_monthlyCtrl.text) ?? 0;
            if (name.isEmpty || target <= 0) return;

            widget.onSave(FinancialGoal(
              id: widget.existingGoal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              targetAmount: target,
              targetDate: _targetDate,
              currentSavings: current,
              monthlyContribution: monthly,
            ));
            Navigator.pop(context);
          },
          child: Text(widget.existingGoal != null ? 'Update' : 'Add Goal'),
        ),
      ],
    );
  }
}
