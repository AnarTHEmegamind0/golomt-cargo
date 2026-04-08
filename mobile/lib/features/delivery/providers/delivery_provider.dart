import 'package:core/features/delivery/models/delivery_candidate.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/services/delivery_service.dart';
import 'package:flutter/foundation.dart';

class DeliveryProvider extends ChangeNotifier {
  DeliveryProvider({
    required DeliveryService service,
    String? Function()? customerIdResolver,
  }) : _service = service,
       _customerIdResolver = customerIdResolver;

  final DeliveryService _service;
  final String? Function()? _customerIdResolver;

  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  List<DeliveryOrder> _orders = const [];
  List<DeliveryCandidate> _eligibleCargos = const [];
  bool _isSubmittingDelivery = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;
  List<DeliveryOrder> get orders => _orders;
  List<DeliveryCandidate> get eligibleCargos => _eligibleCargos;
  bool get isSubmittingDelivery => _isSubmittingDelivery;

  double get todayEarnings {
    return _orders
        .where((order) => order.step == DeliveryStep.completed)
        .fold(0, (sum, order) => sum + order.earnings);
  }

  int get completedCount {
    return _orders
        .where((order) => order.step == DeliveryStep.completed)
        .length;
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.fetchActiveOrders(
        customerId: _resolveCustomerId(),
      );
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEligibleCargos() async {
    _error = null;
    notifyListeners();

    try {
      _eligibleCargos = await _service.fetchEligibleCargos(
        customerId: _resolveCustomerId(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createDeliveryRequest({
    required String cargoId,
    required String deliveryAddress,
    String? deliveryPhone,
  }) async {
    _isSubmittingDelivery = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createDeliveryRequest(
        cargoId: cargoId,
        deliveryAddress: deliveryAddress,
        deliveryPhone: deliveryPhone,
      );
      await load(forceRefresh: true);
      await loadEligibleCargos();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmittingDelivery = false;
      notifyListeners();
    }
  }

  DeliveryOrder? findById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<void> acceptOrder(String orderId) async {
    await _service.acceptOrder(orderId);
    await load(forceRefresh: true);
  }

  Future<void> advanceStep(DeliveryOrder order) async {
    await _service.advanceOrderStep(order);
    await load(forceRefresh: true);
  }

  Future<void> attachProof({
    required String orderId,
    required String proofPath,
  }) async {
    await _service.uploadProof(orderId: orderId, localPath: proofPath);
    await load(forceRefresh: true);
  }

  String? _resolveCustomerId() {
    final userId = _customerIdResolver?.call()?.trim();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }
}
