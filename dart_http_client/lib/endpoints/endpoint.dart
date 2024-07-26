import 'package:dart_http_client/dart_http_client.dart';

class Endpoint {
  final String path;
  final HttpMethod method;
  final bool rawPath;
  final ResponseType responseType;
  final Map<String, dynamic>? headers;
  final dynamic parameters;
  final Map<String, dynamic>? queryParameters;

  Endpoint({
    required this.path,
    required this.method,
    this.responseType = ResponseType.json,
    this.parameters,
    this.queryParameters,
    this.rawPath = false,
    this.headers,
  });
}
