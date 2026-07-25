import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/year_table.dart';

final _curFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

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
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Plans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _saved.isEmpty
              ? const Center(child: Text('No saved calculations yet'))
              : ListView(
                  children: [
                    ..._saved.map((calc) => Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ExpansionTile(
                            title: Text(calc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(calc.params, style: const TextStyle(fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(calc.type, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  onPressed: () => _delete(calc.id),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _info('Investment', calc.result.totalInvestment),
                                    _info('Returns', calc.result.totalReturns),
                                    _info('Total', calc.result.totalValue),
                                    const SizedBox(height: 8),
                                    if (calc.result.yearlyBreakdown.isNotEmpty)
                                      YearTable(data: calc.result.yearlyBreakdown, format: _curFormat),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const AdBanner(),
                    const SizedBox(height: 20),
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
          Text(_curFormat.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
