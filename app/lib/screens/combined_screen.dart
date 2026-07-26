import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/sensitivity_card.dart';
import 'package:sip_calculator/widgets/year_table.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sip_calculator/shared/constants.dart';

class CombinedScreen extends StatefulWidget {
  const CombinedScreen({super.key});

  @override
  State<CombinedScreen> createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  double _lumpsum = 100000;
  double _monthlySip = 5000;
  double _return = 12;
  double _years = 5;
  double _stepUp = 0;
  bool _showYearTable = false;
  bool _showSensitivity = false;

  final _lumpsumCtrl = TextEditingController(text: '100000');
  final _sipCtrl = TextEditingController(text: '5000');
  final _returnCtrl = TextEditingController(text: '12');
  final _yearsCtrl = TextEditingController(text: '5');
  final _stepUpCtrl = TextEditingController(text: '0');

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  CalcResult? _sensitivity;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateCombined(
        lumpsumInvestment: _lumpsum,
        monthlySip: _monthlySip,
        rateOfReturn: _return,
        years: _years.round(),
        stepUp: _stepUp,
      );
      if (_showSensitivity) {
        _sensitivity = CalculatorService.instance.calculateSensitivity(
          monthlyInvestment: _monthlySip,
          rateOfReturn: _return,
          years: _years.round(),
          stepUp: _stepUp,
        );
      }
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Combined - ${curFormat.format(_lumpsum)} + ${curFormat.format(_monthlySip)}/mo',
      type: 'Combined',
      params: 'Lumpsum: ${curFormat.format(_lumpsum)}, SIP: ${curFormat.format(_monthlySip)}/mo',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'Combined SIP+Lumpsum');
  }

  @override
  void dispose() {
    _lumpsumCtrl.dispose();
    _sipCtrl.dispose();
    _returnCtrl.dispose();
    _yearsCtrl.dispose();
    _stepUpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP + Lumpsum'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          InputRow(
            label: 'Lumpsum Investment',
            controller: _lumpsumCtrl,
            sliderValue: _lumpsum,
            min: 10000, max: 10000000,
            divisions: 999,
            prefix: '₹ ',
            maxLength: 8,
            onChanged: (v) {
              _lumpsum = v;
              _lumpsumCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Monthly SIP',
            controller: _sipCtrl,
            sliderValue: _monthlySip,
            min: 500, max: 500000,
            divisions: 499,
            prefix: '₹ ',
            maxLength: 6,
            onChanged: (v) {
              _monthlySip = v;
              _sipCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Return Rate',
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
          ExpansionTile(
            title: const Text('Step-Up SIP', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_stepUp > 0 ? '${_stepUp}% annual' : 'Not enabled'),
            initiallyExpanded: _stepUp > 0,
            children: [
              InputRow(
                label: 'Annual Step-Up',
                controller: _stepUpCtrl,
                sliderValue: _stepUp,
                min: 0, max: 25,
                divisions: 25,
                suffix: ' %',
                maxLength: 2,
                onChanged: (v) {
                  _stepUp = v;
                  _stepUpCtrl.text = v.toInt().toString();
                  _recalculate();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildResultRow('Total Investment', _result.totalInvestment, Colors.purple.shade600),
          buildResultRow('Total Returns', _result.totalReturns, Colors.green.shade600),
          buildResultRow('Total Corpus', _result.totalValue, null),
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
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Year Table'),
                  selected: _showYearTable,
                  onSelected: (v) => setState(() => _showYearTable = v),
                ),
                FilterChip(
                  label: const Text('Sensitivity'),
                  selected: _showSensitivity,
                  onSelected: (v) {
                    _showSensitivity = v;
                    _recalculate();
                  },
                ),
              ],
            ),
          ),
          if (_showSensitivity && _sensitivity != null && _sensitivity!.yearlyBreakdown.length >= 3)
            SensitivityCard(
              worstCorpus: _sensitivity!.yearlyBreakdown[0].corpus,
              expectedCorpus: _sensitivity!.yearlyBreakdown[1].corpus,
              bestCorpus: _sensitivity!.yearlyBreakdown[2].corpus,
              format: curFormat,
            ),
          if (_showYearTable)
            YearTable(data: _result.yearlyBreakdown, format: curFormat),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: kSecondaryDarkColor, fontWeight: FontWeight.bold);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Investment'; break;
                          case 1: text = 'Returns'; break;
                          case 2: text = 'Total'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: double.parse(_result.totalInvestment.toStringAsFixed(2)), color: Colors.purple.shade600, width: 12.5)], showingTooltipIndicators: [0]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: double.parse(_result.totalReturns.toStringAsFixed(2)), color: Colors.green.shade600, width: 12.5)], showingTooltipIndicators: [0]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: double.parse(_result.totalValue.toStringAsFixed(2)), color: Colors.grey.shade600, width: 12.5)], showingTooltipIndicators: [0]),
                ],
                gridData: const FlGridData(show: false),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.yellow,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(rod.toY.round().toString(), const TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
          const AdBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
