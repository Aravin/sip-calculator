import 'package:flutter/material.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/shared/result_helpers.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:fl_chart/fl_chart.dart';

class SipVsLumpsumScreen extends StatefulWidget {
  const SipVsLumpsumScreen({super.key});

  @override
  State<SipVsLumpsumScreen> createState() => _SipVsLumpsumScreenState();
}

class _SipVsLumpsumScreenState extends State<SipVsLumpsumScreen> {
  double _lumpsum = 500000;
  double _monthlySip = 10000;
  double _return = 12;
  double _years = 10;
  double _stepUp = 0;

  late final _lumpsumCtrl = TextEditingController(text: _lumpsum.toInt().toString());
  late final _sipCtrl = TextEditingController(text: _monthlySip.toInt().toString());
  late final _returnCtrl = TextEditingController(text: _return.toInt().toString());
  late final _yearsCtrl = TextEditingController(text: _years.toInt().toString());
  late final _stepUpCtrl = TextEditingController(text: _stepUp.toInt().toString());

  ComparisonResult? _comparison;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _comparison = CalculatorService.instance.compareSipVsLumpsum(
        monthlySip: _monthlySip,
        lumpsumInvestment: _lumpsum,
        rateOfReturn: _return,
        years: _years.round(),
        stepUp: _stepUp,
      );
    });
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
        title: const Text('SIP vs Lumpsum'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _recalculate, tooltip: 'Refresh'),
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
          const SizedBox(height: 4),
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
          if (_comparison != null) _buildComparisonCards(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComparisonCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = _comparison!;

    return Column(
      children: [
        _buildVsCard(context, c),
        const SizedBox(height: 12),
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
                          case 0: text = 'Lumpsum\nInvested'; break;
                          case 1: text = 'Lumpsum\nCorpus'; break;
                          case 2: text = 'SIP\nInvested'; break;
                          case 3: text = 'SIP\nCorpus'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style, textAlign: TextAlign.center));
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
                    BarChartRodData(toY: c.lumpsumInvestment, color: colorScheme.tertiary.withValues(alpha: 0.6), width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: c.lumpsumCorpus, color: colorScheme.tertiary, width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: c.sipTotalInvestment, color: colorScheme.primary.withValues(alpha: 0.6), width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: c.sipCorpus, color: colorScheme.primary, width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  ]),
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
      ],
    );
  }

  Widget _buildVsCard(BuildContext context, ComparisonResult c) {
    final colorScheme = Theme.of(context).colorScheme;
    final winner = c.sipWins ? 'SIP' : 'Lumpsum';
    final diff = c.difference;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Comparison', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            _resultRow(context, 'Lumpsum Investment', c.lumpsumInvestment, colorScheme.tertiary),
            _resultRow(context, 'Lumpsum Corpus', c.lumpsumCorpus, colorScheme.tertiary),
            const Divider(height: 16),
            _resultRow(context, 'SIP Total Investment', c.sipTotalInvestment, colorScheme.primary),
            _resultRow(context, 'SIP Corpus', c.sipCorpus, colorScheme.primary),
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (c.sipWins ? colorScheme.primary : colorScheme.tertiary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(c.sipWins ? Icons.trending_up : Icons.monetization_on,
                      size: 24, color: c.sipWins ? colorScheme.primary : colorScheme.tertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$winner wins by', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                        Text(curFormat.format(diff),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                color: c.sipWins ? colorScheme.primary : colorScheme.tertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(BuildContext context, String label, double value, Color? color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          Text(curFormat.format(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? colorScheme.onSurface)),
        ],
      ),
    );
  }
}
