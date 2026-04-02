import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class AuthService {
  AuthService({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<User> login({required String email, required String password}) {
    return _authRepository.login(email: email, password: password);
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _authRepository.signUp(email: email, password: password, name: name);
  }

  Future<User?> getSessionUser() => _authRepository.getSessionUser();

  Future<User> getAccountInfo() => _authRepository.getAccountInfo();

  Future<void> changeEmail({required String newEmail, String? callbackURL}) {
    return _authRepository.changeEmail(
      newEmail: newEmail,
      callbackURL: callbackURL,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) {
    return _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      revokeOtherSessions: revokeOtherSessions,
    );
  }

  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) {
    return _authRepository.requestPasswordReset(
      email: email,
      redirectTo: redirectTo,
    );
  }

  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) {
    return _authRepository.sendVerificationEmail(
      email: email,
      callbackURL: callbackURL,
    );
  }

  Future<void> logout() => _authRepository.logout();
}
