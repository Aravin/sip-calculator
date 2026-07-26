import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';

class FDScreen extends StatefulWidget {
  const FDScreen({super.key});

  @override
  State<FDScreen> createState() => _FDScreenState();
}

class _FDScreenState extends State<FDScreen> {
  double _principal = 100000;
  double _return = 7.0;
  double _years = 3;
  String _compounding = 'quarterly';
  String _payout = 'cumulative';
  bool _showYearTable = false;

  late final _principalCtrl = TextEditingController(text: _principal.toInt().toString());
  late final _returnCtrl = TextEditingController(text: _return.toStringAsFixed(1));
  late final _yearsCtrl = TextEditingController(text: _years.toInt().toString());

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateFd(
        principal: _principal,
        rateOfReturn: _return,
        years: _years.round(),
        compounding: _compounding,
        payout: _payout,
      );
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'FD - ${curFormat.format(_principal)}',
      type: 'FD',
      params: '${curFormat.format(_principal)}, ${_return}%, ${_years.toInt()}y',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'FD Calculator');
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _returnCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FD Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InputRow(
            label: 'Deposit Amount',
            controller: _principalCtrl,
            sliderValue: _principal,
            min: 10000,
            max: 10000000,
            prefix: '\u20b9 ',
            maxLength: 8,
            onChanged: (v) {
              _principal = v;
              if (_principalCtrl.text != v.toInt().toString()) {
                _principalCtrl.text = v.toInt().toString();
              }
              _recalculate();
            },
          ),
          InputRow(
            label: 'Interest Rate',
            controller: _returnCtrl,
            sliderValue: _return,
            min: 1,
            max: 15,
            suffix: ' %',
            maxLength: 4,
            onChanged: (v) {
              _return = v;
              if (_returnCtrl.text != v.toStringAsFixed(1)) {
                _returnCtrl.text = v.toStringAsFixed(1);
              }
              _recalculate();
            },
          ),
          InputRow(
            label: 'Tenure',
            controller: _yearsCtrl,
            sliderValue: _years,
            min: 1,
            max: 30,
            suffix: ' Years',
            maxLength: 2,
            onChanged: (v) {
              _years = v;
              if (_yearsCtrl.text != v.toInt().toString()) {
                _yearsCtrl.text = v.toInt().toString();
              }
              _recalculate();
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compounding', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['monthly', 'quarterly', 'half_yearly', 'yearly'].map((c) {
                        final labels = {'monthly': 'Monthly', 'quarterly': 'Quarterly', 'half_yearly': 'Half-Yearly', 'yearly': 'Yearly'};
                        return ChoiceChip(
                          label: Text(labels[c]!, style: const TextStyle(fontSize: 12)),
                          selected: _compounding == c,
                          onSelected: (v) {
                            if (v) {
                              _compounding = c;
                              if (_payout == 'quarterly') _payout = 'cumulative';
                              _recalculate();
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text('Payout', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['cumulative', 'quarterly'].map((p) {
                        final labels = {'cumulative': 'Cumulative', 'quarterly': 'Quarterly Payout'};
                        return ChoiceChip(
                          label: Text(labels[p]!, style: const TextStyle(fontSize: 12)),
                          selected: _payout == p,
                          onSelected: (v) {
                            if (v) {
                              _payout = p;
                              if (p == 'quarterly') _compounding = 'quarterly';
                              _recalculate();
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildResultsCard(context),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilterChip(
              label: const Text('Year Table'),
              selected: _showYearTable,
              onSelected: (v) => setState(() => _showYearTable = v),
            ),
          ),
          if (_showYearTable) YearTable(data: _result.yearlyBreakdown, format: curFormat),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Results', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow(context, 'Principal Amount', _result.totalInvestment, colorScheme.tertiary),
            const Divider(height: 12),
            _resultRow(context, 'Total Interest', _result.totalReturns, colorScheme.primary),
            const Divider(height: 12),
            _resultRow(context, 'Maturity Amount', _result.totalValue, null),
            if (_result.totalValue > 0) ...[
              const SizedBox(height: 4),
              Text(
                'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultRow(BuildContext context, String label, double value, Color? color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          curFormat.format(value),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? colorScheme.onSurface),
        ),
      ],
    );
  }
}
