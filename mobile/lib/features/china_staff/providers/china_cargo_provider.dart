import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:core/features/orders/services/order_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for China staff cargo management - track code import and receiving
class ChinaCargoProvider extends ChangeNotifier {
  ChinaCargoProvider({
    required AdminService adminService,
    required OrderService orderService,
  }) : _adminService = adminService,
       _orderService = orderService;

  final AdminService _adminService;
  final OrderService _orderService;

  List<CargoModel> _cargos = [];
  List<CargoModel> _importedCargos = [];
  bool _isLoading = false;
  bool _isImporting = false;
  String? _error;
  String? _processingCargoId;
  String _searchQuery = '';

  List<CargoModel> get cargos => _cargos;
  List<CargoModel> get importedCargos => _importedCargos;
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  String? get error => _error;
  String? get processingCargoId => _processingCargoId;

  /// Filter cargos that have been received in China
  List<CargoModel> get receivedCargos =>
      _cargos.where((c) => c.status == CargoStatus.receivedChina).toList();

  /// Filter cargos ready for shipment (received with weight recorded)
  List<CargoModel> get readyForShipmentCargos =>
      _cargos.where((c) =>
        c.status == CargoStatus.receivedChina &&
        c.weightGrams != null &&
        c.shipmentId == null
      ).toList();

  /// Get cargos by status
  List<CargoModel> getByStatus(CargoStatus status) =>
      _cargos.where((c) => c.status == status).toList();

  /// Get cargos not assigned to any shipment
  List<CargoModel> get unassignedCargos =>
      _cargos.where((c) =>
        c.shipmentId == null &&
        (c.status == CargoStatus.receivedChina || c.status == CargoStatus.created)
      ).toList();

  /// Search filtered cargos
  List<CargoModel> get filteredCargos {
    if (_searchQuery.isEmpty) return _cargos;
    final query = _searchQuery.toLowerCase();
    return _cargos.where((c) =>
      c.trackingNumber.toLowerCase().contains(query) ||
      (c.customer?.name.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load all cargos
  Future<void> loadCargos({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_cargos.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orders = await _orderService.fetchAll();
      _cargos = orders.map((o) => CargoModel(
        id: o.id,
        trackingNumber: o.trackingCode,
        status: _mapOrderStatusToCargoStatus(o.status.name),
        paymentStatus: PaymentStatus.unpaid,
        weightGrams: o.weight > 0 ? (o.weight * 1000).toInt() : null,
        shipmentId: null,
      )).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CargoStatus _mapOrderStatusToCargoStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return CargoStatus.created;
      case 'processing':
        return CargoStatus.receivedChina;
      case 'transit':
        return CargoStatus.inTransitToMn;
      case 'delivered':
        return CargoStatus.arrivedMn;
      default:
        return CargoStatus.created;
    }
  }

  /// Import track codes - creates cargos from list of tracking numbers
  Future<ImportResult> importTrackCodes(List<String> trackCodes) async {
    if (trackCodes.isEmpty) {
      return ImportResult(success: 0, failed: 0, errors: ['Track code жагсаалт хоосон байна']);
    }

    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      final importedCargos = await _adminService.importTrackCodes(trackCodes);
      _importedCargos = importedCargos;

      // Add to main cargos list
      for (final cargo in importedCargos) {
        if (!_cargos.any((c) => c.id == cargo.id)) {
          _cargos.insert(0, cargo);
        }
      }

      return ImportResult(
        success: importedCargos.length,
        failed: trackCodes.length - importedCargos.length,
        errors: [],
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return ImportResult(success: 0, failed: trackCodes.length, errors: [_error!]);
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  /// Parse track codes from text (one per line or comma separated)
  List<String> parseTrackCodes(String text) {
    if (text.trim().isEmpty) return [];

    // Split by newlines or commas
    final lines = text
        .split(RegExp(r'[\n,]'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines;
  }

  /// Receive cargo at China warehouse
  Future<bool> receiveCargo(String cargoId, {String? imagePath}) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.receiveCargo(cargoId: cargoId, imagePath: imagePath);
      _updateCargoStatus(cargoId, CargoStatus.receivedChina);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  /// Record cargo weight and dimensions
  Future<bool> recordWeightAndDimensions({
    required String cargoId,
    required int weightGrams,
    int? heightCm,
    int? widthCm,
    int? lengthCm,
    bool isFragile = false,
  }) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      // Calculate base fee (2000 MNT per kg)
      final baseFeeMnt = (weightGrams / 1000 * 2000).round();

      await _adminService.recordCargoWeight(
        cargoId: cargoId,
        weightGrams: weightGrams,
        baseShippingFeeMnt: baseFeeMnt,
      );

      if (heightCm != null && widthCm != null && lengthCm != null) {
        await _adminService.recordCargoDimensions(
          cargoId: cargoId,
          heightCm: heightCm,
          widthCm: widthCm,
          lengthCm: lengthCm,
          isFragile: isFragile,
        );
      }

      // Update local state
      final index = _cargos.indexWhere((c) => c.id == cargoId);
      if (index != -1) {
        _cargos[index] = _cargos[index].copyWith(
          weightGrams: weightGrams,
          heightCm: heightCm,
          widthCm: widthCm,
          lengthCm: lengthCm,
          isFragile: isFragile,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  void _updateCargoStatus(String cargoId, CargoStatus newStatus) {
    final index = _cargos.indexWhere((c) => c.id == cargoId);
    if (index != -1) {
      _cargos[index] = _cargos[index].copyWith(status: newStatus);
    }
  }

  /// Update cargo shipment assignment locally
  void assignCargoToShipment(String cargoId, String shipmentId) {
    final index = _cargos.indexWhere((c) => c.id == cargoId);
    if (index != -1) {
      _cargos[index] = _cargos[index].copyWith(shipmentId: shipmentId);
      notifyListeners();
    }
  }

  /// Remove cargo from shipment locally
  void unassignCargoFromShipment(String cargoId) {
    final index = _cargos.indexWhere((c) => c.id == cargoId);
    if (index != -1) {
      _cargos[index] = CargoModel(
        id: _cargos[index].id,
        trackingNumber: _cargos[index].trackingNumber,
        status: _cargos[index].status,
        paymentStatus: _cargos[index].paymentStatus,
        weightGrams: _cargos[index].weightGrams,
        heightCm: _cargos[index].heightCm,
        widthCm: _cargos[index].widthCm,
        lengthCm: _cargos[index].lengthCm,
        isFragile: _cargos[index].isFragile,
        customer: _cargos[index].customer,
        shipmentId: null,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearImportedCargos() {
    _importedCargos = [];
    notifyListeners();
  }
}

/// Result of track code import operation
class ImportResult {
  const ImportResult({
    required this.success,
    required this.failed,
    required this.errors,
  });

  final int success;
  final int failed;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty || failed > 0;
}
