import 'package:core/features/orders/models/order.dart';

/// Order repository contract
abstract interface class OrderRepository {
  Future<List<Order>> fetchAll();
  Future<Order?> fetchById(String id);
  Future<List<Order>> fetchByStatus(OrderStatus status);
  Future<List<Order>> search(String query);
  Future<void> delete(String id);
  Future<void> markAsPaid(String id);
  Future<void> requestDelivery(String id);
}
