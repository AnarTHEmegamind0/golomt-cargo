import 'package:core/features/admin/models/finance_summary.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for financial reports
class AdminFinanceProvider extends ChangeNotifier {
  AdminFinanceProvider({required AdminService adminService})
    : _adminService = adminService;

  final AdminService _adminService;

  FinanceSummary _summary = FinanceSummary.empty();
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  FinanceSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Check if a date range is set
  bool get hasDateRange => _startDate != null && _endDate != null;

  /// Get date range display string
  String get dateRangeDisplay {
    if (!hasDateRange) return 'Бүх хугацаа';
    final start = '${_startDate!.month}/${_startDate!.day}';
    final end = '${_endDate!.month}/${_endDate!.day}';
    return '$start - $end';
  }

  /// Load finance summary
  Future<void> loadSummary({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _adminService.getFinanceSummary(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set date range and reload
  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    notifyListeners();
    await loadSummary(forceRefresh: true);
  }

  /// Clear date range and reload
  Future<void> clearDateRange() async {
    _startDate = null;
    _endDate = null;
    notifyListeners();
    await loadSummary(forceRefresh: true);
  }

  /// Set last N days as date range
  Future<void> setLastDays(int days) async {
    final now = DateTime.now();
    _endDate = now;
    _startDate = now.subtract(Duration(days: days));
    notifyListeners();
    await loadSummary(forceRefresh: true);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
