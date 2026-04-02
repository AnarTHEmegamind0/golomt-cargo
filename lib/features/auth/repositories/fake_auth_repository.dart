import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  User _user = const User(
    id: 'user_1',
    email: 'demo@cargo.app',
    name: 'Demo',
    role: UserRole.customer,
  );

  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final role = email.toLowerCase().contains('admin')
        ? UserRole.admin
        : UserRole.customer;
    _user = User(id: 'user_1', email: email, role: role);
    return _user;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _user = User(
      id: 'user_new',
      email: email,
      name: name,
      role: UserRole.customer,
    );
    return _user;
  }

  @override
  Future<User?> getSessionUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _user;
  }

  @override
  Future<User> getAccountInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _user;
  }

  @override
  Future<void> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _user = User(
      id: _user.id,
      email: newEmail,
      name: _user.name,
      role: _user.role,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
