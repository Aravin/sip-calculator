import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/year_table.dart';
import 'package:fl_chart/fl_chart.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  double _principal = 100000;
  double _return = 12.0;
  double _years = 5;
  String _frequency = 'monthly';
  bool _showYearTable = false;

  late final _principalCtrl = TextEditingController(text: _principal.toInt().toString());
  late final _returnCtrl = TextEditingController(text: _return.toInt().toString());
  late final _yearsCtrl = TextEditingController(text: _years.toInt().toString());

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateCompoundInterest(
        principal: _principal,
        rateOfReturn: _return,
        years: _years.round(),
        frequency: _frequency,
      );
    });
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Compound - ${curFormat.format(_principal)}',
      type: 'Compound',
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
    ExportService.shareAsCsv(_result, 'Compound Interest');
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Interest'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCsv, tooltip: 'Export CSV'),
          IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Save'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InputRow(
            label: 'Principal Amount',
            controller: _principalCtrl,
            sliderValue: _principal,
            min: 1000,
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
            label: 'Time Period',
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
                    Text('Compounding Frequency', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['daily', 'monthly', 'quarterly', 'half_yearly', 'yearly'].map((f) {
                        final labels = {
                          'daily': 'Daily',
                          'monthly': 'Monthly',
                          'quarterly': 'Quarterly',
                          'half_yearly': 'Half-Yearly',
                          'yearly': 'Yearly'
                        };
                        return ChoiceChip(
                          label: Text(labels[f]!, style: const TextStyle(fontSize: 12)),
                          selected: _frequency == f,
                          onSelected: (v) {
                            if (v) {
                              _frequency = f;
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
                          final style = TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 11);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Principal'; break;
                            case 1: text = 'Interest'; break;
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
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: _result.totalInvestment, color: colorScheme.tertiary, width: 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                    ], showingTooltipIndicators: [0]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: _result.totalReturns, color: colorScheme.primary, width: 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                    ], showingTooltipIndicators: [0]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: _result.totalValue, color: colorScheme.secondary, width: 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                    ], showingTooltipIndicators: [0]),
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
                          TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
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
                Icon(Icons.assessment_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Results', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            _resultRow(context, 'Principal Amount', _result.totalInvestment, colorScheme.tertiary),
            const Divider(height: 12),
            _resultRow(context, 'Compound Interest', _result.totalReturns, colorScheme.primary),
            const Divider(height: 12),
            _resultRow(context, 'Total Amount', _result.totalValue, null),
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
