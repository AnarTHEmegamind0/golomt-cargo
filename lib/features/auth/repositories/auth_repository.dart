import 'package:core/features/auth/models/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<User?> getSessionUser();
  Future<User> getAccountInfo();
  Future<void> changeEmail({required String newEmail, String? callbackURL});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions,
  });
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  });
  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  });
  Future<void> logout();
}
