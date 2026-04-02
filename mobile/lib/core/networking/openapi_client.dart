import 'package:core/core/networking/openapi_registry.dart';
import 'package:core/core/services/api_service.dart';
import 'package:dio/dio.dart';

class OpenApiClient {
  OpenApiClient({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Iterable<String> get operations => kOpenApiOperations.keys;

  Future<Response<dynamic>> call(
    String operation, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? query,
    dynamic data,
  }) async {
    final descriptor = kOpenApiOperations[operation];
    if (descriptor == null) {
      throw ArgumentError.value(
        operation,
        'operation',
        'Unknown OpenAPI operation',
      );
    }

    final resolvedPath = _resolvePath(
      descriptor.path,
      pathParams: pathParams ?? const {},
    );

    return _apiService.request(
      descriptor.method,
      resolvedPath,
      query: query,
      data: data,
    );
  }

  String _resolvePath(
    String rawPath, {
    required Map<String, String> pathParams,
  }) {
    var path = rawPath;
    for (final entry in pathParams.entries) {
      path = path.replaceAll(
        '{${entry.key}}',
        Uri.encodeComponent(entry.value),
      );
    }
    return path;
  }
}
