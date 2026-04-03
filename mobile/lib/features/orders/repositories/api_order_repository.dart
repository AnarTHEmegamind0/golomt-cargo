import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/repositories/order_repository.dart';
import 'package:dio/dio.dart';

class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;
  List<Order> _cache = const [];
  static const int _pageSize = 100;

  @override
  Future<Order> createOrder({
    required String trackingCode,
    String? productName,
  }) async {
    final normalizedTracking = trackingCode.trim();
    if (normalizedTracking.isEmpty) {
      throw Exception('Tracking code is required');
    }

    try {
      final response = await _openApiClient.call(
        AppApiOperations.createCargo,
        data: {
          'trackingNumber': normalizedTracking,
          if (productName != null && productName.trim().isNotEmpty)
            'description': productName.trim(),
        },
      );

      final body = asJsonMap(response.data, context: 'create cargo response');
      final createdData = body['data'];
      final order = createdData is Map<String, dynamic>
          ? _mapCargoToOrder(createdData)
          : Order(
              id: normalizedTracking,
              trackingCode: normalizedTracking,
              productName: (productName ?? '').trim().isEmpty
                  ? 'Cargo $normalizedTracking'
                  : productName!.trim(),
              status: OrderStatus.pending,
              createdAt: DateTime.now(),
              price: 0,
              weight: 0,
              isPaid: false,
            );

      _cache = [order, ..._cache.where((item) => item.id != order.id)];
      return order;
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<List<Order>> fetchAll() async {
    try {
      final orders = await _fetchAllOrders();
      _cache = orders;
      return orders;
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Order?> fetchById(String id) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.getCargoById,
        pathParams: {'cargoId': id},
      );
      final body = asJsonMap(response.data, context: 'cargo detail response');
      final data = asJsonMap(body['data'], context: 'cargo detail data');
      return _mapCargoToOrder(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw Exception(extractApiErrorMessage(error));
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<List<Order>> fetchByStatus(OrderStatus status) async {
    final statuses = _mapApiStatuses(status);
    if (statuses.isEmpty) {
      final source = _cache.isEmpty ? await fetchAll() : _cache;
      return source.where((order) => order.status == status).toList();
    }

    try {
      final merged = <Order>[];
      final byId = <String>{};

      for (final apiStatus in statuses) {
        final parsed = await _fetchAllOrders(query: {'status': apiStatus});
        for (final order in parsed) {
          if (byId.add(order.id)) {
            merged.add(order);
          }
        }
      }

      _cache = merged;
      return merged;
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<List<Order>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return fetchAll();
    }

    try {
      final orders = await _fetchAllOrders(
        query: {'q': normalized},
        search: true,
      );
      _cache = orders;
      return orders;
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> delete(String id) async {
    _cache = _cache.where((order) => order.id != id).toList();
  }

  @override
  Future<void> markAsPaid(String id) async {
    try {
      await _openApiClient.call(
        AppApiOperations.createBatchPayment,
        data: {
          'cargoIds': [id],
          'method': 'APP',
        },
      );

      final latest = await fetchById(id);
      if (latest != null) {
        _cache = _cache
            .map((order) => order.id == id ? latest : order)
            .toList();
      }
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> requestDelivery(String id) async {
    try {
      await _openApiClient.call(
        AppApiOperations.chooseCargoFulfillment,
        pathParams: {'cargoId': id},
        data: {
          'fulfillmentType': 'HOME_DELIVERY',
          'deliveryAddress': 'Улаанбаатар',
          'deliveryPhone': '00000000',
        },
      );

      _cache = _cache
          .map(
            (order) => order.id == id
                ? order.copyWith(status: OrderStatus.transit)
                : order,
          )
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> updateStatus(String id, OrderStatus status) async {
    try {
      final operation = _statusUpdateOperation(status);
      await _openApiClient.call(operation, pathParams: {'cargoId': id});

      final latest = await fetchById(id);
      if (latest != null) {
        _cache = _cache
            .map((order) => order.id == id ? latest : order)
            .toList();
      }
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  Future<List<Order>> _fetchAllOrders({
    Map<String, dynamic>? query,
    bool search = false,
  }) async {
    final orders = <Order>[];
    var page = 1;

    while (true) {
      final response = await _openApiClient.call(
        search ? AppApiOperations.searchCargos : AppApiOperations.listCargos,
        query: {...?query, 'page': page, 'limit': _pageSize},
      );

      final body = asJsonMap(response.data, context: 'cargo list response');
      final items = asJsonMapList(body['data'], context: 'cargo list data');
      orders.addAll(items.map(_mapCargoToOrder));

      final meta = asPaginationMeta(body['meta'], context: 'cargo list meta');
      if (meta == null || page >= meta.totalPages) {
        break;
      }

      page += 1;
    }

    return orders;
  }

  Order _mapCargoToOrder(Map<String, dynamic> json) {
    final id = ((json['id'] as String?) ?? '').trim();
    final tracking = ((json['trackingNumber'] as String?) ?? '').trim();
    final description = ((json['description'] as String?) ?? '').trim();
    final statusRaw = ((json['status'] as String?) ?? '').trim();
    final paymentStatusRaw = ((json['paymentStatus'] as String?) ?? '').trim();
    final receivedImage = ((json['receivedImageUrl'] as String?) ?? '').trim();
    final customer = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : null;

    final weightGrams = _toDouble(json['weightGrams']);
    final totalFeeMnt = _toDouble(json['totalFeeMnt']);
    final createdAt = _toDateTime(json['createdAt']) ?? DateTime.now();
    final estimatedDelivery = _toDateTime(json['estimatedDeliveryAt']);
    final deliveredAt = _toDateTime(json['completedAt']);

    return Order(
      id: id.isEmpty ? tracking : id,
      trackingCode: tracking.isEmpty ? 'UNKNOWN' : tracking,
      productName: description.isEmpty ? 'Cargo $tracking' : description,
      status: _mapOrderStatus(statusRaw),
      createdAt: createdAt,
      price: totalFeeMnt,
      weight: weightGrams <= 0 ? 0 : (weightGrams / 1000),
      deliveryAddress: (json['deliveryAddress'] as String?)?.trim(),
      estimatedDelivery: estimatedDelivery,
      deliveredAt: deliveredAt,
      imageUrl: receivedImage.isEmpty ? null : receivedImage,
      isPaid: paymentStatusRaw == 'PAID',
      customerName: (customer?['name'] as String?)?.trim(),
      customerEmail: (customer?['email'] as String?)?.trim(),
    );
  }

  OrderStatus _mapOrderStatus(String raw) {
    switch (raw) {
      case 'CREATED':
        return OrderStatus.pending;
      case 'RECEIVED_CHINA':
      case 'ARRIVED_MN':
      case 'AWAITING_FULFILLMENT_CHOICE':
      case 'READY_FOR_PICKUP':
        return OrderStatus.processing;
      case 'IN_TRANSIT_TO_MN':
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.transit;
      case 'COMPLETED_PICKUP':
      case 'COMPLETED_DELIVERY':
        return OrderStatus.delivered;
      default:
        return OrderStatus.processing;
    }
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

  DateTime? _toDateTime(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  List<String> _mapApiStatuses(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const ['CREATED'];
      case OrderStatus.processing:
        return const [
          'RECEIVED_CHINA',
          'ARRIVED_MN',
          'AWAITING_FULFILLMENT_CHOICE',
          'READY_FOR_PICKUP',
        ];
      case OrderStatus.transit:
        return const ['IN_TRANSIT_TO_MN', 'OUT_FOR_DELIVERY'];
      case OrderStatus.delivered:
        return const ['COMPLETED_PICKUP', 'COMPLETED_DELIVERY'];
      case OrderStatus.cancelled:
        return const [];
    }
  }

  String _statusUpdateOperation(OrderStatus status) {
    switch (status) {
      case OrderStatus.transit:
        return AppApiOperations.shipCargo;
      case OrderStatus.delivered:
        return AppApiOperations.arriveCargo;
      case OrderStatus.pending:
      case OrderStatus.processing:
      case OrderStatus.cancelled:
        throw Exception(
          'Admin API supports status updates only for transit and delivered.',
        );
    }
  }
}
