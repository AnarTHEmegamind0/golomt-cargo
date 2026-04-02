import 'package:core/core/config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Result wrapper for API responses
class ApiResult<T> {
  const ApiResult.success(this.data) : error = null, isSuccess = true;
  const ApiResult.failure(this.error) : data = null, isSuccess = false;

  final T? data;
  final ApiError? error;
  final bool isSuccess;
}

/// API Error model
class ApiError {
  const ApiError({required this.message, this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  factory ApiError.fromDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Холболтын хугацаа дууссан. Дахин оролдоно уу.';
        break;
      case DioExceptionType.connectionError:
        message = 'Интернет холболт байхгүй байна.';
        break;
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else if (statusCode == 401) {
          message = 'Нэвтрэх шаардлагатай.';
        } else if (statusCode == 403) {
          message = 'Хандах эрх байхгүй.';
        } else if (statusCode == 404) {
          message = 'Мэдээлэл олдсонгүй.';
        } else if (statusCode == 409) {
          message = 'Ийм бичлэг аль хэдийн байна.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Серверийн алдаа. Дахин оролдоно уу.';
        } else {
          message = 'Алдаа гарлаа: ${e.message}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Хүсэлт цуцлагдсан.';
        break;
      default:
        message = 'Тодорхойгүй алдаа гарлаа.';
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      details: e.response?.data,
    );
  }

  @override
  String toString() => message;
}

/// Main API Client with Dio
class ApiClient {
  ApiClient({String? baseUrl, String? authToken})
    : _authToken = authToken,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiConfig.baseUrl,
          connectTimeout: const Duration(
            milliseconds: ApiConfig.connectTimeout,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiConfig.receiveTimeout,
          ),
          sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  final Dio _dio;
  String? _authToken;

  Dio get dio => _dio;
  String? get authToken => _authToken;

  void _setupInterceptors() {
    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && _authToken != null) {
            // Could implement token refresh here
            debugPrint('🔒 Auth error: Token may be expired');
          }
          handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('📡 API: $obj'),
        ),
      );
    }
  }

  /// Update the auth token
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  /// Clear auth token (logout)
  void clearAuthToken() {
    _authToken = null;
  }

  // ============ Generic HTTP Methods ============

  /// GET request
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      }
      return ApiResult.success(response.data as T);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// POST request
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      }
      return ApiResult.success(response.data as T);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// PUT request
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      }
      return ApiResult.success(response.data as T);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// DELETE request
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      }
      return ApiResult.success(response.data as T);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDioException(e));
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }
}
