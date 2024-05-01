import 'package:dart_http_client/dart_http_client.dart';
import 'package:dio/dio.dart';

abstract class RequestHelper {
  const RequestHelper();

  Future<NetworkResponse> makeRequestHelper({
    required Endpoint endpoint,
    required Dio httpProvider,
  });
}
