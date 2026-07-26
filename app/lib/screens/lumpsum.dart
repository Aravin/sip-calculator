import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';

class LumpSumScreen extends StatefulWidget {
  const LumpSumScreen({super.key});

  @override
  State<LumpSumScreen> createState() => _LumpSumScreenState();
}

class _LumpSumScreenState extends State<LumpSumScreen> {
  double _investment = 100000;
  double _return = 12;
  double _years = 5;
  bool _showYearTable = false;
  bool _showPostTax = false;

  final _investmentCtrl = TextEditingController(text: '100000');
  final _returnCtrl = TextEditingController(text: '12');
  final _yearsCtrl = TextEditingController(text: '5');

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  CalcResult? _postTax;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateLumpsum(
        investment: _investment,
        rateOfReturn: _return,
        years: _years.round(),
      );
      if (_showPostTax) {
        _postTax = CalculatorService.instance.calculateLtcgTax(result: _result);
      }
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Lumpsum - ${curFormat.format(_investment)}',
      type: 'Lumpsum',
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
    ExportService.shareAsCsv(_result, 'Lumpsum Calculator');
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
        title: const Text('Lump-sum Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          InputRow(
            label: 'One Time Investment',
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
          buildResultRow('Future Value', _result.totalValue, null),
          buildResultRow('Total Returns', _result.totalReturns, Colors.green.shade600),
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
              label: const Text('LTCG Tax (12.5% after ₹1.25L)'),
              selected: _showPostTax,
              onSelected: (v) {
                _showPostTax = v;
                _recalculate();
              },
            ),
          ),
          if (_showPostTax && _postTax != null) ...[
            buildResultRow('Post-Tax Value', _postTax!.totalValue, Colors.orange),
            buildResultRow('Tax Paid', _result.totalReturns - _postTax!.totalReturns, Colors.red),
          ],
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
          const AdBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
