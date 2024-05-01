import 'package:dio/dio.dart';

class NetworkResponse {
  final dynamic data;
  final int? status;
  final String? message;
  final DioExceptionType? typeError;

  NetworkResponse({
    required this.data,
    required this.status,
    this.typeError,
    this.message,
  });
}
