import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/repositories/order_repository.dart';

/// Order service handles business logic
class OrderService {
  OrderService({required OrderRepository repository})
    : _repository = repository;

  final OrderRepository _repository;

  Future<Order> createOrder({
    required String trackingCode,
    String? productName,
  }) => _repository.createOrder(
    trackingCode: trackingCode,
    productName: productName,
  );
  Future<List<Order>> fetchAll() => _repository.fetchAll();
  Future<Order?> fetchById(String id) => _repository.fetchById(id);
  Future<List<Order>> fetchByStatus(OrderStatus status) =>
      _repository.fetchByStatus(status);
  Future<List<Order>> search(String query) => _repository.search(query);
  Future<void> delete(String id) => _repository.delete(id);
  Future<void> markAsPaid(String id) => _repository.markAsPaid(id);
  Future<void> requestDelivery(String id) => _repository.requestDelivery(id);
  Future<void> updateStatus(String id, OrderStatus status) =>
      _repository.updateStatus(id, status);
}
