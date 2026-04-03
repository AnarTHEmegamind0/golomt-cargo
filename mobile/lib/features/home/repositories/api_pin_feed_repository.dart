import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';
import 'package:flutter/material.dart';

class ApiPinFeedRepository implements PinFeedRepository {
  ApiPinFeedRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;
  static const int _pageSize = 100;

  static const _statusColorMap = <String, List<Color>>{
    'CREATED': [Color(0xFFF08A1A), Color(0xFFE85D04)],
    'RECEIVED_CHINA': [Color(0xFF7C3AED), Color(0xFF4C1D95)],
    'IN_TRANSIT_TO_MN': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    'ARRIVED_MN': [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    'AWAITING_FULFILLMENT_CHOICE': [Color(0xFFF59E0B), Color(0xFFD97706)],
    'READY_FOR_PICKUP': [Color(0xFF10B981), Color(0xFF047857)],
    'OUT_FOR_DELIVERY': [Color(0xFF14B8A6), Color(0xFF0F766E)],
    'COMPLETED_PICKUP': [Color(0xFF22C55E), Color(0xFF15803D)],
    'COMPLETED_DELIVERY': [Color(0xFF16A34A), Color(0xFF166534)],
  };

  @override
  Future<List<PinItem>> fetchPins() async {
    try {
      final items = await _fetchAllCargoItems();
      return items.map(_mapCargoToPin).toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  PinItem _mapCargoToPin(Map<String, dynamic> json) {
    final id = ((json['id'] as String?) ?? '').trim();
    final tracking = ((json['trackingNumber'] as String?) ?? '').trim();
    final description = ((json['description'] as String?) ?? '').trim();
    final status = ((json['status'] as String?) ?? '').trim();

    final colors =
        _statusColorMap[status] ?? const [Color(0xFF6B7280), Color(0xFF374151)];

    final seed = (id.isEmpty ? tracking : id).hashCode.abs();
    final likes = 120 + (seed % 880);
    final ratio = 0.68 + ((seed % 60) / 100);

    return PinItem(
      id: id.isEmpty ? tracking : id,
      title: description.isEmpty ? 'Tracking $tracking' : description,
      author: 'Cargo System',
      board: status.isEmpty ? 'Unknown' : status,
      aspectRatio: ratio,
      likes: likes,
      primaryColor: colors.first,
      secondaryColor: colors.last,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllCargoItems() async {
    final items = <Map<String, dynamic>>[];
    var page = 1;

    while (true) {
      final response = await _openApiClient.call(
        AppApiOperations.listCargos,
        query: {'page': page, 'limit': _pageSize},
      );
      final body = asJsonMap(response.data, context: 'cargo list response');
      items.addAll(asJsonMapList(body['data'], context: 'cargo list data'));

      final meta = asPaginationMeta(body['meta'], context: 'cargo list meta');
      if (meta == null || page >= meta.totalPages) {
        break;
      }

      page += 1;
    }

    return items;
  }
}
