import 'package:core/features/admin/services/admin_service.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/services/order_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for admin cargo management with status flow
class AdminCargosProvider extends ChangeNotifier {
  AdminCargosProvider({
    required AdminService adminService,
    required OrderService orderService,
  }) : _adminService = adminService,
       _orderService = orderService;

  final AdminService _adminService;
  final OrderService _orderService;

  bool _isLoading = false;
  String? _error;
  List<Order> _cargos = [];
  String? _processingCargoId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Order> get cargos => _cargos;
  String? get processingCargoId => _processingCargoId;

  // Filter getters
  List<Order> get pendingCargos =>
      _cargos.where((c) => c.status == OrderStatus.pending).toList();

  List<Order> get processingCargos =>
      _cargos.where((c) => c.status == OrderStatus.processing).toList();

  List<Order> get transitCargos =>
      _cargos.where((c) => c.status == OrderStatus.transit).toList();

  List<Order> get deliveredCargos =>
      _cargos.where((c) => c.status == OrderStatus.delivered).toList();

  Future<void> loadCargos({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_cargos.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cargos = await _orderService.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCargos(String query) async {
    if (query.isEmpty) {
      await loadCargos(forceRefresh: true);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cargos = await _orderService.search(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark cargo as received (pending -> processing)
  Future<bool> receiveCargo(String cargoId, {String? imageBase64}) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.receiveCargo(
        cargoId: cargoId,
        imageBase64: imageBase64,
      );
      _updateCargoStatus(cargoId, OrderStatus.processing);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  /// Record weight for cargo
  Future<bool> recordWeight(
    String cargoId,
    int weightGrams,
    int baseShippingFeeMnt,
  ) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.recordCargoWeight(
        cargoId: cargoId,
        weightGrams: weightGrams,
        baseShippingFeeMnt: baseShippingFeeMnt,
      );
      // Update local weight if Order model has weight field
      final index = _cargos.indexWhere((c) => c.id == cargoId);
      if (index != -1) {
        _cargos[index] = _cargos[index].copyWith(weight: weightGrams / 1000.0);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  /// Ship cargo (processing -> transit)
  Future<bool> shipCargo(String cargoId) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.shipCargo(cargoId);
      _updateCargoStatus(cargoId, OrderStatus.transit);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  /// Arrive cargo (transit -> delivered)
  Future<bool> arriveCargo(String cargoId) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.arriveCargo(cargoId);
      _updateCargoStatus(cargoId, OrderStatus.delivered);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  void _updateCargoStatus(String cargoId, OrderStatus newStatus) {
    final index = _cargos.indexWhere((c) => c.id == cargoId);
    if (index != -1) {
      _cargos[index] = _cargos[index].copyWith(status: newStatus);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
