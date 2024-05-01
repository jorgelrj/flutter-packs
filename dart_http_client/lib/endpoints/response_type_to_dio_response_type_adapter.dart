import 'package:dart_http_client/dart_http_client.dart';
import 'package:dio/dio.dart' as dio;

class ResponseTypeToDioResponseTypeAdapter {
  final Map<ResponseType, dio.ResponseType> _mapResponseType = const {
    ResponseType.bytes: dio.ResponseType.bytes,
    ResponseType.json: dio.ResponseType.json,
    ResponseType.plain: dio.ResponseType.plain,
    ResponseType.stream: dio.ResponseType.stream,
  };

  dio.ResponseType? _getDioResponseType({required ResponseType type}) {
    return _mapResponseType[type];
  }

  dio.Options createRequestOptionsWith({required Endpoint endpoint}) {
    return dio.Options(
      headers: endpoint.headers,
      responseType: _getDioResponseType(type: endpoint.responseType),
    );
  }
}
