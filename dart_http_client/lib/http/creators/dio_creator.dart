import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioCreator {
  static Future<Dio> create() async {
    final Dio dio = Dio()..options.headers = _headers();

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(),
      );
    }

    return dio;
  }

  static Map<String, dynamic> _headers() {
    return <String, dynamic>{'content-type': 'application/json'};
  }
}
