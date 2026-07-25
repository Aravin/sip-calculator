import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sip_calculator/models/calculator_models.dart';
import 'package:sip_calculator/services/calculator_service.dart';
import 'package:sip_calculator/services/export_service.dart';
import 'package:sip_calculator/services/monte_carlo_service.dart';
import 'package:sip_calculator/services/persistence_service.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:sip_calculator/widgets/ad_banner.dart';
import 'package:sip_calculator/widgets/input_row.dart';
import 'package:sip_calculator/widgets/sensitivity_card.dart';
import 'package:sip_calculator/widgets/year_table.dart';
import 'package:fl_chart/fl_chart.dart';

final _service = CalculatorService();

class SIPScreen extends StatefulWidget {
  const SIPScreen({super.key});

  @override
  State<SIPScreen> createState() => _SIPScreenState();
}

class _SIPScreenState extends State<SIPScreen> {
  final _formKey = GlobalKey<FormState>();

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

  CalcResult _result = CalcResult(totalInvestment: 0, totalReturns: 0, totalValue: 0);
  CalcResult? _inflAdjusted;
  CalcResult? _sensitivity;
  List<AiInsight> _insights = [];
  double _goalSip = 0;
  bool _showMonteCarlo = false;
  MonteCarloResult? _monteCarloResult;
  String _nriCountry = 'India';
  NumberFormat _format = NumberFormat.simpleCurrency(locale: 'en_IN');
  static const _nriOptions = ['India', 'USA', 'UAE', 'UK', 'Canada', 'Singapore'];

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = _service.calculateSip(
        monthlyInvestment: _monthlyInvestment,
        rateOfReturn: _expectedReturn,
        years: _timePeriod.round(),
        stepUp: _stepUp,
      );
      if (_showInflationAdjusted) {
        _inflAdjusted = _service.calculateInflationAdjusted(
          corpus: _result.totalValue,
          years: _timePeriod.round(),
          inflationRate: _inflationRate,
        );
      }
      if (_showSensitivity) {
        _sensitivity = _service.calculateSensitivity(
          monthlyInvestment: _monthlyInvestment,
          rateOfReturn: _expectedReturn,
          years: _timePeriod.round(),
          stepUp: _stepUp,
        );
      }
      if (_showInsights) {
        _insights = _service.generateInsights(
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
    double target = double.tryParse(_goalCtrl.text) ?? 10000000;
    _goalSip = _service.findGoalSip(
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
      params: '₹${_monthlyInvestment.toInt()}/mo, ${_expectedReturn}%, ${_timePeriod.toInt()}y, ${_stepUp}% step-up',
      result: _result,
      savedAt: DateTime.now(),
    );
    PersistenceService.save(calc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation saved!'), duration: Duration(seconds: 2)),
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
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            InputRow(
              label: 'Monthly Investment',
              controller: _investmentCtrl,
              sliderValue: _monthlyInvestment,
              min: 500, max: 500000,
              divisions: 499,
              prefix: '₹ ',
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
              min: 1, max: 30,
              divisions: 29,
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
              min: 1, max: 30,
              divisions: 29,
              suffix: ' Year',
              maxLength: 2,
              onChanged: (v) {
                _timePeriod = v;
                _periodCtrl.text = v.toInt().toString();
                _recalculate();
              },
            ),
            const Divider(height: 32),
            // Step-Up SIP toggle and slider
            ExpansionTile(
              title: const Text('Step-Up SIP', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_stepUp > 0 ? '${_stepUp}% annual increase' : 'Not enabled'),
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
            const SizedBox(height: 8),
            // Quick Goal Presets
            ExpansionTile(
              title: const Text('Quick Goals', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                  spacing: 8, runSpacing: 4,
                  children: [
                    _goalChip('Retirement', 50000000),
                    _goalChip('Child Education', 25000000),
                    _goalChip('₹1 Crore', 10000000),
                    _goalChip('Home Down Payment', 5000000),
                    _goalChip('Vacation', 1000000),
                    _goalChip('Emergency Fund', 500000),
                  ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Goal Mode (Reverse SIP)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal Mode (Reverse SIP)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _goalCtrl,
                          decoration: const InputDecoration(
                            prefixText: '₹ ',
                            labelText: 'Target Corpus',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _calculateGoal,
                        child: const Text('Find SIP'),
                      ),
                    ],
                  ),
                  if (_goalSip > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Required SIP: ${_format.format(_goalSip)}/month',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Feature Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
              spacing: 8,
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
            ),
            // NRI Mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Currency: ', style: TextStyle(fontSize: 13)),
                  DropdownButton<String>(
                    value: _nriCountry,
                    items: _nriOptions.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${NriConfig.presets[c]!.currencySymbol} $c', style: const TextStyle(fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _nriCountry = v;
                          final cfg = NriConfig.presets[v]!;
                          _format = NumberFormat.simpleCurrency(locale: v == 'India' ? 'en_IN' : 'en_US', name: cfg.currencyCode);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Results
            _resultRow('Total Investment', _result.totalInvestment, Colors.purple.shade600),
            _resultRow('Total Returns', _result.totalReturns, Colors.green.shade600),
            _resultRow('Total Value', _result.totalValue, null),
            if (_result.totalValue > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'In words: ${ExportService.generateNumberToWords(_result.totalValue)}',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            if (_showInflationAdjusted) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Inflation Rate', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: _inflationRate,
                        min: 2, max: 12,
                        divisions: 20,
                        label: '${_inflationRate.toStringAsFixed(1)}%',
                        onChanged: (v) {
                          _inflationRate = v;
                          _recalculate();
                        },
                      ),
                    ),
                    Text('${_inflationRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              if (_inflAdjusted != null)
                _resultRow('Real Value (${_inflationRate.toStringAsFixed(1)}% inflation)', _inflAdjusted!.totalValue, Colors.red, subtitle: 'What your corpus is worth today'),
            ],
            // SIP Delay Cost
            _buildDelayCost(),
            // Insights
            if (_showInsights && _insights.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ..._insights.map((i) => Card(
                      child: ListTile(
                        leading: Text(i.emoji ?? '💡', style: const TextStyle(fontSize: 24)),
                        title: Text(i.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(i.description),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            // Sensitivity Analysis
            if (_showSensitivity && _sensitivity != null && _sensitivity!.yearlyBreakdown.length >= 3)
              SensitivityCard(
                worstCorpus: _sensitivity!.yearlyBreakdown[0].corpus,
                expectedCorpus: _sensitivity!.yearlyBreakdown[1].corpus,
                bestCorpus: _sensitivity!.yearlyBreakdown[2].corpus,
                format: _format,
              ),
            // Monte Carlo Simulation
            if (_showMonteCarlo && _monteCarloResult != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monte Carlo Simulation (1000 runs)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _mcRow('Best Case (P90)', _monteCarloResult!.p90Corpus, Colors.teal),
                    _mcRow('Median (P50)', _monteCarloResult!.medianCorpus, Colors.blue),
                    _mcRow('Worst Case (P10)', _monteCarloResult!.p10Corpus, Colors.red),
                    _mcRow('Success Probability', _monteCarloResult!.probabilityOfSuccess, Colors.green,
                        label2: '${(_monteCarloResult!.probabilityOfSuccess * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            // Yearly Table
            if (_showYearTable)
              YearTable(data: _result.yearlyBreakdown, format: _format),
            const SizedBox(height: 20),
            // Chart
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  titlesData: _titlesData,
                  borderData: FlBorderData(show: false),
                  barGroups: _barGroups,
                  gridData: const FlGridData(show: false),
                  barTouchData: _barTouchData,
                  alignment: BarChartAlignment.spaceAround,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // SIP → SWP Bridge
            if (_result.totalValue > 0)
              _buildSwpBridge(context),
            const AdBanner(),
            const SizedBox(height: 20),
          ],
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

  Widget _resultRow(String label, double value, Color? color, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            _format.format(value),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null)
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildDelayCost() {
    if (_timePeriod < 2) return const SizedBox.shrink();
    CalcResult delayCost = _service.calculateSipDelay(
      monthlyInvestment: _monthlyInvestment,
      rateOfReturn: _expectedReturn,
      actualYears: _timePeriod.round(),
      delayYears: 1,
      stepUp: _stepUp,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delaying 1 year costs you ${_format.format(delayCost.totalValue)}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
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
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            label2 ?? _format.format(value),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSwpBridge(BuildContext context) {
    double monthlySwp = _service.calculateSwpFromCorpus(
      corpus: _result.totalValue,
      rateOfReturn: _expectedReturn,
      years: _timePeriod.round(),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.teal.shade50,
        child: ListTile(
          leading: const Icon(Icons.arrow_forward, color: Colors.teal),
          title: const Text('SWP Income', style: TextStyle(fontSize: 14)),
          subtitle: Text(
            'This corpus can give you ${_format.format(monthlySwp)}/month for ${_timePeriod.toInt()} years',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SWPScreen()));
            },
            child: const Text('SWP →'),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> get _barGroups => [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: double.parse(_result.totalInvestment.toStringAsFixed(2)),
              color: Colors.purple.shade600, width: 12.5,
            )
          ], showingTooltipIndicators: [0]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: double.parse((_result.totalReturns).toStringAsFixed(2)),
              color: Colors.green.shade600, width: 12.5,
            )
          ], showingTooltipIndicators: [0]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: double.parse((_result.totalValue).toStringAsFixed(2)),
              color: Colors.grey.shade600, width: 12.5,
            )
          ], showingTooltipIndicators: [0]),
      ];

  FlTitlesData get _titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final style = TextStyle(color: kSecondaryDartColor, fontWeight: FontWeight.bold);
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
      );

  BarTouchData get _barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.yellow,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold),
            );
          },
        ),
      );
}
