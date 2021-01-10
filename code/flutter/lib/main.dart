import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/home.dart';
import 'package:sip_calculator/shared/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: kPrimaryColor,
        secondaryHeaderColor: kSecondaryColor,
        accentColor: kSecondaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'IBM Plex Mono',
        sliderTheme: SliderThemeData(
          activeTrackColor: kPrimaryLiteColor,
          inactiveTrackColor: kPrimaryColor,
          thumbColor: kSecondaryLiteColor,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
