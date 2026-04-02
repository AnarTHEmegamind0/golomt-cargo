import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getSessionUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAccountInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getAccountInfo();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changeEmail(
        newEmail: newEmail,
        callbackURL: callbackURL,
      );
      _user = _user == null
          ? User(id: newEmail, email: newEmail, role: UserRole.customer)
          : User(
              id: _user!.id,
              email: newEmail,
              name: _user!.name,
              role: _user!.role,
            );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        revokeOtherSessions: revokeOtherSessions,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.requestPasswordReset(
        email: email,
        redirectTo: redirectTo,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendVerificationEmail(
        email: email,
        callbackURL: callbackURL,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
