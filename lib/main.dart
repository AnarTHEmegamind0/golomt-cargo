import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core/app_theme.dart';
import 'package:core/core/di/app_providers.dart';
import 'package:core/core/navigation/global_keys.dart';
import 'package:core/features/auth/pages/login_page.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/shell/pages/app_shell_page.dart';

/// Default design version (1=Glassmorphism, 2=Neumorphism, 3=Minimal, 4=Cyberpunk, 5=Luxury)
/// This can be overridden by user preference in SettingsProvider
const int designVersion = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: AppProviders.build(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = context.select(
      (SettingsProvider p) => p.settings.themeMode,
    );
    final currentDesignVersion = context.select(
      (SettingsProvider p) => p.settings.designVersion,
    );
    final isLoggedIn = context.select((AuthProvider p) => p.isLoggedIn);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalKeys.navigatorKey,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              // ignore: deprecated_member_use
              clampDouble(MediaQuery.of(context).textScaleFactor, 0.8, 1.4),
            ),
          ),
          child: child!,
        );
      },
      theme: AppTheme.design(currentDesignVersion, Brightness.light),
      darkTheme: AppTheme.design(currentDesignVersion, Brightness.dark),
      themeMode: themeMode,
      home: isLoggedIn ? const AppShellPage() : const LoginPage(),
    );
  }
}
