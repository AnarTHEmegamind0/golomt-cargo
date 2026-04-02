import 'package:core/features/delivery/models/delivery_order.dart';

abstract interface class DeliveryRepository {
  Future<List<DeliveryOrder>> fetchActiveOrders();
  Future<void> updateOrderStep({required String orderId, required DeliveryStep step});
  Future<void> uploadProof({required String orderId, required String localPath});
}
