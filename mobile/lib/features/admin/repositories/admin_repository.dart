import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/auth/models/user.dart';

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
}
