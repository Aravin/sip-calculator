import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';

final _curFormat = NumberFormat.simpleCurrency(locale: 'en_IN');
final _service = CalculatorService();

class SWPScreen extends StatefulWidget {
  const SWPScreen({super.key});

  @override
  State<SWPScreen> createState() => _SWPScreenState();
}

class _SWPScreenState extends State<SWPScreen> {
  double _investment = 50000;
  double _withdraw = 1000;
  double _return = 12;
  double _years = 5;
  bool _showYearTable = false;

  final _investmentCtrl = TextEditingController(text: '50000');
  final _withdrawCtrl = TextEditingController(text: '1000');
  final _returnCtrl = TextEditingController(text: '12');
  final _yearsCtrl = TextEditingController(text: '5');

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  double _totalWithdrawn = 0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = _service.calculateSwp(
        totalInvestment: _investment,
        monthlyWithdraw: _withdraw,
        rateOfReturn: _return,
        years: _years.round(),
      );
      _totalWithdrawn = _result.totalReturns;
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'SWP - ${_curFormat.format(_investment)}',
      type: 'SWP',
      params: '₹${_investment.toInt()}, ${_withdraw.toInt()}/mo, ${_return}%',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'SWP Calculator');
  }

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _withdrawCtrl.dispose();
    _returnCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SWP Calculator'),
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
            label: 'Monthly Withdraw',
            controller: _withdrawCtrl,
            sliderValue: _withdraw,
            min: 500, max: 500000,
            prefix: '₹ ',
            maxLength: 6,
            onChanged: (v) {
              _withdraw = v;
              _withdrawCtrl.text = v.toInt().toString();
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
          _resultRow('Total Investment', _result.totalInvestment, Colors.purple.shade600),
          _resultRow('Total Withdrawn', _totalWithdrawn, Colors.green.shade600),
          _resultRow('Remaining Corpus', _result.totalValue, null),
          if (_result.totalValue > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          if (_result.totalValue <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.red.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Warning: Corpus depleted before tenure ends!', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ),
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
            YearTable(data: _result.yearlyBreakdown, format: _curFormat),
          const AdBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _resultRow(String label, double value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            _curFormat.format(value),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
