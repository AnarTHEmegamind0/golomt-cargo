import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/widgets/design_version_picker.dart';
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
    final designVersion = context.select(
      (SettingsProvider p) => p.settings.designVersion,
    );

    return CargoBackdrop(
      light: true,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Text(
              'Тохиргоо',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Загвар, хүртээмж, болон бүртгэлийн удирдлага.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Загвар', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Систем, цайвар, харанхуй горимоос сонгоно уу.',
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
            const SizedBox(height: 12),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Дизайн хувилбар',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '5 өөр дизайн загвараас сонгоно уу.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  DesignVersionPicker(
                    value: designVersion,
                    onChanged: context
                        .read<SettingsProvider>()
                        .setDesignVersion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _GlassCard(
              child: SwitchListTile.adaptive(
                value: _reducedMotion,
                onChanged: (value) => setState(() => _reducedMotion = value),
                title: const Text('Хөдөлгөөн багасгах горим'),
                subtitle: const Text(
                  'Шаардлагагүй хөдөлгөөн, шилжилтийг багасгана.',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Бүртгэл',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Энэ төхөөрөмжөөс гарах.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('settings_logout'),
                    onPressed: context.read<AuthProvider>().logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Гарах'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE0E8)),
      ),
      child: child,
    );
  }
}
