import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:flutter/foundation.dart';

/// Provider for admin user management
class AdminUsersProvider extends ChangeNotifier {
  AdminUsersProvider({required AdminService service}) : _service = service;

  final AdminService _service;

  bool _isLoading = false;
  String? _error;
  List<AdminUser> _users = [];
  AdminUser? _selectedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AdminUser> get users => _users;
  AdminUser? get selectedUser => _selectedUser;

  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_users.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.listUsers(limit: 100);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers(forceRefresh: true);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.listUsers(
        searchField: 'email',
        searchValue: query,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUser = await _service.getUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  Future<void> setUserRole(String userId, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.setRole(userId: userId, role: role);
      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: role);
      }
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser?.copyWith(role: role);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> banUser(String userId, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.banUser(userId: userId, reason: reason);
      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(banned: true, banReason: reason);
      }
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser?.copyWith(
          banned: true,
          banReason: reason,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unbanUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.unbanUser(userId);
      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(banned: false, banReason: null);
      }
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser?.copyWith(banned: false, banReason: null);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _service.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _users.insert(0, newUser);
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
}
