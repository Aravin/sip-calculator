import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';

class PPFScreen extends StatefulWidget {
  const PPFScreen({super.key});

  @override
  State<PPFScreen> createState() => _PPFScreenState();
}

class _PPFScreenState extends State<PPFScreen> {
  double _yearlyInvestment = 24000;
  double _return = 7.1;
  double _years = 15;
  bool _showYearTable = false;

  final _investmentCtrl = TextEditingController(text: '24000');
  final _returnCtrl = TextEditingController(text: '7.1');
  final _yearsCtrl = TextEditingController(text: '15');

  CalcResult _result =
      CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculatePpf(
        yearlyInvestment: _yearlyInvestment,
        rateOfReturn: _return,
        years: _years.round(),
      );
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'PPF - ${curFormat.format(_yearlyInvestment)}/yr',
      type: 'PPF',
      params:
          '\u20b9${_yearlyInvestment.toInt()}/yr, ${_return}%, ${_years.toInt()}y',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'PPF Calculator');
  }

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _returnCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPF Calculator'),
        actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCsv,
              tooltip: 'Export CSV'),
          IconButton(
              icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InputRow(
            label: 'Yearly Investment',
            controller: _investmentCtrl,
            sliderValue: _yearlyInvestment,
            min: 6000,
            max: 150000,
            prefix: '\u20b9 ',
            maxLength: 6,
            onChanged: (v) {
              _yearlyInvestment = v;
              _investmentCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'PPF Interest Rate',
            controller: _returnCtrl,
            sliderValue: _return,
            min: 6,
            max: 12,
            suffix: ' %',
            maxLength: 3,
            onChanged: (v) {
              _return = v;
              _returnCtrl.text = v.toStringAsFixed(1);
              _recalculate();
            },
          ),
          InputRow(
            label: 'Investment Duration',
            controller: _yearsCtrl,
            sliderValue: _years,
            min: 1,
            max: 30,
            suffix: ' Years',
            maxLength: 2,
            onChanged: (v) {
              _years = v;
              _yearsCtrl.text = v.toInt().toString();
              _recalculate();
            },
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
          if (_showYearTable)
            YearTable(data: _result.yearlyBreakdown, format: curFormat),
          const SizedBox(height: 16),
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
                Icon(Icons.assessment_outlined,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow(context, 'Total Investment', _result.totalInvestment,
                colorScheme.tertiary),
            const Divider(height: 12),
            _resultRow(context, 'Total Interest', _result.totalReturns,
                colorScheme.primary),
            const Divider(height: 12),
            _resultRow(context, 'Maturity Amount', _result.totalValue, null),
            if (_result.totalValue > 0) ...[
              const SizedBox(height: 4),
              Text(
                'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultRow(
      BuildContext context, String label, double value, Color? color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          curFormat.format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
