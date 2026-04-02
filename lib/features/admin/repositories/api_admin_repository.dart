import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/repositories/admin_repository.dart';
import 'package:core/features/auth/models/user.dart';

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
    String? imageBase64,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.receiveCargo,
        pathParams: {'cargoId': cargoId},
        data: {if (imageBase64 != null) 'image': imageBase64},
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
}
