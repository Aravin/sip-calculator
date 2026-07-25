import 'dart:io';

class AdManager {
  static bool get _isTestEnvironment =>
      Platform.environment.containsKey('FLUTTER_TEST');

  static String get appId {
    if (_isTestEnvironment) return "ca-app-pub-3940256099942544~1458002511";
    if (Platform.isAndroid) {
      return "ca-app-pub-2191548178499350~7648928102";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_ADMOB_APP_ID>";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (_isTestEnvironment) return "ca-app-pub-3940256099942544/6300978111";
    if (Platform.isAndroid) {
      return "ca-app-pub-2191548178499350/3518111407";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (_isTestEnvironment) return "ca-app-pub-3940256099942544/1033173712";
    if (Platform.isAndroid) {
      return "ca-app-pub-2191548178499350/3580856433";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
