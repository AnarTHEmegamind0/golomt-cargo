import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/repositories/order_repository.dart';

/// Fake implementation of OrderRepository for development
class FakeOrderRepository implements OrderRepository {
  final List<Order> _orders = [
    Order(
      id: 'ord-001',
      trackingCode: 'BD2024031501',
      productName: 'iPhone 15 Pro Max',
      status: OrderStatus.transit,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      price: 4500000,
      weight: 0.5,
      deliveryAddress: 'Улаанбаатар, Баянзүрх дүүрэг',
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      isPaid: true,
    ),
    Order(
      id: 'ord-002',
      trackingCode: 'BD2024031502',
      productName: 'MacBook Air M3',
      status: OrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      price: 5200000,
      weight: 1.8,
      deliveryAddress: 'Улаанбаатар, Сүхбаатар дүүрэг',
      isPaid: false,
    ),
    Order(
      id: 'ord-003',
      trackingCode: 'BD2024031503',
      productName: 'Nike Air Max 270',
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      price: 450000,
      weight: 0.8,
      isPaid: false,
    ),
    Order(
      id: 'ord-004',
      trackingCode: 'BD2024031504',
      productName: 'Samsung Galaxy Watch 6',
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      price: 850000,
      weight: 0.3,
      deliveryAddress: 'Улаанбаатар, Хан-Уул дүүрэг',
      deliveredAt: DateTime.now().subtract(const Duration(days: 2)),
      isPaid: true,
    ),
    Order(
      id: 'ord-005',
      trackingCode: 'BD2024031505',
      productName: 'Sony WH-1000XM5',
      status: OrderStatus.transit,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      price: 1200000,
      weight: 0.4,
      deliveryAddress: 'Дархан-Уул аймаг',
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      isPaid: true,
    ),
    Order(
      id: 'ord-006',
      trackingCode: 'BD2024031506',
      productName: 'Dyson V15 Detect',
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      price: 2800000,
      weight: 3.5,
      isPaid: false,
    ),
    Order(
      id: 'ord-007',
      trackingCode: 'BD2024031507',
      productName: 'Nintendo Switch OLED',
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      price: 1100000,
      weight: 0.9,
      isPaid: false,
    ),
    Order(
      id: 'ord-008',
      trackingCode: 'BD2024031508',
      productName: 'Apple Watch Ultra 2',
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      price: 3200000,
      weight: 0.2,
      deliveryAddress: 'Эрдэнэт хот',
      deliveredAt: DateTime.now().subtract(const Duration(days: 12)),
      isPaid: true,
    ),
  ];

  @override
  Future<List<Order>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_orders);
  }

  @override
  Future<Order?> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Order>> fetchByStatus(OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.status == status).toList();
  }

  @override
  Future<List<Order>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _orders.where((o) {
      return o.trackingCode.toLowerCase().contains(q) ||
          o.productName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<void> markAsPaid(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(isPaid: true);
    }
  }

  @override
  Future<void> requestDelivery(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.transit);
    }
  }
}
