import 'package:dart_http_client/dart_http_client.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiError extends ApiResult {
  const ApiError({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @JsonKey(
    disallowNullValue: true,
    includeIfNull: false,
    required: true,
  )
  final String message;

  @JsonKey(
    disallowNullValue: true,
    includeIfNull: false,
    required: true,
  )
  final int statusCode;

  @JsonKey(
    required: false,
  )
  final List<Map<String, dynamic>>? errors;

  factory ApiError.internalError() {
    const message = 'Ops. An error occurred.';

    return const ApiError(
      message: message,
      statusCode: 520,
    );
  }
}
