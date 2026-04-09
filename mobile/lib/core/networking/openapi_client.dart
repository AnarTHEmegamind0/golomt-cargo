import 'package:core/core/networking/openapi_registry.dart';
import 'package:core/core/networking/downloaded_file.dart';
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

  Future<DownloadedFile> downloadOperation(
    String operation, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? query,
    String? fallbackFilename,
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

    final response = await _apiService.request(
      descriptor.method,
      resolvedPath,
      query: query,
      responseType: ResponseType.bytes,
      headers: const {'Accept': '*/*'},
    );

    final bytes = response.data is List<int>
        ? List<int>.from(response.data as List<int>)
        : (response.data as List<dynamic>).cast<int>();
    final contentType = response.headers.value(Headers.contentTypeHeader);

    return DownloadedFile(
      bytes: bytes,
      filename:
          _extractFilename(response) ??
          fallbackFilename ??
          _filenameFromPath(resolvedPath),
      contentType: contentType ?? 'application/octet-stream',
    );
  }

  String? _extractFilename(Response<dynamic> response) {
    final disposition = response.headers.value('content-disposition');
    if (disposition == null || disposition.isEmpty) {
      return null;
    }

    final utf8Match = RegExp(
      r"filename\\*=UTF-8''([^;]+)",
    ).firstMatch(disposition);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!);
    }

    final standardMatch = RegExp(
      r'filename="?([^"]+)"?',
    ).firstMatch(disposition);
    return standardMatch?.group(1);
  }

  String _filenameFromPath(String path) {
    final sanitized = path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .join('-');
    return sanitized.isEmpty ? 'download.bin' : sanitized;
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
