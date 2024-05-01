import 'package:dart_http_client/dart_http_client.dart';
import 'package:dio/dio.dart';

class DioProvider implements NetworkProvider {
  late Dio? _provider;

  Future<NetworkResponse> _safeRequest({
    required RequestHelper requestHelper,
    required Endpoint endpoint,
  }) async {
    _provider = await DioCreator.create();

    try {
      return await requestHelper.makeRequestHelper(
        endpoint: endpoint,
        httpProvider: _provider!,
      );
    } on DioException catch (e) {
      return e.response != null
          ? NetworkResponse(
              data: e.response!.data,
              status: e.response!.statusCode,
              typeError: e.type,
            )
          : NetworkResponse(
              message: e.message,
              typeError: e.type,
              status: 520,
              data: null,
            );
    }
  }

  @override
  Future<NetworkResponse> get(Endpoint endpoint) async {
    const GetHelper requestHelper = GetHelper();

    return _safeRequest(requestHelper: requestHelper, endpoint: endpoint);
  }

  @override
  Future<NetworkResponse> post(Endpoint endpoint) async {
    return _safeRequest(requestHelper: const PostHelper(), endpoint: endpoint);
  }

  @override
  Future<NetworkResponse> put(Endpoint endpoint) {
    const PutHelper requestHelper = PutHelper();

    return _safeRequest(requestHelper: requestHelper, endpoint: endpoint);
  }

  @override
  Future<NetworkResponse> delete(Endpoint endpoint) {
    const DeleteHelper requestHelper = DeleteHelper();

    return _safeRequest(requestHelper: requestHelper, endpoint: endpoint);
  }

  @override
  Future<NetworkResponse> patch(Endpoint endpoint) {
    return _safeRequest(
      requestHelper: const PatchHelper(),
      endpoint: endpoint,
    );
  }
}
