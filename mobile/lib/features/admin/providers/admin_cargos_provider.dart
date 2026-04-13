import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/core/networking/repositories/cargo_api_repository.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for admin cargo management with status flow
class AdminCargosProvider extends ChangeNotifier {
  AdminCargosProvider({
    required AdminService adminService,
    required CargoApiRepository cargoApiRepository,
  }) : _adminService = adminService,
       _cargoApiRepository = cargoApiRepository;

  final AdminService _adminService;
  final CargoApiRepository _cargoApiRepository;

  bool _isLoading = false;
  String? _error;
  List<CargoModel> _cargos = [];
  String? _processingCargoId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CargoModel> get cargos => _cargos;
  String? get processingCargoId => _processingCargoId;

  // Filter getters
  List<CargoModel> get pendingCargos =>
      _cargos.where((c) => c.status == CargoStatus.created).toList();

  List<CargoModel> get processingCargos =>
      _cargos.where((c) => c.status == CargoStatus.receivedChina).toList();

  List<CargoModel> get transitCargos =>
      _cargos.where((c) => c.status == CargoStatus.inTransitToMn).toList();

  List<CargoModel> get deliveredCargos => _cargos.where((c) {
    return c.status == CargoStatus.arrivedMn ||
        c.status == CargoStatus.awaitingFulfillmentChoice ||
        c.status == CargoStatus.readyForPickup ||
        c.status == CargoStatus.outForDelivery ||
        c.status == CargoStatus.completedPickup ||
        c.status == CargoStatus.completedDelivery;
  }).toList();

  Future<void> loadCargos({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_cargos.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cargos = await _fetchAllCargos();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
      _cargos = await _fetchAllCargos(query: query);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark cargo as received (pending -> processing)
  Future<bool> receiveCargo(String cargoId, {String? imagePath}) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.receiveCargo(cargoId: cargoId, imagePath: imagePath);
      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  Future<bool> recordDimensions({
    required String cargoId,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? overrideFeeMnt,
  }) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.recordCargoDimensions(
        cargoId: cargoId,
        heightCm: heightCm,
        widthCm: widthCm,
        lengthCm: lengthCm,
        isFragile: isFragile,
        overrideFeeMnt: overrideFeeMnt,
      );
      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  /// Unified pricing - records weight and dimensions together
  Future<bool> recordPricing({
    required String cargoId,
    required int weightGrams,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? overrideFeeMnt,
  }) async {
    _processingCargoId = cargoId;
    _error = null;
    notifyListeners();

    try {
      // Record weight first (calculates base fee)
      final baseFee = ((weightGrams / 1000) * 2000).ceil().clamp(2000, 1 << 30);
      await _adminService.recordCargoWeight(
        cargoId: cargoId,
        weightGrams: weightGrams,
        baseShippingFeeMnt: baseFee,
      );

      // Then record dimensions (recalculates final fee)
      await _adminService.recordCargoDimensions(
        cargoId: cargoId,
        heightCm: heightCm,
        widthCm: widthCm,
        lengthCm: lengthCm,
        isFragile: isFragile,
        overrideFeeMnt: overrideFeeMnt,
      );

      await _reloadCargo(cargoId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingCargoId = null;
      notifyListeners();
    }
  }

  Future<List<CargoModel>> _fetchAllCargos({String? query}) async {
    final cargos = <CargoModel>[];
    var page = 1;
    var totalPages = 1;

    do {
      final result = query == null || query.isEmpty
          ? await _cargoApiRepository.getCargos(page: page, limit: 100)
          : await _cargoApiRepository.searchCargos(
              query: query,
              page: page,
              limit: 100,
            );

      if (!result.isSuccess || result.data == null) {
        throw Exception(result.error?.message ?? 'Failed to load cargos.');
      }

      cargos.addAll(result.data!.data);
      totalPages = result.data!.meta.totalPages;
      page++;
    } while (page <= totalPages);

    return cargos;
  }

  Future<void> _reloadCargo(String cargoId) async {
    final result = await _cargoApiRepository.getCargoById(cargoId);
    if (!result.isSuccess || result.data == null) {
      return;
    }

    final index = _cargos.indexWhere((c) => c.id == cargoId);
    if (index == -1) {
      _cargos = [result.data!.data, ..._cargos];
      return;
    }

    _cargos[index] = result.data!.data;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
