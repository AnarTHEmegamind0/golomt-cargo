import 'package:core/features/delivery/models/delivery_candidate.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';

class DeliveryService {
  DeliveryService({required DeliveryRepository repository})
    : _repository = repository;

  final DeliveryRepository _repository;

  Future<List<DeliveryOrder>> fetchActiveOrders({String? customerId}) {
    return _repository.fetchActiveOrders(customerId: customerId);
  }

  Future<List<DeliveryCandidate>> fetchEligibleCargos({String? customerId}) {
    return _repository.fetchEligibleCargos(customerId: customerId);
  }

  Future<void> createDeliveryRequest({
    required String cargoId,
    required String deliveryAddress,
    String? deliveryPhone,
  }) {
    return _repository.createDeliveryRequest(
      cargoId: cargoId,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
    );
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

  Future<void> uploadProof({
    required String orderId,
    required String localPath,
  }) {
    return _repository.uploadProof(orderId: orderId, localPath: localPath);
  }
}
