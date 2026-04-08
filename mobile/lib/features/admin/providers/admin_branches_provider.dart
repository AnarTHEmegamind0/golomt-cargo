import 'package:core/features/admin/services/admin_service.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/services/branch_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for branch management
class AdminBranchesProvider extends ChangeNotifier {
  AdminBranchesProvider({
    required AdminService adminService,
    required BranchService branchService,
  })  : _adminService = adminService,
        _branchService = branchService;

  final AdminService _adminService;
  final BranchService _branchService;

  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;
  String? _processingBranchId;

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get processingBranchId => _processingBranchId;

  /// Get active branches only
  List<Branch> get activeBranches =>
      _branches.where((b) => b.isActive).toList();

  /// Load all branches
  Future<void> loadBranches({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_branches.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _branches = await _branchService.fetchAll();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new branch
  Future<bool> createBranch({
    required String name,
    required String code,
    required String address,
    String? phone,
    String? chinaAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final branch = await _adminService.createBranch(
        name: name,
        code: code,
        address: address,
        phone: phone,
        chinaAddress: chinaAddress,
      );
      _branches = [branch, ..._branches];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a branch
  Future<bool> updateBranch({
    required String branchId,
    String? name,
    String? code,
    String? address,
    String? phone,
    String? chinaAddress,
    bool? isActive,
  }) async {
    _processingBranchId = branchId;
    _error = null;
    notifyListeners();

    try {
      final updated = await _adminService.updateBranch(
        branchId: branchId,
        name: name,
        code: code,
        address: address,
        phone: phone,
        chinaAddress: chinaAddress,
        isActive: isActive,
      );

      final index = _branches.indexWhere((b) => b.id == branchId);
      if (index != -1) {
        _branches = List.from(_branches)..[index] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingBranchId = null;
      notifyListeners();
    }
  }

  /// Toggle branch active status
  Future<bool> toggleActive(String branchId) async {
    final branch = _branches.firstWhere(
      (b) => b.id == branchId,
      orElse: () => throw Exception('Branch not found'),
    );

    return updateBranch(branchId: branchId, isActive: !branch.isActive);
  }

  /// Delete a branch
  Future<bool> deleteBranch(String branchId) async {
    _processingBranchId = branchId;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteBranch(branchId);
      _branches = _branches.where((b) => b.id != branchId).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _processingBranchId = null;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
