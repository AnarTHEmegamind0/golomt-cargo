import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/services/delivery_service.dart';
import 'package:flutter/foundation.dart';

class DeliveryProvider extends ChangeNotifier {
  DeliveryProvider({required DeliveryService service}) : _service = service;

  final DeliveryService _service;

  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  List<DeliveryOrder> _orders = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;
  List<DeliveryOrder> get orders => _orders;

  double get todayEarnings {
    return _orders
        .where((order) => order.step == DeliveryStep.completed)
        .fold(0, (sum, order) => sum + order.earnings);
  }

  int get completedCount {
    return _orders.where((order) => order.step == DeliveryStep.completed).length;
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.fetchActiveOrders();
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
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
}
