import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapValidity extends ChangeNotifier {
  bool isApiKeyValid = false;

  MapValidity(BuildContext context) {
    String api = ApiKey().apiKey();
    if (api == "123456789000000") {
      isApiKeyValid = true;
    }
    // Provider.of<MapValidity>(context, listen: true).setValidity(isApiKeyValid);
  }
  void setValidity(bool isValid) {
    isApiKeyValid = isValid;
    notifyListeners();
  }
}

class ApiKey {
  static final ApiKey _instance = ApiKey._internal();
  factory ApiKey() {
    return _instance;
  }
  ApiKey._internal();

  String _apiKey = "";
  setApiKey(String api) => _apiKey = api;
  String apiKey() => _apiKey;
}
