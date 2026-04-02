import 'package:dio/dio.dart';

typedef JsonMap = Map<String, dynamic>;

String extractApiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return 'Network request failed (${error.type.name})';
  }

  return error.toString();
}

JsonMap asJsonMap(dynamic raw, {required String context}) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  throw FormatException('Expected object for $context');
}

List<JsonMap> asJsonMapList(dynamic raw, {required String context}) {
  if (raw is! List) {
    throw FormatException('Expected list for $context');
  }

  return raw
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList();
}
