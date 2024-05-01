import 'package:dart_http_client/dart_http_client.dart';

class Delete implements HttpMethod {
  const Delete();

  @override
  String get methodString => 'DELETE';

  @override
  Future<NetworkResponse> request({
    required NetworkProvider http,
    required Endpoint endpoint,
  }) {
    return http.delete(endpoint);
  }
}
