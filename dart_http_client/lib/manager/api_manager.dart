import 'dart:async';

import 'package:dart_http_client/dart_http_client.dart';

class ApiManager {
  const ApiManager._();

  static final NetworkProvider _networkProvider = DioProvider();

  static Future<ApiResult> request({required Endpoint endpoint}) async {
    try {
      final response = await endpoint.method.request(
        http: _networkProvider,
        endpoint: endpoint,
      );

      if (response.status! >= 200 && response.status! < 400) {
        return Success(
          data: response.data,
          statusCode: response.status,
        );
      }
      if (response.status == 400) {
        final data = response.data as Map<String, dynamic>;
        final errors = data['errors'] as List?;
        final errorList = errors
            ?.map<Map<String, dynamic>>(
              (dynamic p) => p as Map<String, dynamic>,
            )
            .toList();

        return ApiError(
          message: _validationErrorMessage(errorList) ?? data['message'] as String,
          errors: errorList,
          statusCode: 400,
        );
      }

      return ApiError.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return ApiError.internalError();
    }
  }

  static String? _validationErrorMessage(List<Map<String, dynamic>>? errors) {
    if (errors != null) {
      for (final Map<String, dynamic> errorMap in errors) {
        final constraints = errorMap['constraints'] as Map<String, dynamic>?;
        if (constraints != null && constraints.isNotEmpty) {
          return constraints.values.first as String;
        }
      }
    }

    return null;
  }
}
