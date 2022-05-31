import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';

class API {
  static String hostUrl = Constants.hostUrl;
  static final API _singleton = API._internal();
  factory API() => _singleton;
  API._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: hostUrl,
        connectTimeout: 5000,
        receiveTimeout: 4000,
      ),
    );
  }

  late Dio dio;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    Response response;
    log(dio.options.baseUrl + path);
    try {
      response = await dio.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioError catch (e) {
      response = e.response!;
    }
    return response;
  }
}
