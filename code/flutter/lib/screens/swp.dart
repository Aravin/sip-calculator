import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sip_calculator/shared/ads.dart';
import 'package:velocity_x/velocity_x.dart';

class SWPScreen extends StatefulWidget {
  @override
  _SWPScreenState createState() => _SWPScreenState();
}

class _SWPScreenState extends State<SWPScreen> {
  final _formKey = GlobalKey<FormState>();
  double _investmentSliderValue = 50000;
  double _withdrawSliderValue = 1000;
  double _expectedReturnSliderValue = 12;
  double _timePeriodSliderValue = 2;
  final _monthlyInvestmentController = TextEditingController(text: '50000');
  final _withdrawController = TextEditingController(text: '1000');
  final _expectedReturnSController = TextEditingController(text: '12');
  final _timePeriodController = TextEditingController(text: '2');

  int touchedIndex;

  double sip = 0.0;
  double totalAmount = 0.0;
  double withdrawn = 0.0;

  void calculateSip() {
    // getting values from form
    double amount = _investmentSliderValue;
    double withdraw = _withdrawSliderValue;
    double duration = _timePeriodSliderValue;
    double rateOfReturn = _expectedReturnSliderValue;

    if (amount.isNull || duration.isNull || rateOfReturn.isNull) {
      return;
    }

    sip = ((amount * pow((1 + rateOfReturn / 100), duration)) -
        (withdraw *
            (pow((1 + (pow((1 + rateOfReturn / 100), (1 / 12)) - 1)),
                    (duration * 12)) -
                1) /
            (pow((1 + rateOfReturn / 100), (1 / 12)) - 1)));
    totalAmount = amount;
    withdrawn = duration * 12 * withdraw;
  }

  void initState() {
    super.initState();
    calculateSip();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: 'SWP Calculator'.text.make()),
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
                          child: 'Total Investment'
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
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value != null &&
                                  value != '' &&
                                  double.parse(value) >= 500 &&
                                  double.parse(value) <= 50000)
                                {
                                  setState(() {
                                    _investmentSliderValue =
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
                      value: _investmentSliderValue,
                      min: 500,
                      max: 50000,
                      divisions: 495,
                      label: _investmentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _investmentSliderValue = value;
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
                          child: 'Monthly Withdraw'
                              .text
                              .lg
                              .make()
                              .pOnly(left: 24.0),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _withdrawController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(prefix: Text('₹ ')),
                            inputFormatters: [
                              new LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value != null &&
                                  value != '' &&
                                  double.parse(value) >= 1 &&
                                  double.parse(value) <= 30)
                                {
                                  setState(() {
                                    _withdrawSliderValue = double.parse(value);
                                    calculateSip();
                                  })
                                }
                            },
                          ).pOnly(right: 24.0),
                        ),
                      ],
                    ),
                    Slider(
                      value: _withdrawSliderValue,
                      min: 500,
                      max: 50000,
                      divisions: 495,
                      label: _withdrawSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _withdrawSliderValue = value;
                          _withdrawController.value =
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
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value != null &&
                                  value != '' &&
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
                      divisions: 30,
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
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => {
                              if (value != null &&
                                  value != '' &&
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
                      divisions: 30,
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
                    'Total Investment is ₹${totalAmount.toStringAsFixed(2)}'
                        .text
                        .xl
                        .bold
                        .purple600
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Future Return is ₹${sip.toStringAsFixed(2)}'
                        .text
                        .xl
                        .bold
                        .makeCentered()
                        .pOnly(top: 5.0),
                    'Withdrawn Amount is ₹${(withdrawn).toStringAsFixed(2)}'
                        .text
                        .xl
                        .bold
                        .green600
                        .makeCentered()
                        .pOnly(top: 5.0),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: AdmobBanner(
                  adUnitId: AdManager.bannerAdUnitId,
                  adSize: AdmobBannerSize.LARGE_BANNER,
                  listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                    print([event, args, 'Banner']);
                  },
                  onBannerCreated: (AdmobBannerController controller) {
                    // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                    // Normally you don't need to worry about disposing this yourself, it's handled.
                    // If you need direct access to dispose, this is your guy!
                    // controller.dispose();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
