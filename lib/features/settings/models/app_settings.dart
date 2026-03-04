import 'package:core/core/app_theme.dart';
import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    this.designVersion = DesignVersion.glassmorphism,
  });

  final ThemeMode themeMode;
  final DesignVersion designVersion;

  AppSettings copyWith({ThemeMode? themeMode, DesignVersion? designVersion}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      designVersion: designVersion ?? this.designVersion,
    );
  }
}
