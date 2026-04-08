import 'package:core/features/delivery/models/delivery_candidate.dart';
import 'package:core/features/delivery/models/delivery_order.dart';

abstract interface class DeliveryRepository {
  Future<List<DeliveryOrder>> fetchActiveOrders({String? customerId});
  Future<List<DeliveryCandidate>> fetchEligibleCargos({String? customerId});
  Future<void> createDeliveryRequest({
    required String cargoId,
    required String deliveryAddress,
    String? deliveryPhone,
  });
  Future<void> updateOrderStep({
    required String orderId,
    required DeliveryStep step,
  });
  Future<void> uploadProof({
    required String orderId,
    required String localPath,
  });
}
