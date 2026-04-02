import 'package:flutter/foundation.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/services/order_service.dart';

/// Order state provider with filtering and search
class OrderProvider extends ChangeNotifier {
  OrderProvider({required OrderService service}) : _service = service;

  final OrderService _service;

  bool _isLoading = false;
  String? _error;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  OrderStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isGridView = false;
  bool _hasLoaded = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Order> get orders => _filteredOrders;
  OrderStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get isGridView => _isGridView;
  bool get hasLoaded => _hasLoaded;

  int get pendingCount =>
      _allOrders.where((o) => o.status == OrderStatus.pending).length;
  int get transitCount =>
      _allOrders.where((o) => o.status == OrderStatus.transit).length;
  int get deliveredCount =>
      _allOrders.where((o) => o.status == OrderStatus.delivered).length;

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setFilter(OrderStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Order>.from(_allOrders);

    // Apply status filter
    if (_selectedStatus != null) {
      result = result.where((o) => o.status == _selectedStatus).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((o) {
        return o.trackingCode.toLowerCase().contains(q) ||
            o.productName.toLowerCase().contains(q);
      }).toList();
    }

    _filteredOrders = result;
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOrders = await _service.fetchAll();
      _applyFilters();
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> createOrder({
    required String trackingCode,
    String? productName,
  }) async {
    _error = null;

    try {
      final order = await _service.createOrder(
        trackingCode: trackingCode,
        productName: productName,
      );
      _allOrders = [order, ..._allOrders];
      _applyFilters();
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _service.delete(id);
      _allOrders.removeWhere((o) => o.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsPaid(String id) async {
    try {
      await _service.markAsPaid(id);
      final refreshed = await _service.fetchById(id);
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1 && refreshed != null) {
        _allOrders[index] = refreshed;
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> requestDelivery(String id) async {
    try {
      await _service.requestDelivery(id);
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _allOrders[index] = _allOrders[index].copyWith(
          status: OrderStatus.transit,
        );
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    try {
      await _service.updateStatus(id, status);
      final refreshed = await _service.fetchById(id);
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1 && refreshed != null) {
        _allOrders[index] = refreshed;
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
