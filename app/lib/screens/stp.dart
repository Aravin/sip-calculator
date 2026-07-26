import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/input_row.dart';

class STPScreen extends StatefulWidget {
  const STPScreen({super.key});

  @override
  State<STPScreen> createState() => _STPScreenState();
}

class _STPScreenState extends State<STPScreen> {
  double _investment = 50000;
  double _return = 12;
  double _years = 5;

  final _investmentCtrl = TextEditingController(text: '50000');
  final _returnCtrl = TextEditingController(text: '12');
  final _yearsCtrl = TextEditingController(text: '5');

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  double _monthlyTransfer = 0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateStp(
        totalInvestment: _investment,
        rateOfReturn: _return,
        years: _years.round(),
      );
      int months = _years.round() * 12;
      _monthlyTransfer = months > 0 ? _investment / months : 0;
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'STP - ${curFormat.format(_investment)}',
      type: 'STP',
      params: '₹${_investment.toInt()}, ${_return}%, ${_years.toInt()}y',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'STP Calculator');
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
        title: const Text('STP Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          InputRow(
            label: 'Total Investment',
            controller: _investmentCtrl,
            sliderValue: _investment,
            min: 10000, max: 10000000,
            prefix: '₹ ',
            maxLength: 8,
            onChanged: (v) {
              _investment = v;
              _investmentCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Expected Return',
            controller: _returnCtrl,
            sliderValue: _return,
            min: 1, max: 30,
            divisions: 29,
            suffix: ' %',
            maxLength: 2,
            onChanged: (v) {
              _return = v;
              _returnCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Time Period',
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
          buildResultRow('Total Investment', _result.totalInvestment, Colors.purple.shade600),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Monthly Transfer: ${curFormat.format(_monthlyTransfer)}/month', style: const TextStyle(fontSize: 13)),
          ),
          buildResultRow('Total Returns', _result.totalReturns, Colors.green.shade600),
          buildResultRow('Maturity Value', _result.totalValue, null),
          if (_result.totalValue > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          const AdBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
