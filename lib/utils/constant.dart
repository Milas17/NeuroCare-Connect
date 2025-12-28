import 'package:google_maps_flutter/google_maps_flutter.dart';

class Constant {
  static const String baseurl = 'https://basedtcare.neurocareconnect.tech/public/api/login';

  static const String appName = "NeuroCare Telemed";
  static const String chatAppName = "yourchatappname";
  static String appleAppId = "";
  static String appPackageName = "com.example.yourappname";
  static int zegoAppId = 0;
  static String zegoAppSign = "";

  static const googleApikey = "";

  // OneSignal App ID /
  static const String oneSignalAppIdKey = "d_onesignal_app_id";
  static String? oneSignalAppId;

  static String? userID;
  static String? isDemo = "0";
  static String userPlaceholder =
      "https://i.pinimg.com/564x/5d/69/42/5d6942c6dff12bd3f960eb30c5fdd0f9.jpg";

  // Dimentions START
  static double appBarHeight = 60.0;
  static double appBarTextSize = 20.0;
  static double textFieldHeight = 50.0;
  static double buttonHeight = 45.0;
  static double backBtnHeight = 15.0;
  static double backBtnWidth = 19.0;
  static String accessToken = "";
  // Dimentions END

  // Static Location
  static LatLng defaultLocation = const LatLng(20.5937, 78.9629);
  static double defaultLatitude = 20.5937;
  static double defaultLongitude = 78.9629;
}
