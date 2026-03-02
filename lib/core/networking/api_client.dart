import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({required String baseUrl, String? authToken})
    : _authToken = authToken,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token refresh can be added here when auth API is available.
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));
  }

  final Dio _dio;
  String? _authToken;

  Dio get dio => _dio;

  void updateAuthToken(String? token) {
    _authToken = token;
  }
}
