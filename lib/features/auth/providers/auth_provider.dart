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

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}

