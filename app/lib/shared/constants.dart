import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF00E2A6);
const Color kPrimaryDarkColor = Color(0xFF00FFDD);
const Color kPrimaryLiteColor = Color(0xFF00B29A);

const Color kSecondaryColor = Color(0xFF33404F);
const Color kSecondaryDarkColor = Color(0xFF637C9A);
const Color kSecondaryLiteColor = Color(0xFF323F4E);

const EdgeInsets kAppPadding = EdgeInsets.all(10.0);

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: kPrimaryColor,
  secondaryHeaderColor: kSecondaryColor,
  fontFamily: 'IBM Plex Mono',
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
  dividerColor: Colors.grey.shade300,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: kPrimaryLiteColor,
    inactiveTrackColor: kPrimaryColor,
    thumbColor: kSecondaryLiteColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    isDense: true,
  ),
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: kPrimaryColor,
  secondaryHeaderColor: kSecondaryColor,
  fontFamily: 'IBM Plex Mono',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: Colors.grey.shade700,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: kPrimaryLiteColor,
    inactiveTrackColor: Color(0xFF555555),
    thumbColor: kPrimaryColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    isDense: true,
    fillColor: const Color(0xFF2C2C2C),
    filled: true,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
  ),
);
