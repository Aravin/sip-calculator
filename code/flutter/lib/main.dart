import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/home.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: kPrimaryColor,
        secondaryHeaderColor: kSecondaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'IBM Plex Mono',
        appBarTheme: AppBarTheme(color: kPrimaryColor),
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
