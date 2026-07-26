import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/sensitivity_card.dart';
import 'package:sip_calculator/widgets/year_table.dart';
import 'package:fl_chart/fl_chart.dart';

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

  late final _lumpsumCtrl = TextEditingController(text: _lumpsum.toInt().toString());
  late final _sipCtrl = TextEditingController(text: _monthlySip.toInt().toString());
  late final _returnCtrl = TextEditingController(text: _return.toInt().toString());
  late final _yearsCtrl = TextEditingController(text: _years.toInt().toString());
  late final _stepUpCtrl = TextEditingController(text: _stepUp.toInt().toString());

  CalcResult _result =
      CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
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
      params:
          'Lumpsum: ${curFormat.format(_lumpsum)}, SIP: ${curFormat.format(_monthlySip)}/mo',
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP + Lumpsum'),
        actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCsv,
              tooltip: 'Export CSV'),
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InputRow(
            label: 'Lumpsum Investment',
            controller: _lumpsumCtrl,
            sliderValue: _lumpsum,
            min: 10000,
            max: 10000000,
            prefix: '\u20b9 ',
            maxLength: 8,
            onChanged: (v) {
              _lumpsum = v;
              if (_lumpsumCtrl.text != v.toInt().toString()) {
                _lumpsumCtrl.text = v.toInt().toString();
              }
              _recalculate();
            },
          ),
          InputRow(
            label: 'Monthly SIP',
            controller: _sipCtrl,
            sliderValue: _monthlySip,
            min: 500,
            max: 500000,
            prefix: '\u20b9 ',
            maxLength: 6,
            onChanged: (v) {
              _monthlySip = v;
              if (_sipCtrl.text != v.toInt().toString()) {
                _sipCtrl.text = v.toInt().toString();
              }
              _recalculate();
            },
          ),
          InputRow(
            label: 'Return Rate',
            controller: _returnCtrl,
            sliderValue: _return,
            min: 1,
            max: 30,
            suffix: ' %',
            maxLength: 2,
            onChanged: (v) {
              _return = v;
              if (_returnCtrl.text != v.toInt().toString()) {
                _returnCtrl.text = v.toInt().toString();
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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpansionTile(
              title: const Text('Step-Up SIP', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                _stepUp > 0 ? '${_stepUp}% annual' : 'Not enabled',
                style: const TextStyle(fontSize: 11),
              ),
              initiallyExpanded: _stepUp > 0,
              children: [
                InputRow(
                  label: 'Annual Step-Up',
                  controller: _stepUpCtrl,
                  sliderValue: _stepUp,
                  min: 0,
                  max: 25,
                  suffix: ' %',
                  maxLength: 2,
                  onChanged: (v) {
                    _stepUp = v;
                    if (_stepUpCtrl.text != v.toInt().toString()) {
                      _stepUpCtrl.text = v.toInt().toString();
                    }
                    _recalculate();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildResultsCard(context),
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
                    setState(() {
                      _showSensitivity = v;
                    });
                    _recalculate();
                  },
                ),
              ],
            ),
          ),
          if (_showSensitivity && _sensitivity != null &&
              _sensitivity!.yearlyBreakdown.length >= 3)
            SensitivityCard(
              worstCorpus: _sensitivity!.yearlyBreakdown[0].corpus,
              expectedCorpus: _sensitivity!.yearlyBreakdown[1].corpus,
              bestCorpus: _sensitivity!.yearlyBreakdown[2].corpus,
              format: curFormat,
            ),
          if (_showYearTable)
            YearTable(data: _result.yearlyBreakdown, format: curFormat),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Investment';
                              break;
                            case 1:
                              text = 'Returns';
                              break;
                            case 2:
                              text = 'Total';
                              break;
                            default:
                              text = '';
                          }
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: _result.totalInvestment,
                          color: colorScheme.tertiary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: _result.totalReturns,
                          color: colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: _result.totalValue,
                          color: colorScheme.secondary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        )
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                  gridData: const FlGridData(show: false),
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.inverseSurface,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
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
            _resultRow(
                context, 'Total Returns', _result.totalReturns, colorScheme.primary),
            const Divider(height: 12),
            _resultRow(context, 'Total Corpus', _result.totalValue, null),
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
