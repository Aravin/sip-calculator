import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sip_calculator/shared/ads.dart';
import 'package:sip_calculator/shared/donut_chart.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:charts_flutter/flutter.dart' as charts;

late BannerAd _bannerAd;
bool _isBannerAdReady = false;
final curFormat = new NumberFormat.simpleCurrency();

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
                    'Total Investment is ₹${curFormat.format(totalAmount)}'
                        .text
                        .xl
                        .bold
                        .purple600
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Future Return is ₹${curFormat.format(sip)}'
                        .text
                        .xl
                        .bold
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Profit is ₹${curFormat.format((sip - totalAmount))}'
                        .text
                        .xl
                        .bold
                        .green600
                        .makeCentered()
                        .pOnly(top: 5.0),
                    if (_isBannerAdReady)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: _bannerAd.size.width.toDouble(),
                          height: _bannerAd.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ),
                      ).py20(),
                    SizedBox(
                      height: 250,
                      child: DonutPieChart(_createRandomData(), true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Create random data.
  List<charts.Series<LinearSales, num>> _createRandomData() {
    final data = [
      new LinearSales(
        'Investment',
        double.parse(totalAmount.toStringAsFixed(2)),
        charts.MaterialPalette.purple.shadeDefault,
      ),
      new LinearSales(
        'Returns',
        double.parse((sip - totalAmount).toStringAsFixed(2)),
        charts.MaterialPalette.green.shadeDefault,
      ),
    ];

    return [
      new charts.Series<LinearSales, num>(
        id: 'SIP',
        domainFn: (LinearSales sales, _) => sales.amount,
        measureFn: (LinearSales sales, _) => sales.amount,
        colorFn: (_, __) => _.color,
        areaColorFn: (_, __) =>
            charts.MaterialPalette.green.shadeDefault.lighter,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final String label;
  final num amount;
  final charts.Color color;

  LinearSales(this.label, this.amount, this.color);
}
