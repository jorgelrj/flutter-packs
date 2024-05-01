import 'package:dart_http_client/dart_http_client.dart';

abstract class ApiResult {
  const ApiResult();

  T map<T>({
    T Function(Success success)? onSuccess,
    T Function(ApiError error)? onError,
  }) {
    final ApiResult _this = this;

    if (_this is Success) {
      return onSuccess!(_this);
    } else if (_this is ApiError) {
      return onError!(_this);
    }
    throw Exception('ApiFailure $_this was not mapped');
  }
}
