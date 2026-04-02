import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/repositories/admin_repository.dart';
import 'package:core/features/auth/models/user.dart';

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
  Future<void> receiveCargo({required String cargoId, String? imageBase64}) {
    return _repository.receiveCargo(cargoId: cargoId, imageBase64: imageBase64);
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
}
