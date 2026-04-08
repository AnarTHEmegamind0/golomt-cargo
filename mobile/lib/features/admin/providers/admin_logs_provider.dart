import 'package:core/features/admin/models/admin_activity_log.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for activity logs
class AdminLogsProvider extends ChangeNotifier {
  AdminLogsProvider({required AdminService adminService})
      : _adminService = adminService;

  final AdminService _adminService;

  List<AdminActivityLog> _logs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  String? _actionFilter;
  String? _targetTypeFilter;

  static const int _pageSize = 20;
  int _offset = 0;

  List<AdminActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get actionFilter => _actionFilter;
  String? get targetTypeFilter => _targetTypeFilter;

  /// Load logs (initial or refresh)
  Future<void> loadLogs({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (forceRefresh) {
      _logs = [];
      _offset = 0;
      _hasMore = true;
    }

    if (!_hasMore && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newLogs = await _adminService.listActivityLogs(
        limit: _pageSize,
        offset: _offset,
        action: _actionFilter,
        targetType: _targetTypeFilter,
      );

      if (newLogs.length < _pageSize) {
        _hasMore = false;
      }

      _logs = [..._logs, ...newLogs];
      _offset += newLogs.length;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more logs (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadLogs();
  }

  /// Set action filter and reload
  Future<void> setActionFilter(String? action) async {
    if (_actionFilter == action) return;
    _actionFilter = action;
    await loadLogs(forceRefresh: true);
  }

  /// Set target type filter and reload
  Future<void> setTargetTypeFilter(String? targetType) async {
    if (_targetTypeFilter == targetType) return;
    _targetTypeFilter = targetType;
    await loadLogs(forceRefresh: true);
  }

  /// Clear all filters and reload
  Future<void> clearFilters() async {
    _actionFilter = null;
    _targetTypeFilter = null;
    await loadLogs(forceRefresh: true);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
