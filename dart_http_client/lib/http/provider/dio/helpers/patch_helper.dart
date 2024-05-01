import 'package:dart_http_client/dart_http_client.dart';
import 'package:dio/dio.dart';

class PatchHelper implements RequestHelper {
  const PatchHelper();

  @override
  Future<NetworkResponse> makeRequestHelper({
    required Endpoint endpoint,
    required Dio httpProvider,
  }) async {
    final adapter = ResponseTypeToDioResponseTypeAdapter();
    final Response<dynamic> response = await httpProvider.patch<dynamic>(
      endpoint.path,
      options: adapter.createRequestOptionsWith(endpoint: endpoint),
      queryParameters: endpoint.queryParameters,
      data: endpoint.parameters,
    );

    return NetworkResponse(
      data: response.data,
      status: response.statusCode,
    );
  }
}
