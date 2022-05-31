import 'package:package_info_plus/package_info_plus.dart';

class Constants {
  static String hostUrl = "https://raksichaiyo.com/api/";
  static final Constants _singleton = Constants._internal();
  factory Constants() {
    return _singleton;
  }
  Constants._internal();

  String appId = "";
  String apiKey = "";
  getSetCredentials(String apiKey) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appId = packageInfo.packageName;
    this.apiKey = apiKey;
  }
}
