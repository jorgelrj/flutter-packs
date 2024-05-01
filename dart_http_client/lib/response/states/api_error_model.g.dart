// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['message', 'statusCode'],
    disallowNullValues: const ['message', 'statusCode'],
  );
  return ApiError(
    message: json['message'] as String,
    statusCode: json['statusCode'] as int,
    errors: (json['errors'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
  );
}

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) {
  final val = <String, dynamic>{
    'message': instance.message,
    'statusCode': instance.statusCode,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('errors', instance.errors);
  return val;
}
