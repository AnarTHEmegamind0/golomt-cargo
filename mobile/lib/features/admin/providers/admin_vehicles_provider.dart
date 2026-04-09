import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for vehicle management
class AdminVehiclesProvider extends ChangeNotifier {
  AdminVehiclesProvider({required AdminService adminService})
    : _adminService = adminService;

  final AdminService _adminService;

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  String? _processingVehicleId;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get processingVehicleId => _processingVehicleId;

  /// Get active vehicles only
  List<Vehicle> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();

  /// Load all vehicles
  Future<void> loadVehicles({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_vehicles.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _adminService.listVehicles();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new vehicle
  Future<bool> createVehicle({
    required String plateNumber,
    required String name,
    required VehicleType type,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vehicle = await _adminService.createVehicle(
        plateNumber: plateNumber,
        name: name,
        type: type,
      );
      _vehicles = [vehicle, ..._vehicles];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a vehicle
  Future<bool> updateVehicle({
    required String vehicleId,
    String? plateNumber,
    String? name,
    VehicleType? type,
    bool? isActive,
  }) async {
    _processingVehicleId = vehicleId;
    _error = null;
    notifyListeners();

    try {
      final updated = await _adminService.updateVehicle(
        vehicleId: vehicleId,
        plateNumber: plateNumber,
        name: name,
        type: type,
        isActive: isActive,
      );

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles = List.from(_vehicles)..[index] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingVehicleId = null;
      notifyListeners();
    }
  }

  /// Toggle vehicle active status
  Future<bool> toggleActive(String vehicleId) async {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => throw Exception('Vehicle not found'),
    );

    return updateVehicle(vehicleId: vehicleId, isActive: !vehicle.isActive);
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    _processingVehicleId = vehicleId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteVehicle(vehicleId);
      _vehicles = _vehicles.where((v) => v.id != vehicleId).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingVehicleId = null;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
