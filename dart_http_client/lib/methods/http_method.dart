import 'package:dart_http_client/dart_http_client.dart';

abstract class HttpMethod {
  const HttpMethod();

  String get methodString;

  Future<NetworkResponse> request({
    required NetworkProvider http,
    required Endpoint endpoint,
  });
}
