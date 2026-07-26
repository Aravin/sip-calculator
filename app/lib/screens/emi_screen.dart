import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
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

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
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
      params: '₹${_principal.toInt()}, ${_rate}%, ${_years.toInt()}y',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
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
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          InputRow(
            label: 'Loan Amount',
            controller: _principalCtrl,
            sliderValue: _principal,
            min: 10000, max: 10000000,
            divisions: 999,
            prefix: '₹ ',
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
            min: 1, max: 24,
            divisions: 23,
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
            min: 1, max: 30,
            divisions: 29,
            suffix: ' Year',
            maxLength: 2,
            onChanged: (v) {
              _years = v;
              _yearsCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          const SizedBox(height: 16),
          buildResultRow('Monthly EMI', _monthlyEmi, Colors.red),
          buildResultRow('Total Interest', _result.totalReturns, Colors.orange),
          buildResultRow('Total Payment', _result.totalValue, null),
          if (_result.totalValue > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
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
          const SizedBox(height: 20),
          const AdBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
