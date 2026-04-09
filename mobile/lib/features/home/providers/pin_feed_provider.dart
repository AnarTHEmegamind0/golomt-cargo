import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/services/pin_feed_service.dart';
import 'package:flutter/foundation.dart';

class PinFeedProvider extends ChangeNotifier {
  PinFeedProvider({required PinFeedService service}) : _service = service;

  final PinFeedService _service;

  bool _isLoading = false;
  String? _error;
  String _selectedBoard = 'All';
  List<PinItem> _allPins = const [];
  bool _hasLoaded = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedBoard => _selectedBoard;
  bool get hasLoaded => _hasLoaded;

  List<String> get boards {
    final uniqueBoards = _allPins.map((pin) => pin.board).toSet().toList()
      ..sort();
    return ['All', ...uniqueBoards];
  }

  List<PinItem> get pins {
    if (_selectedBoard == 'All') {
      return _allPins;
    }

    return _allPins.where((pin) => pin.board == _selectedBoard).toList();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allPins = await _service.fetchPins();
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectBoard(String board) {
    if (board == _selectedBoard) {
      return;
    }

    _selectedBoard = board;
    notifyListeners();
  }
}
