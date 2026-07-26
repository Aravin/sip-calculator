import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/year_table.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<SavedCalculation> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PersistenceService.loadAll();
    setState(() {
      _saved = data.reversed.toList();
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await PersistenceService.delete(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Plans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _saved.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No saved calculations yet',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save calculations from any calculator',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    const SizedBox(height: 8),
                    ..._saved.map((calc) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ExpansionTile(
                            title: Text(
                              calc.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              calc.params,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    calc.type,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 20, color: colorScheme.error),
                                  onPressed: () => _delete(calc.id),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _info('Investment',
                                        calc.result.totalInvestment),
                                    const Divider(height: 8),
                                    _info('Returns', calc.result.totalReturns),
                                    const Divider(height: 8),
                                    _info('Total', calc.result.totalValue),
                                    const SizedBox(height: 8),
                                    if (calc.result.yearlyBreakdown.isNotEmpty)
                                      YearTable(
                                        data: calc.result.yearlyBreakdown,
                                        format: curFormat,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _info(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            curFormat.format(value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
