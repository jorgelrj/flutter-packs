import 'package:dart_http_client/dart_http_client.dart';

class Success extends ApiResult {
  final int? statusCode;
  final dynamic data;

  const Success({
    this.data,
    this.statusCode,
  });
}
