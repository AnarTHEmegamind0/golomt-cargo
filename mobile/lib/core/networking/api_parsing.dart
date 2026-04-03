import 'package:dio/dio.dart';

typedef JsonMap = Map<String, dynamic>;

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 1,
    );
  }
}

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

PaginationMeta? asPaginationMeta(dynamic raw, {required String context}) {
  if (raw == null) {
    return null;
  }

  if (raw is Map<String, dynamic>) {
    return PaginationMeta.fromJson(raw);
  }

  throw FormatException('Expected object for $context');
}

int? _asInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw);
  return null;
}
