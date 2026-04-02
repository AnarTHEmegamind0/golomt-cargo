import 'package:core/core/networking/api_client.dart';
import 'package:dio/dio.dart';

class ApiService {
  ApiService({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return request('GET', path, query: query);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return request('POST', path, data: data, query: query);
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return request('PATCH', path, data: data, query: query);
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return request('PUT', path, data: data, query: query);
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return request('DELETE', path, data: data, query: query);
  }

  Future<Response<dynamic>> request(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return _retry(
      () => _dio.request(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      ),
    );
  }

  Future<Response<dynamic>> _retry(
    Future<Response<dynamic>> Function() request,
  ) async {
    var attempts = 0;

    while (true) {
      try {
        return await request();
      } on DioException {
        attempts++;
        if (attempts >= 3) rethrow;
        final delayMs = 250 * attempts * attempts;
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}
