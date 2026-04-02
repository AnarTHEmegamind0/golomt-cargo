import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';
import 'package:flutter/material.dart';

class ApiDeliveryRepository implements DeliveryRepository {
  ApiDeliveryRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;
  final Map<String, DeliveryStep> _stepOverrides = {};
  final Map<String, String> _proofOverrides = {};

  static const _palette = [
    [Color(0xFF8F3F3A), Color(0xFFD79F84)],
    [Color(0xFF5A4D44), Color(0xFFC5A792)],
    [Color(0xFF384955), Color(0xFF99AEB7)],
    [Color(0xFF1F6AA5), Color(0xFF82B2D8)],
    [Color(0xFF2D6A4F), Color(0xFF95D5B2)],
    [Color(0xFF7C2D12), Color(0xFFF59E0B)],
  ];

  @override
  Future<List<DeliveryOrder>> fetchActiveOrders() async {
    try {
      final response = await _openApiClient.call(AppApiOperations.listCargos);
      final body = asJsonMap(response.data, context: 'cargo list response');
      final items = asJsonMapList(body['data'], context: 'cargo list data');

      final orders = items.map(_mapCargoToDeliveryOrder).toList();
      return orders
          .where((order) => order.step != DeliveryStep.completed)
          .toList(growable: false);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> updateOrderStep({
    required String orderId,
    required DeliveryStep step,
  }) async {
    _stepOverrides[orderId] = step;

    try {
      switch (step) {
        case DeliveryStep.accepted:
          await _openApiClient.call(
            AppApiOperations.chooseCargoFulfillment,
            pathParams: {'cargoId': orderId},
            data: {
              'fulfillmentType': 'HOME_DELIVERY',
              'deliveryAddress': 'Улаанбаатар',
              'deliveryPhone': '00000000',
            },
          );
          break;
        case DeliveryStep.pickedUp:
          await _openApiClient.call(
            AppApiOperations.shipCargo,
            pathParams: {'cargoId': orderId},
          );
          break;
        case DeliveryStep.arrived:
          await _openApiClient.call(
            AppApiOperations.arriveCargo,
            pathParams: {'cargoId': orderId},
          );
          break;
        case DeliveryStep.pending:
        case DeliveryStep.enRoute:
        case DeliveryStep.proof:
        case DeliveryStep.completed:
          break;
      }
    } catch (_) {
      // Keep local override for smooth UX even if remote transition is unavailable.
    }
  }

  @override
  Future<void> uploadProof({
    required String orderId,
    required String localPath,
  }) async {
    _proofOverrides[orderId] = localPath;
  }

  DeliveryOrder _mapCargoToDeliveryOrder(Map<String, dynamic> json) {
    final id = ((json['id'] as String?) ?? '').trim();
    final tracking = ((json['trackingNumber'] as String?) ?? '').trim();
    final description = ((json['description'] as String?) ?? '').trim();
    final status = ((json['status'] as String?) ?? '').trim();

    final safeId = id.isEmpty ? tracking : id;
    final seed = safeId.hashCode.abs();
    final palette = _palette[seed % _palette.length];
    final etaMinutes = 10 + (seed % 30);
    final earnings = _toDouble(json['totalFeeMnt']) / 1000;

    final remoteStep = _mapDeliveryStep(status);
    final step = _stepOverrides[safeId] ?? remoteStep;

    return DeliveryOrder(
      id: safeId,
      restaurantName: description.isEmpty ? 'Cargo $tracking' : description,
      customerName: 'Хэрэглэгч',
      deliveryAddress: _safeText(
        json['deliveryAddress'],
        fallback: 'Хаяг оруулаагүй',
      ),
      etaMinutes: etaMinutes,
      earnings: earnings <= 0 ? 0 : earnings,
      items: [tracking.isEmpty ? safeId : tracking],
      instructions: 'Хүргэлтийн дэлгэрэнгүй мэдээлэл удахгүй нэмэгдэнэ.',
      primaryColor: palette.first,
      secondaryColor: palette.last,
      imageHeroTag: 'delivery_$safeId',
      step: step,
      proofImagePath: _proofOverrides[safeId],
    );
  }

  DeliveryStep _mapDeliveryStep(String status) {
    switch (status) {
      case 'CREATED':
      case 'RECEIVED_CHINA':
        return DeliveryStep.pending;
      case 'IN_TRANSIT_TO_MN':
      case 'ARRIVED_MN':
      case 'AWAITING_FULFILLMENT_CHOICE':
        return DeliveryStep.accepted;
      case 'READY_FOR_PICKUP':
        return DeliveryStep.pickedUp;
      case 'OUT_FOR_DELIVERY':
        return DeliveryStep.enRoute;
      case 'COMPLETED_PICKUP':
      case 'COMPLETED_DELIVERY':
        return DeliveryStep.completed;
      default:
        return DeliveryStep.pending;
    }
  }

  String _safeText(dynamic raw, {required String fallback}) {
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return fallback;
  }

  double _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw) ?? 0;
    }
    return 0;
  }
}
