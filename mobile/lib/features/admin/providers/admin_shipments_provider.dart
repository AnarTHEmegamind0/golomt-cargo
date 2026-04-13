import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/core/networking/repositories/cargo_api_repository.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for shipment management
class AdminShipmentsProvider extends ChangeNotifier {
  AdminShipmentsProvider({
    required AdminService adminService,
    required CargoApiRepository cargoApiRepository,
  }) : _adminService = adminService,
       _cargoApiRepository = cargoApiRepository;

  final AdminService _adminService;
  final CargoApiRepository _cargoApiRepository;

  List<Shipment> _shipments = [];
  Shipment? _selectedShipment;
  List<CargoModel> _shipmentCargos = [];
  bool _isLoading = false;
  bool _isLoadingCargos = false;
  String? _error;
  String? _processingShipmentId;
  ShipmentStatus? _statusFilter;

  List<Shipment> get shipments => _shipments;
  Shipment? get selectedShipment => _selectedShipment;
  List<CargoModel> get shipmentCargos => _shipmentCargos;
  bool get isLoading => _isLoading;
  bool get isLoadingCargos => _isLoadingCargos;
  String? get error => _error;
  String? get processingShipmentId => _processingShipmentId;
  ShipmentStatus? get statusFilter => _statusFilter;

  /// Get shipments filtered by status
  List<Shipment> get filteredShipments {
    if (_statusFilter == null) return _shipments;
    return _shipments.where((s) => s.status == _statusFilter).toList();
  }

  /// Get shipments by status
  List<Shipment> getByStatus(ShipmentStatus status) {
    return _shipments.where((s) => s.status == status).toList();
  }

  /// Set status filter
  void setStatusFilter(ShipmentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Load all shipments
  Future<void> loadShipments({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_shipments.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shipments = await _adminService.listShipments();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get shipment details
  Future<void> loadShipmentDetails(String shipmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedShipment = await _adminService.getShipment(shipmentId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new shipment
  Future<Shipment?> createShipment({
    required String vehicleId,
    DateTime? departureDate,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shipment = await _adminService.createShipment(
        vehicleId: vehicleId,
        departureDate: departureDate,
        note: note,
      );
      _shipments = [shipment, ..._shipments];
      return shipment;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add cargos to a shipment
  Future<bool> addCargos({
    required String shipmentId,
    required List<String> cargoIds,
  }) async {
    _processingShipmentId = shipmentId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.addCargosToShipment(
        shipmentId: shipmentId,
        cargoIds: cargoIds,
      );

      // Reload shipment details
      await loadShipmentDetails(shipmentId);
      // Also refresh the list
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1 && _selectedShipment != null) {
        _shipments = List.from(_shipments)..[index] = _selectedShipment!;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingShipmentId = null;
      notifyListeners();
    }
  }

  /// Remove cargos from a shipment
  Future<bool> removeCargos({
    required String shipmentId,
    required List<String> cargoIds,
  }) async {
    _processingShipmentId = shipmentId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.removeCargosFromShipment(
        shipmentId: shipmentId,
        cargoIds: cargoIds,
      );

      // Reload shipment details
      await loadShipmentDetails(shipmentId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingShipmentId = null;
      notifyListeners();
    }
  }

  /// Update shipment status
  Future<bool> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
  }) async {
    _processingShipmentId = shipmentId;
    _error = null;
    notifyListeners();

    try {
      final updated = await _adminService.updateShipmentStatus(
        shipmentId: shipmentId,
        status: status,
      );

      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        _shipments = List.from(_shipments)..[index] = updated;
      }
      if (_selectedShipment?.id == shipmentId) {
        _selectedShipment = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingShipmentId = null;
      notifyListeners();
    }
  }

  /// Clear selected shipment
  void clearSelection() {
    _selectedShipment = null;
    _shipmentCargos = [];
    notifyListeners();
  }

  /// Load cargos for a shipment
  Future<void> loadShipmentCargos(String shipmentId) async {
    _isLoadingCargos = true;
    _shipmentCargos = [];
    _error = null;
    notifyListeners();

    try {
      // First load shipment details to get cargo IDs
      final shipment = await _adminService.getShipment(shipmentId);
      _selectedShipment = shipment;

      // Load each cargo by ID
      final cargos = <CargoModel>[];
      for (final cargoId in shipment.cargoIds) {
        final result = await _cargoApiRepository.getCargoById(cargoId);
        if (result.isSuccess && result.data != null) {
          cargos.add(result.data!.data);
        }
      }
      _shipmentCargos = cargos;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCargos = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
