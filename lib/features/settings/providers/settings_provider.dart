import 'package:core/core/app_theme.dart';
import 'package:core/features/settings/models/app_settings.dart';
import 'package:core/features/settings/services/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required SettingsService settingsService})
    : _settingsService = settingsService;

  final SettingsService _settingsService;

  bool _isLoading = false;
  AppSettings _settings = const AppSettings(
    themeMode: ThemeMode.system,
    designVersion: DesignVersion.glassmorphism,
  );

  bool get isLoading => _isLoading;
  AppSettings get settings => _settings;

  /// Convenience getter for design version
  DesignVersion get designVersion => _settings.designVersion;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _settingsService.read();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final next = _settings.copyWith(themeMode: mode);
    _settings = next;
    notifyListeners();
    await _settingsService.write(next);
  }

  /// Set design version and persist
  Future<void> setDesignVersion(DesignVersion version) async {
    final next = _settings.copyWith(designVersion: version);
    _settings = next;
    notifyListeners();
    await _settingsService.write(next);
  }
}
