import 'package:dart_http_client/dart_http_client.dart';

class Put implements HttpMethod {
  const Put();

  @override
  String get methodString => 'PUT';

  @override
  Future<NetworkResponse> request({
    required NetworkProvider http,
    required Endpoint endpoint,
  }) {
    return http.put(endpoint);
  }
}
