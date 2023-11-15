import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sip_calculator/shared/ads.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fl_chart/fl_chart.dart';

late BannerAd _bannerAd;
bool _isBannerAdReady = false;
final curFormat = new NumberFormat.simpleCurrency(locale: 'en_IN');

class SIPScreen extends StatefulWidget {
  @override
  _SIPScreenState createState() => _SIPScreenState();
}

class _SIPScreenState extends State<SIPScreen> {
  final _formKey = GlobalKey<FormState>();
  double _monthlyInvestmentSliderValue = 5000;
  double _expectedReturnSliderValue = 12;
  double _timePeriodSliderValue = 2;
  final _monthlyInvestmentController = TextEditingController(text: '5000');
  final _expectedReturnSController = TextEditingController(text: '12');
  final _timePeriodController = TextEditingController(text: '2');

  double sip = 0.0;
  double totalAmount = 0.0;

  void calculateSip() {
    // getting values from form
    double amount = _monthlyInvestmentSliderValue;
    double duration = _timePeriodSliderValue;
    double rateOfReturn = _expectedReturnSliderValue;

    double r = rateOfReturn / 100 / 12;
    sip = amount * ((pow(1 + r, 12 * duration) - 1) / (r)) * (1 + r);
    totalAmount = amount * duration * 12;
  }

  void initState() {
    super.initState();
    calculateSip();

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.leaderboard,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: 'SIP Calculator'.text.make()),
      body: Container(
        // padding: kAppPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: 'Monthly Investment'
                              .text
                              .lg
                              .make()
                              .pOnly(left: 24.0),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _monthlyInvestmentController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(prefix: Text('₹ ')),
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (value) {
                              if (value.isEmptyOrNull) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value.isEmptyOrNull &&
                                  double.parse(value) >= 500 &&
                                  double.parse(value) <= 50000)
                                {
                                  setState(() {
                                    _monthlyInvestmentSliderValue =
                                        double.parse(value);
                                    calculateSip();
                                  })
                                }
                            },
                          ).pOnly(right: 24.0),
                        ),
                      ],
                    ),
                    Slider(
                      value: _monthlyInvestmentSliderValue,
                      min: 500,
                      max: 50000,
                      divisions: 495,
                      label: _monthlyInvestmentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _monthlyInvestmentSliderValue = value;
                          _monthlyInvestmentController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateSip();
                        });
                      },
                    ),
                    HeightBox(20.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: 'Expected Return Rate'
                              .text
                              .lg
                              .make()
                              .pOnly(left: 24.0),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _expectedReturnSController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(suffix: Text(' %')),
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value.isEmptyOrNull) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value.isEmptyOrNull &&
                                  double.parse(value) >= 1 &&
                                  double.parse(value) <= 30)
                                {
                                  setState(() {
                                    _expectedReturnSliderValue =
                                        double.parse(value);
                                    calculateSip();
                                  })
                                }
                            },
                          ).pOnly(right: 24.0),
                        ),
                      ],
                    ),
                    Slider(
                      value: _expectedReturnSliderValue,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: _expectedReturnSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _expectedReturnSliderValue = value;
                          _expectedReturnSController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateSip();
                        });
                      },
                    ),
                    HeightBox(20.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: 'Time Period'.text.lg.make().pOnly(left: 24.0),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _timePeriodController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(suffix: Text(' Year')),
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value.isEmptyOrNull) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value.isEmptyOrNull &&
                                  double.parse(value) >= 1 &&
                                  double.parse(value) <= 30)
                                {
                                  setState(() {
                                    _timePeriodSliderValue =
                                        double.parse(value);
                                    calculateSip();
                                  })
                                }
                            },
                          ).pOnly(right: 24.0),
                        ),
                      ],
                    ),
                    Slider(
                      value: _timePeriodSliderValue,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: _timePeriodSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _timePeriodSliderValue = value;
                          _timePeriodController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateSip();
                        });
                      },
                    ),
                    HeightBox(20),
                    'Total Investment is ${curFormat.format(totalAmount)}'
                        .text
                        .xl
                        .bold
                        .purple600
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Return is ${curFormat.format((sip - totalAmount))}'
                        .text
                        .xl
                        .bold
                        .green600
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Total value is ${curFormat.format(sip)}'
                        .text
                        .xl
                        .bold
                        .makeCentered()
                        .pOnly(top: 5.0),
                    HeightBox(50),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          titlesData: titlesData,
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                          gridData: const FlGridData(show: false),
                          barTouchData: barTouchData,
                          alignment: BarChartAlignment.spaceAround,
                        ),
                      ),
                    ),
                    if (_isBannerAdReady)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: _bannerAd.size.width.toDouble(),
                          height: _bannerAd.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ),
                      ).py20(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: double.parse(totalAmount.toStringAsFixed(2)),
              color: Vx.purple600,
              width: 12.5,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: double.parse((sip - totalAmount).toStringAsFixed(2)),
              color: Vx.green600,
              width: 12.5,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: double.parse((sip).toStringAsFixed(2)),
              color: Vx.gray600,
              width: 12.5,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      ];

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: kSecondaryDartColor,
      fontWeight: FontWeight.bold,
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
        text = 'Total Value';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.yellow,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: kSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );
}
