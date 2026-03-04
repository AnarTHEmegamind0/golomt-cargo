import 'package:flutter/foundation.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/services/branch_service.dart';

/// Branch state provider
class BranchProvider extends ChangeNotifier {
  BranchProvider({required BranchService service}) : _service = service;

  final BranchService _service;

  bool _isLoading = false;
  String? _error;
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isGridView = true;
  bool _hasLoaded = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;
  bool get isGridView => _isGridView;
  bool get hasLoaded => _hasLoaded;

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void selectBranch(Branch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _branches = await _service.fetchAll();
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBranchById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBranch = await _service.fetchById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
