import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/monte_carlo_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/sensitivity_card.dart';
import 'package:sip_calculator/widgets/year_table.dart';
import 'package:fl_chart/fl_chart.dart';

class SIPScreen extends StatefulWidget {
  const SIPScreen({super.key});

  @override
  State<SIPScreen> createState() => _SIPScreenState();
}

class _SIPScreenState extends State<SIPScreen> {
  double _monthlyInvestment = 5000;
  double _expectedReturn = 12;
  double _timePeriod = 2;
  double _stepUp = 0;
  double _inflationRate = 6.5;
  bool _showInflationAdjusted = false;
  bool _showYearTable = false;
  bool _showSensitivity = false;
  bool _showInsights = false;

  final _investmentCtrl = TextEditingController(text: '5000');
  final _returnCtrl = TextEditingController(text: '12');
  final _periodCtrl = TextEditingController(text: '2');
  final _stepUpCtrl = TextEditingController(text: '0');
  final _goalCtrl = TextEditingController(text: '10000000');

  CalcResult _result =
      CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  CalcResult? _inflAdjusted;
  CalcResult? _sensitivity;
  List<AiInsight> _insights = [];
  double _goalSip = 0;
  bool _showMonteCarlo = false;
  MonteCarloResult? _monteCarloResult;
  String _nriCountry = 'India';
  NumberFormat _format = NumberFormat.simpleCurrency(locale: 'en_IN');
  static const _nriOptions = [
    'India',
    'USA',
    'UAE',
    'UK',
    'Canada',
    'Singapore'
  ];

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = CalculatorService.instance.calculateSip(
        monthlyInvestment: _monthlyInvestment,
        rateOfReturn: _expectedReturn,
        years: _timePeriod.round(),
        stepUp: _stepUp,
      );
      if (_showInflationAdjusted) {
        _inflAdjusted = CalculatorService.instance.calculateInflationAdjusted(
          corpus: _result.totalValue,
          totalInvested: _result.totalInvestment,
          years: _timePeriod.round(),
          inflationRate: _inflationRate,
        );
      }
      if (_showSensitivity) {
        _sensitivity = CalculatorService.instance.calculateSensitivity(
          monthlyInvestment: _monthlyInvestment,
          rateOfReturn: _expectedReturn,
          years: _timePeriod.round(),
          stepUp: _stepUp,
        );
      }
      if (_showInsights) {
        _insights = CalculatorService.instance.generateInsights(
          monthlyInvestment: _monthlyInvestment,
          rateOfReturn: _expectedReturn,
          years: _timePeriod.round(),
          stepUp: _stepUp,
        );
      }
      if (_showMonteCarlo) {
        _monteCarloResult = MonteCarloService().simulate(
          monthlyInvestment: _monthlyInvestment,
          years: _timePeriod.round(),
          expectedReturn: _expectedReturn,
          stepUp: _stepUp,
        );
      }
    });
  }

  void _calculateGoal() {
    final double target = double.tryParse(_goalCtrl.text) ?? 10000000;
    _goalSip = CalculatorService.instance.findGoalSip(
      targetCorpus: target,
      rateOfReturn: _expectedReturn,
      years: _timePeriod.round(),
      stepUp: _stepUp,
    );
    setState(() {});
  }

  void _save() {
    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'SIP - ${_format.format(_monthlyInvestment)}/mo',
      type: 'SIP',
      params:
          '\u20b9${_monthlyInvestment.toInt()}/mo, ${_expectedReturn}%, ${_timePeriod.toInt()}y, ${_stepUp}% step-up',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareCsv() {
    ExportService.shareAsCsv(_result, 'SIP Calculator');
  }

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _returnCtrl.dispose();
    _periodCtrl.dispose();
    _stepUpCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCsv,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Save Calculation',
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          InputRow(
            label: 'Monthly Investment',
            controller: _investmentCtrl,
            sliderValue: _monthlyInvestment,
            min: 500,
            max: 500000,
            prefix: '\u20b9 ',
            maxLength: 7,
            onChanged: (v) {
              _monthlyInvestment = v;
              _investmentCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Expected Return',
            controller: _returnCtrl,
            sliderValue: _expectedReturn,
            min: 1,
            max: 30,
            suffix: ' %',
            maxLength: 2,
            onChanged: (v) {
              _expectedReturn = v;
              _returnCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          InputRow(
            label: 'Time Period',
            controller: _periodCtrl,
            sliderValue: _timePeriod,
            min: 1,
            max: 30,
            suffix: ' Years',
            maxLength: 2,
            onChanged: (v) {
              _timePeriod = v;
              _periodCtrl.text = v.toInt().toString();
              _recalculate();
            },
          ),
          const SizedBox(height: 8),
          _sectionCard(
            context,
            title: 'Advanced Options',
            icon: Icons.tune,
            child: Column(
              children: [
                ExpansionTile(
                  title:
                      const Text('Step-Up SIP', style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    _stepUp > 0 ? '${_stepUp}% annual increase' : 'Not enabled',
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
                        _stepUpCtrl.text = v.toInt().toString();
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                ExpansionTile(
                  title:
                      const Text('Quick Goals', style: TextStyle(fontSize: 13)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _goalChip('Retirement', 50000000),
                          _goalChip('Child Education', 25000000),
                          _goalChip('\u20b91 Crore', 10000000),
                          _goalChip('Home Down Payment', 5000000),
                          _goalChip('Vacation', 1000000),
                          _goalChip('Emergency Fund', 500000),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sectionCard(
            context,
            title: 'Goal Mode (Reverse SIP)',
            icon: Icons.track_changes,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _goalCtrl,
                          decoration: const InputDecoration(
                            prefixText: '\u20b9 ',
                            labelText: 'Target Corpus',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _calculateGoal,
                        child: const Text('Find SIP'),
                      ),
                    ],
                  ),
                  if (_goalSip > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primaryContainer),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Required SIP: ${_format.format(_goalSip)}/month',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildResultsSection(context),
          if (_timePeriod >= 2) ...[
            const SizedBox(height: 8),
            _buildDelayCost(),
          ],
          const SizedBox(height: 8),
          _buildToggles(context),
          if (_showInsights && _insights.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInsights(context),
          ],
          if (_showSensitivity &&
              _sensitivity != null &&
              _sensitivity!.yearlyBreakdown.length >= 3)
            SensitivityCard(
              worstCorpus: _sensitivity!.yearlyBreakdown[0].corpus,
              expectedCorpus: _sensitivity!.yearlyBreakdown[1].corpus,
              bestCorpus: _sensitivity!.yearlyBreakdown[2].corpus,
              format: _format,
            ),
          if (_showMonteCarlo && _monteCarloResult != null)
            _buildMonteCarlo(context),
          if (_showYearTable)
            YearTable(data: _result.yearlyBreakdown, format: _format),
          const SizedBox(height: 16),
          _buildChart(context),
          if (_result.totalValue > 0) ...[
            const SizedBox(height: 8),
            _buildSwpBridge(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required IconData icon, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
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
            const Divider(height: 16),
            _resultRow(context, 'Total Returns', _result.totalReturns,
                colorScheme.primary),
            const Divider(height: 16),
            _resultRow(context, 'Total Value', _result.totalValue, null),
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
            if (_showInflationAdjusted) ...[
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(
                      'Inflation Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_inflationRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Slider(
                value: _inflationRate,
                min: 2,
                max: 12,
                divisions: 20,
                label: '${_inflationRate.toStringAsFixed(1)}%',
                onChanged: (v) {
                  _inflationRate = v;
                  _recalculate();
                },
              ),
              if (_inflAdjusted != null)
                _resultRow(
                  context,
                  'Real Value (${_inflationRate.toStringAsFixed(1)}% inflation)',
                  _inflAdjusted!.totalValue,
                  colorScheme.error,
                  subtitle: 'What your corpus is worth today',
                ),
            ],
            const SizedBox(height: 4),
            // NRI Currency
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    'Currency:  ',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _nriCountry,
                    underline: const SizedBox(),
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _nriOptions
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                  '${NriConfig.presets[c]!.currencySymbol} $c'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _nriCountry = v;
                          final cfg = NriConfig.presets[v]!;
                          _format = NumberFormat.simpleCurrency(
                            locale: v == 'India' ? 'en_IN' : 'en_US',
                            name: cfg.currencyCode,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(
      BuildContext context, String label, double value, Color? color,
      {String? subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _format.format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildToggles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('Inflation'),
            selected: _showInflationAdjusted,
            onSelected: (v) {
              _showInflationAdjusted = v;
              _recalculate();
            },
          ),
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
          FilterChip(
            label: const Text('Insights'),
            selected: _showInsights,
            onSelected: (v) {
              _showInsights = v;
              _recalculate();
            },
          ),
          FilterChip(
            label: const Text('Monte Carlo'),
            selected: _showMonteCarlo,
            onSelected: (v) {
              _showMonteCarlo = v;
              _recalculate();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDelayCost() {
    final colorScheme = Theme.of(context).colorScheme;
    final CalcResult delayCost = CalculatorService.instance.calculateSipDelay(
      monthlyInvestment: _monthlyInvestment,
      rateOfReturn: _expectedReturn,
      actualYears: _timePeriod.round(),
      delayYears: 1,
      stepUp: _stepUp,
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.errorContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: colorScheme.error, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cost of Delay',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Delaying 1 year costs you ${_format.format(delayCost.totalValue)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onErrorContainer,
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

  Widget _buildInsights(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 8),
          ..._insights.map((i) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        i.emoji ?? '\ud83d\udca1',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    i.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    i.description,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonteCarlo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mc = _monteCarloResult!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Monte Carlo Simulation (1000 runs)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _mcRow('Best Case (P90)', mc.p90Corpus, colorScheme.tertiary),
            const Divider(height: 8),
            _mcRow('Median (P50)', mc.medianCorpus, colorScheme.primary),
            const Divider(height: 8),
            _mcRow('Worst Case (P10)', mc.p10Corpus, colorScheme.error),
            const Divider(height: 8),
            _mcRow(
              'Success Probability',
              mc.probabilityOfSuccess,
              colorScheme.primary,
              label2: '${(mc.probabilityOfSuccess * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _mcRow(String label, double value, Color color, {String? label2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label2 ?? _format.format(value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwpBridge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double monthlySwp = CalculatorService.instance.calculateSwpFromCorpus(
      corpus: _result.totalValue,
      rateOfReturn: _expectedReturn,
      years: _timePeriod.round(),
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.arrow_forward, color: colorScheme.primary),
        ),
        title: const Text('SWP Income', style: TextStyle(fontSize: 14)),
        subtitle: Text(
          'This corpus can give you ${_format.format(monthlySwp)}/month for ${_timePeriod.toInt()} years',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: FilledButton.tonal(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SWPScreen()),
            );
          },
          child: const Text('SWP \u2192'),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
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
                      child: Text(text, style: style),
                    );
                  },
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: double.parse(
                        _result.totalInvestment.toStringAsFixed(2)),
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
                    toY:
                        double.parse((_result.totalReturns).toStringAsFixed(2)),
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
                    toY: double.parse((_result.totalValue).toStringAsFixed(2)),
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
    );
  }

  Widget _goalChip(String label, double amount) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        _goalCtrl.text = amount.toInt().toString();
        _calculateGoal();
      },
    );
  }
}
