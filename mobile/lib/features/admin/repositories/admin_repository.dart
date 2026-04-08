import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/admin/models/admin_activity_log.dart';
import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/models/finance_summary.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/branch/models/branch.dart';

/// Admin repository contract for user and cargo management
abstract interface class AdminRepository {
  // User management
  Future<List<AdminUser>> listUsers({
    int? limit,
    int? offset,
    String? searchField,
    String? searchValue,
  });

  Future<AdminUser> getUser(String userId);

  Future<AdminUser> createUser({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.customer,
  });

  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
  });

  Future<void> setRole({required String userId, required UserRole role});

  Future<void> banUser({
    required String userId,
    String? reason,
    DateTime? expiresAt,
  });

  Future<void> unbanUser(String userId);

  // Cargo management
  Future<void> receiveCargo({required String cargoId, String? imagePath});

  Future<void> recordCargoWeight({
    required String cargoId,
    required int weightGrams,
    required int baseShippingFeeMnt,
  });

  Future<void> shipCargo(String cargoId);

  Future<void> arriveCargo(String cargoId);

  Future<void> recordCargoDimensions({
    required String cargoId,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? calculatedFeeMnt,
    int? overrideFeeMnt,
  });

  Future<List<CargoModel>> importTrackCodes(List<String> trackCodes);

  // Vehicle management
  Future<List<Vehicle>> listVehicles();

  Future<Vehicle> createVehicle({
    required String plateNumber,
    required String name,
    required VehicleType type,
  });

  Future<Vehicle> updateVehicle({
    required String vehicleId,
    String? plateNumber,
    String? name,
    VehicleType? type,
    bool? isActive,
  });

  Future<void> deleteVehicle(String vehicleId);

  // Shipment management
  Future<List<Shipment>> listShipments({ShipmentStatus? status});

  Future<Shipment> getShipment(String shipmentId);

  Future<Shipment> createShipment({
    required String vehicleId,
    DateTime? departureDate,
    String? note,
  });

  Future<void> addCargosToShipment({
    required String shipmentId,
    required List<String> cargoIds,
  });

  Future<void> removeCargosFromShipment({
    required String shipmentId,
    required List<String> cargoIds,
  });

  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
  });

  // Activity logs
  Future<List<AdminActivityLog>> listActivityLogs({
    int? limit,
    int? offset,
    String? action,
    String? targetType,
  });

  // Finance
  Future<FinanceSummary> getFinanceSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Branch management
  Future<Branch> createBranch({
    required String name,
    required String code,
    required String address,
    String? phone,
    String? chinaAddress,
  });

  Future<Branch> updateBranch({
    required String branchId,
    String? name,
    String? code,
    String? address,
    String? phone,
    String? chinaAddress,
    bool? isActive,
  });

  Future<void> deleteBranch(String branchId);
}
