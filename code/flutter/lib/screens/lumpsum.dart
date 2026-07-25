import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sip_calculator/shared/ads.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

late BannerAd _bannerAd;
bool _isBannerAdReady = false;
final curFormat = new NumberFormat.simpleCurrency(locale: 'en_IN');

const LUMPSUM_MIN_AMT = 10000.00;
const LUMPSUM_MAX_AMT = 1000000.00;
const LUMPSUM_AVG_AMT = 25000.00;

class LumpSumScreen extends StatefulWidget {
  @override
  _LumpSumScreenState createState() => _LumpSumScreenState();
}

class _LumpSumScreenState extends State<LumpSumScreen> {
  final _formKey = GlobalKey<FormState>();
  double _investmentSliderValue = LUMPSUM_AVG_AMT;
  double _expectedReturnSliderValue = 12;
  double _timePeriodSliderValue = 2;
  final _investmentController =
      TextEditingController(text: LUMPSUM_AVG_AMT.toString());
  final _expectedReturnSController = TextEditingController(text: '12');
  final _timePeriodController = TextEditingController(text: '2');

  double futureValue = 0.0;
  double totalAmount = 0.0;

  void calculateLumpsum() {
    double amount = _investmentSliderValue;
    double duration = _timePeriodSliderValue;
    double rateOfReturn = _expectedReturnSliderValue;

    double r = rateOfReturn / 100;
    futureValue = amount * pow(1 + r, duration);
    totalAmount = amount;
  }

  void initState() {
    super.initState();
    calculateLumpsum();

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
      appBar: AppBar(title: 'Lump-sum Calculator'.text.make()),
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
                          child: 'One Time Investment'
                              .text
                              .lg
                              .make()
                              .pOnly(left: 24.0),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _investmentController,
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
                            onChanged: (value) {
                              if (!value.isEmptyOrNull) {
                                try {
                                  final v = double.parse(value);
                                  if (v >= LUMPSUM_MIN_AMT && v <= LUMPSUM_MAX_AMT) {
                                    setState(() {
                                      _investmentSliderValue = v;
                                      calculateLumpsum();
                                    });
                                  }
                                } catch (_) {}
                              }
                            },
                          ).pOnly(right: 24.0),
                        ),
                      ],
                    ),
                    Slider(
                      value: _investmentSliderValue,
                      min: LUMPSUM_MIN_AMT,
                      max: LUMPSUM_MAX_AMT,
                      // divisions: 495,
                      label: _investmentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _investmentSliderValue = value;
                          _investmentController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateLumpsum();
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
                              if (value!.isEmptyOrNull) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (!value.isEmptyOrNull) {
                                try {
                                  final v = double.parse(value);
                                  if (v >= 1 && v <= 30) {
                                    setState(() {
                                      _expectedReturnSliderValue = v;
                                      calculateLumpsum();
                                    });
                                  }
                                } catch (_) {}
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
                      divisions: 30,
                      label: _expectedReturnSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _expectedReturnSliderValue = value;
                          _expectedReturnSController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateLumpsum();
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
                              if (value!.isEmptyOrNull) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (!value.isEmptyOrNull) {
                                try {
                                  final v = double.parse(value);
                                  if (v >= 1 && v <= 30) {
                                    setState(() {
                                      _timePeriodSliderValue = v;
                                      calculateLumpsum();
                                    });
                                  }
                                } catch (_) {}
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
                      divisions: 30,
                      label: _timePeriodSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _timePeriodSliderValue = value;
                          _timePeriodController.value =
                              TextEditingValue(text: value.toInt().toString());
                          calculateLumpsum();
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
                    'Future Return is ${curFormat.format(futureValue)}'
                        .text
                        .xl
                        .bold
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Profit is ${curFormat.format(futureValue - totalAmount)}'
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
