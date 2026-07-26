import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';

class EMIScreen extends StatefulWidget {
  const EMIScreen({super.key});

  @override
  State<EMIScreen> createState() => _EMIScreenState();
}

class _EMIScreenState extends State<EMIScreen> {
  double _principal = 500000;
  double _rate = 9;
  double _years = 5;
  bool _showTable = false;

  final _principalCtrl = TextEditingController(text: '500000');
  final _rateCtrl = TextEditingController(text: '9');
  final _yearsCtrl = TextEditingController(text: '5');

  CalcResult _result =
      CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  double _monthlyEmi = 0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateEmi(
        principal: _principal,
        annualRate: _rate,
        years: _years.round(),
      );
      _monthlyEmi = _years > 0 ? _result.totalValue / (_years * 12) : 0;
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'EMI - ${curFormat.format(_principal)}',
      type: 'EMI',
      params: '\u20b9${_principal.toInt()}, ${_rate}%, ${_years.toInt()}y',
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
    ExportService.shareAsCsv(_result, 'EMI Calculator');
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Calculator'),
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
            label: 'Loan Amount',
            controller: _principalCtrl,
            sliderValue: _principal,
            min: 10000,
            max: 10000000,
            prefix: '\u20b9 ',
            maxLength: 8,
            onChanged: (v) {
              _principal = v;
              _principalCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Interest Rate',
            controller: _rateCtrl,
            sliderValue: _rate,
            min: 1,
            max: 24,
            suffix: ' %',
            maxLength: 2,
            onChanged: (v) {
              _rate = v;
              _rateCtrl.text = v.toInt().toString();
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
              label: const Text('Amortization Table'),
              selected: _showTable,
              onSelected: (v) => setState(() => _showTable = v),
            ),
          ),
          if (_showTable)
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
            _resultRow(context, 'Monthly EMI', _monthlyEmi, colorScheme.error),
            const Divider(height: 12),
            _resultRow(
                context, 'Total Interest', _result.totalReturns, Colors.orange),
            const Divider(height: 12),
            _resultRow(context, 'Total Payment', _result.totalValue, null),
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
