import 'package:core/core/networking/api_client.dart';
import 'package:dio/dio.dart';

class ApiService {
  ApiService({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _retry(() => _dio.get(path, queryParameters: query));
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return _retry(() => _dio.post(path, data: data, queryParameters: query));
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return _retry(() => _dio.patch(path, data: data, queryParameters: query));
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
