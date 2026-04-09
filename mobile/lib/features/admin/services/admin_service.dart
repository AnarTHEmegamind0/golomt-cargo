import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/features/admin/models/admin_activity_log.dart';
import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/models/finance_summary.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/admin/repositories/admin_repository.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/branch/models/branch.dart';

/// Admin service for user and cargo management operations
class AdminService {
  AdminService({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  // User management
  Future<List<AdminUser>> listUsers({
    int? limit,
    int? offset,
    String? searchField,
    String? searchValue,
  }) {
    return _repository.listUsers(
      limit: limit,
      offset: offset,
      searchField: searchField,
      searchValue: searchValue,
    );
  }

  Future<AdminUser> getUser(String userId) {
    return _repository.getUser(userId);
  }

  Future<AdminUser> createUser({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.customer,
  }) {
    return _repository.createUser(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }

  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
  }) {
    return _repository.updateUser(userId: userId, name: name, email: email);
  }

  Future<void> setRole({required String userId, required UserRole role}) {
    return _repository.setRole(userId: userId, role: role);
  }

  Future<void> banUser({
    required String userId,
    String? reason,
    DateTime? expiresAt,
  }) {
    return _repository.banUser(
      userId: userId,
      reason: reason,
      expiresAt: expiresAt,
    );
  }

  Future<void> unbanUser(String userId) {
    return _repository.unbanUser(userId);
  }

  // Cargo management
  Future<void> receiveCargo({required String cargoId, String? imagePath}) {
    return _repository.receiveCargo(cargoId: cargoId, imagePath: imagePath);
  }

  Future<void> recordCargoWeight({
    required String cargoId,
    required int weightGrams,
    required int baseShippingFeeMnt,
  }) {
    return _repository.recordCargoWeight(
      cargoId: cargoId,
      weightGrams: weightGrams,
      baseShippingFeeMnt: baseShippingFeeMnt,
    );
  }

  Future<void> shipCargo(String cargoId) {
    return _repository.shipCargo(cargoId);
  }

  Future<void> arriveCargo(String cargoId) {
    return _repository.arriveCargo(cargoId);
  }

  Future<void> recordCargoDimensions({
    required String cargoId,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? calculatedFeeMnt,
    int? overrideFeeMnt,
  }) {
    return _repository.recordCargoDimensions(
      cargoId: cargoId,
      heightCm: heightCm,
      widthCm: widthCm,
      lengthCm: lengthCm,
      isFragile: isFragile,
      calculatedFeeMnt: calculatedFeeMnt,
      overrideFeeMnt: overrideFeeMnt,
    );
  }

  Future<List<CargoModel>> importTrackCodes(List<String> trackCodes) {
    return _repository.importTrackCodes(trackCodes);
  }

  // Vehicle management
  Future<List<Vehicle>> listVehicles() {
    return _repository.listVehicles();
  }

  Future<Vehicle> createVehicle({
    required String plateNumber,
    required String name,
    required VehicleType type,
  }) {
    return _repository.createVehicle(
      plateNumber: plateNumber,
      name: name,
      type: type,
    );
  }

  Future<Vehicle> updateVehicle({
    required String vehicleId,
    String? plateNumber,
    String? name,
    VehicleType? type,
    bool? isActive,
  }) {
    return _repository.updateVehicle(
      vehicleId: vehicleId,
      plateNumber: plateNumber,
      name: name,
      type: type,
      isActive: isActive,
    );
  }

  Future<void> deleteVehicle(String vehicleId) {
    return _repository.deleteVehicle(vehicleId);
  }

  // Shipment management
  Future<List<Shipment>> listShipments({ShipmentStatus? status}) {
    return _repository.listShipments(status: status);
  }

  Future<Shipment> getShipment(String shipmentId) {
    return _repository.getShipment(shipmentId);
  }

  Future<Shipment> createShipment({
    required String vehicleId,
    DateTime? departureDate,
    String? note,
  }) {
    return _repository.createShipment(
      vehicleId: vehicleId,
      departureDate: departureDate,
      note: note,
    );
  }

  Future<void> addCargosToShipment({
    required String shipmentId,
    required List<String> cargoIds,
  }) {
    return _repository.addCargosToShipment(
      shipmentId: shipmentId,
      cargoIds: cargoIds,
    );
  }

  Future<void> removeCargosFromShipment({
    required String shipmentId,
    required List<String> cargoIds,
  }) {
    return _repository.removeCargosFromShipment(
      shipmentId: shipmentId,
      cargoIds: cargoIds,
    );
  }

  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
  }) {
    return _repository.updateShipmentStatus(
      shipmentId: shipmentId,
      status: status,
    );
  }

  // Activity logs
  Future<List<AdminActivityLog>> listActivityLogs({
    int? limit,
    int? offset,
    String? action,
    String? targetType,
  }) {
    return _repository.listActivityLogs(
      limit: limit,
      offset: offset,
      action: action,
      targetType: targetType,
    );
  }

  // Finance
  Future<FinanceSummary> getFinanceSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getFinanceSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Branch management
  Future<List<Branch>> listBranches() {
    return _repository.listBranches();
  }

  Future<Branch> createBranch({
    required String name,
    required String code,
    required String address,
    String? phone,
    String? chinaAddress,
  }) {
    return _repository.createBranch(
      name: name,
      code: code,
      address: address,
      phone: phone,
      chinaAddress: chinaAddress,
    );
  }

  Future<Branch> updateBranch({
    required String branchId,
    String? name,
    String? code,
    String? address,
    String? phone,
    String? chinaAddress,
    bool? isActive,
  }) {
    return _repository.updateBranch(
      branchId: branchId,
      name: name,
      code: code,
      address: address,
      phone: phone,
      chinaAddress: chinaAddress,
      isActive: isActive,
    );
  }

  Future<void> deleteBranch(String branchId) {
    return _repository.deleteBranch(branchId);
  }

  // Exports
  Future<DownloadedFile> exportShipmentPdf(String shipmentId) {
    return _repository.exportShipmentPdf(shipmentId);
  }

  Future<DownloadedFile> exportShipmentXlsx(String shipmentId) {
    return _repository.exportShipmentXlsx(shipmentId);
  }

  Future<DownloadedFile> exportAdminLogsXlsx() {
    return _repository.exportAdminLogsXlsx();
  }
}
