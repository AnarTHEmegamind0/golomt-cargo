import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/widgets/theme_mode_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _reducedMotion = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select(
      (SettingsProvider p) => p.settings.themeMode,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Theme, accessibility, and session controls.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Switch between system, light, and dark modes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ThemeModePicker(
                    value: themeMode,
                    onChanged: context.read<SettingsProvider>().setThemeMode,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile.adaptive(
              value: _reducedMotion,
              onChanged: (value) => setState(() => _reducedMotion = value),
              title: const Text('Reduced motion mode'),
              subtitle: const Text('Minimize non-essential movement and transitions.'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Session', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Sign out from this device.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('settings_logout'),
                    onPressed: context.read<AuthProvider>().logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
