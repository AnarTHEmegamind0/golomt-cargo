import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/admin/models/admin_activity_log.dart';
import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/models/finance_summary.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/admin/repositories/admin_repository.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;

  @override
  Future<List<AdminUser>> listUsers({
    int? limit,
    int? offset,
    String? searchField,
    String? searchValue,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (searchField != null) queryParams['searchField'] = searchField;
      if (searchValue != null) queryParams['searchValue'] = searchValue;

      final response = await _openApiClient.call(
        AppApiOperations.adminListUsers,
        query: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = asJsonMap(response.data, context: 'admin list-users');
      final usersRaw = body['users'] as List<dynamic>? ?? [];

      return usersRaw
          .whereType<Map<String, dynamic>>()
          .map(AdminUser.fromJson)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<AdminUser> getUser(String userId) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminGetUser,
        query: {'userId': userId},
      );

      final body = asJsonMap(response.data, context: 'admin get-user');
      final userRaw = body['user'] as Map<String, dynamic>? ?? body;

      return AdminUser.fromJson(userRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<AdminUser> createUser({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminCreateUser,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role.name,
        },
      );

      final body = asJsonMap(response.data, context: 'admin create-user');
      final userRaw = body['user'] as Map<String, dynamic>? ?? body;

      return AdminUser.fromJson(userRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminUpdateUser,
        data: {
          'userId': userId,
          if (name != null) 'name': name,
          if (email != null) 'email': email,
        },
      );

      final body = asJsonMap(response.data, context: 'admin update-user');
      final userRaw = body['user'] as Map<String, dynamic>? ?? body;

      return AdminUser.fromJson(userRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> setRole({required String userId, required UserRole role}) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminSetRole,
        data: {'userId': userId, 'role': role.name},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> banUser({
    required String userId,
    String? reason,
    DateTime? expiresAt,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminBanUser,
        data: {
          'userId': userId,
          if (reason != null) 'banReason': reason,
          if (expiresAt != null)
            'banExpiresIn': expiresAt.millisecondsSinceEpoch,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> unbanUser(String userId) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminUnbanUser,
        data: {'userId': userId},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> receiveCargo({
    required String cargoId,
    String? imagePath,
  }) async {
    try {
      final data = imagePath == null
          ? <String, dynamic>{}
          : FormData.fromMap({
              'image': await MultipartFile.fromFile(imagePath),
            });
      await _openApiClient.call(
        AppApiOperations.receiveCargo,
        pathParams: {'cargoId': cargoId},
        data: data,
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> recordCargoWeight({
    required String cargoId,
    required int weightGrams,
    required int baseShippingFeeMnt,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.recordCargoWeight,
        pathParams: {'cargoId': cargoId},
        data: {
          'weightGrams': weightGrams,
          'baseShippingFeeMnt': baseShippingFeeMnt,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> shipCargo(String cargoId) async {
    try {
      await _openApiClient.call(
        AppApiOperations.shipCargo,
        pathParams: {'cargoId': cargoId},
        data: <String, dynamic>{},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> arriveCargo(String cargoId) async {
    try {
      await _openApiClient.call(
        AppApiOperations.arriveCargo,
        pathParams: {'cargoId': cargoId},
        data: <String, dynamic>{},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> recordCargoDimensions({
    required String cargoId,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? calculatedFeeMnt,
    int? overrideFeeMnt,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.recordCargoDimensions,
        pathParams: {'cargoId': cargoId},
        data: {
          'heightCm': heightCm,
          'widthCm': widthCm,
          'lengthCm': lengthCm,
          'isFragile': isFragile,
          if (calculatedFeeMnt != null) 'calculatedFeeMnt': calculatedFeeMnt,
          if (overrideFeeMnt != null) 'overrideFeeMnt': overrideFeeMnt,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<List<CargoModel>> importTrackCodes(List<String> trackCodes) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminImportTrackCodes,
        data: {'source_type': 'MANUAL', 'track_codes': trackCodes},
      );

      final body = asJsonMap(response.data, context: 'import track codes');
      final cargosRaw = body['data'] as List<dynamic>? ?? [];

      return cargosRaw
          .whereType<Map<String, dynamic>>()
          .map(CargoModel.fromJson)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  // Vehicle management
  @override
  Future<List<Vehicle>> listVehicles() async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminListVehicles,
      );

      final body = asJsonMap(response.data, context: 'list vehicles');
      final vehiclesRaw = body['data'] as List<dynamic>? ?? [];

      return vehiclesRaw
          .whereType<Map<String, dynamic>>()
          .map(Vehicle.fromJson)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Vehicle> createVehicle({
    required String plateNumber,
    required String name,
    required VehicleType type,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminCreateVehicle,
        data: {'plate_number': plateNumber, 'name': name, 'type': type.value},
      );

      final body = asJsonMap(response.data, context: 'create vehicle');
      final vehicleRaw = body['data'] as Map<String, dynamic>? ?? body;

      return Vehicle.fromJson(vehicleRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Vehicle> updateVehicle({
    required String vehicleId,
    String? plateNumber,
    String? name,
    VehicleType? type,
    bool? isActive,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminUpdateVehicle,
        pathParams: {'vehicleId': vehicleId},
        data: {
          if (plateNumber != null) 'plate_number': plateNumber,
          if (name != null) 'name': name,
          if (type != null) 'type': type.value,
          if (isActive != null) 'is_active': isActive,
        },
      );

      final body = asJsonMap(response.data, context: 'update vehicle');
      final vehicleRaw = body['data'] as Map<String, dynamic>? ?? body;

      return Vehicle.fromJson(vehicleRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminDeleteVehicle,
        pathParams: {'vehicleId': vehicleId},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  // Shipment management
  @override
  Future<List<Shipment>> listShipments({ShipmentStatus? status}) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminListShipments,
        query: status != null ? {'status': status.value} : null,
      );

      final body = asJsonMap(response.data, context: 'list shipments');
      final shipmentsRaw = body['data'] as List<dynamic>? ?? [];

      return shipmentsRaw
          .whereType<Map<String, dynamic>>()
          .map(Shipment.fromJson)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Shipment> getShipment(String shipmentId) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminGetShipment,
        pathParams: {'shipmentId': shipmentId},
      );

      final body = asJsonMap(response.data, context: 'get shipment');
      final shipmentRaw = body['data'] as Map<String, dynamic>? ?? body;

      return Shipment.fromJson(shipmentRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Shipment> createShipment({
    required String vehicleId,
    DateTime? departureDate,
    String? note,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminCreateShipment,
        data: {
          'vehicle_id': vehicleId,
          if (departureDate != null)
            'departure_date': departureDate.toIso8601String(),
          if (note != null) 'note': note,
        },
      );

      final body = asJsonMap(response.data, context: 'create shipment');
      final shipmentRaw = body['data'] as Map<String, dynamic>? ?? body;

      return Shipment.fromJson(shipmentRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> addCargosToShipment({
    required String shipmentId,
    required List<String> cargoIds,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminAddCargosToShipment,
        pathParams: {'shipmentId': shipmentId},
        data: {'cargo_ids': cargoIds},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> removeCargosFromShipment({
    required String shipmentId,
    required List<String> cargoIds,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminRemoveCargosFromShipment,
        pathParams: {'shipmentId': shipmentId},
        data: {'cargo_ids': cargoIds},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminUpdateShipmentStatus,
        pathParams: {'shipmentId': shipmentId},
        data: {'status': status.value},
      );

      final body = asJsonMap(response.data, context: 'update shipment status');
      final shipmentRaw = body['data'] as Map<String, dynamic>? ?? body;

      return Shipment.fromJson(shipmentRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  // Activity logs
  @override
  Future<List<AdminActivityLog>> listActivityLogs({
    int? limit,
    int? offset,
    String? action,
    String? targetType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (action != null) queryParams['action'] = action;
      if (targetType != null) queryParams['targetType'] = targetType;

      final response = await _openApiClient.call(
        AppApiOperations.adminListActivityLogs,
        query: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = asJsonMap(response.data, context: 'list activity logs');
      final logsRaw = body['data'] as List<dynamic>? ?? [];

      return logsRaw
          .whereType<Map<String, dynamic>>()
          .map(AdminActivityLog.fromJson)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  // Finance
  @override
  Future<FinanceSummary> getFinanceSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _openApiClient.call(
        AppApiOperations.adminFinanceSummary,
        query: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = asJsonMap(response.data, context: 'finance summary');
      final summaryRaw = body['data'] as Map<String, dynamic>? ?? body;

      return FinanceSummary.fromJson(summaryRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  // Branch management
  @override
  Future<List<Branch>> listBranches() async {
    try {
      final response = await _openApiClient.call(AppApiOperations.listBranches);
      final body = asJsonMap(response.data, context: 'list branches');
      final branchesRaw = body['data'] as List<dynamic>? ?? [];

      return branchesRaw
          .whereType<Map<String, dynamic>>()
          .map(_parseBranch)
          .toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Branch> createBranch({
    required String name,
    required String code,
    required String address,
    String? phone,
    String? chinaAddress,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminCreateBranch,
        data: {
          'name': name,
          'code': code,
          'address': address,
          if (phone != null) 'phone': phone,
          if (chinaAddress != null) 'chinaAddress': chinaAddress,
        },
      );

      final body = asJsonMap(response.data, context: 'create branch');
      final branchRaw = body['data'] as Map<String, dynamic>? ?? body;

      return _parseBranch(branchRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Branch> updateBranch({
    required String branchId,
    String? name,
    String? code,
    String? address,
    String? phone,
    String? chinaAddress,
    bool? isActive,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.adminUpdateBranch,
        pathParams: {'branchId': branchId},
        data: {
          if (name != null) 'name': name,
          if (code != null) 'code': code,
          if (address != null) 'address': address,
          if (phone != null) 'phone': phone,
          if (chinaAddress != null) 'chinaAddress': chinaAddress,
          if (isActive != null) 'isActive': isActive,
        },
      );

      final body = asJsonMap(response.data, context: 'update branch');
      final branchRaw = body['data'] as Map<String, dynamic>? ?? body;

      return _parseBranch(branchRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> deleteBranch(String branchId) async {
    try {
      await _openApiClient.call(
        AppApiOperations.adminDeleteBranch,
        pathParams: {'branchId': branchId},
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<DownloadedFile> exportShipmentPdf(String shipmentId) {
    return _openApiClient.downloadOperation(
      AppApiOperations.adminExportShipmentPdf,
      pathParams: {'shipmentId': shipmentId},
      fallbackFilename: 'shipment-$shipmentId.pdf',
    );
  }

  @override
  Future<DownloadedFile> exportShipmentXlsx(String shipmentId) {
    return _openApiClient.downloadOperation(
      AppApiOperations.adminExportShipmentXlsx,
      pathParams: {'shipmentId': shipmentId},
      fallbackFilename: 'shipment-$shipmentId.xlsx',
    );
  }

  @override
  Future<DownloadedFile> exportAdminLogsXlsx() {
    return _openApiClient.downloadOperation(
      AppApiOperations.adminExportActivityLogsXlsx,
      fallbackFilename: 'admin-logs.xlsx',
    );
  }

  Branch _parseBranch(Map<String, dynamic> json) {
    final code = _readString(json, 'code');
    return Branch(
      id: _readString(json, 'id').isEmpty ? code : _readString(json, 'id'),
      name: _readString(json, 'name').isEmpty
          ? 'Салбар'
          : _readString(json, 'name'),
      address: _readString(json, 'address').isEmpty
          ? 'Хаяг оруулаагүй'
          : _readString(json, 'address'),
      chinaAddress: _readString(json, 'chinaAddress', 'china_address').isEmpty
          ? 'Хятад дахь агуулахын хаяг мэдээлэл алга'
          : _readString(json, 'chinaAddress', 'china_address'),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 47.9184,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.9177,
      phone: _readString(json, 'phone').isEmpty
          ? 'Мэдээлэл алга'
          : _readString(json, 'phone'),
      workingHours: _readString(json, 'workingHours').isEmpty
          ? (_readBool(json, 'isActive', 'is_active')
                ? 'Өдөр бүр 09:00-18:00'
                : 'Хаалттай')
          : _readString(json, 'workingHours'),
      iconColor: Colors.blue,
      description:
          (json['description'] as String?) ??
          (code.isEmpty ? null : 'Код: $code'),
      imageUrl: json['imageUrl'] as String?,
      isActive: _readBool(json, 'isActive', 'is_active'),
    );
  }

  String _readString(
    Map<String, dynamic> json,
    String key, [
    String? fallbackKey,
  ]) {
    return ((json[key] ?? (fallbackKey == null ? null : json[fallbackKey]))
                as String? ??
            '')
        .trim();
  }

  bool _readBool(Map<String, dynamic> json, String key, [String? fallbackKey]) {
    return (json[key] ?? (fallbackKey == null ? null : json[fallbackKey])) ==
        true;
  }
}
