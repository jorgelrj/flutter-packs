import 'package:dart_http_client/dart_http_client.dart';

class Post implements HttpMethod {
  const Post();

  @override
  String get methodString => 'POST';

  @override
  Future<NetworkResponse> request({
    required NetworkProvider http,
    required Endpoint endpoint,
  }) {
    return http.post(endpoint);
  }
}
