import 'package:dart_http_client/dart_http_client.dart';

class Get implements HttpMethod {
  const Get();

  @override
  String get methodString => 'GET';

  @override
  Future<NetworkResponse> request({
    required NetworkProvider http,
    required Endpoint endpoint,
  }) {
    return http.get(endpoint);
  }
}
