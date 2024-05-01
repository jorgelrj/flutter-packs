import 'package:dart_http_client/dart_http_client.dart';

abstract class NetworkProvider {
  Future<NetworkResponse> get(Endpoint endpoints);
  Future<NetworkResponse> post(Endpoint endpoints);
  Future<NetworkResponse> put(Endpoint endpoints);
  Future<NetworkResponse> delete(Endpoint endpoints);
  Future<NetworkResponse> patch(Endpoint endpoints);
}
