import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';

class DeliveryService {
  DeliveryService({required DeliveryRepository repository})
    : _repository = repository;

  final DeliveryRepository _repository;

  Future<List<DeliveryOrder>> fetchActiveOrders() {
    return _repository.fetchActiveOrders();
  }

  Future<void> acceptOrder(String orderId) {
    return _repository.updateOrderStep(
      orderId: orderId,
      step: DeliveryStep.accepted,
    );
  }

  Future<void> advanceOrderStep(DeliveryOrder order) {
    final nextStep = switch (order.step) {
      DeliveryStep.pending => DeliveryStep.accepted,
      DeliveryStep.accepted => DeliveryStep.pickedUp,
      DeliveryStep.pickedUp => DeliveryStep.enRoute,
      DeliveryStep.enRoute => DeliveryStep.arrived,
      DeliveryStep.arrived => DeliveryStep.proof,
      DeliveryStep.proof => DeliveryStep.completed,
      DeliveryStep.completed => DeliveryStep.completed,
    };

    return _repository.updateOrderStep(orderId: order.id, step: nextStep);
  }

  Future<void> uploadProof({required String orderId, required String localPath}) {
    return _repository.uploadProof(orderId: orderId, localPath: localPath);
  }
}
