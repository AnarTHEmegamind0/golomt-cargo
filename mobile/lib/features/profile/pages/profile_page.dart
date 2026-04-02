import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.select((ProfileProvider p) => p.profile);
    final isLoading = context.select((ProfileProvider p) => p.isLoading);
    final themeMode = context.select(
      (SettingsProvider p) => p.settings.themeMode,
    );
    final isDarkMode = themeMode == ThemeMode.dark;
    final isDark = theme.brightness == Brightness.dark;

    return CargoBackdrop(
      light: !isDark,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF1F2F54), Color(0xFF162445)]
                              : const [
                                  BrandPalette.white,
                                  BrandPalette.softBlueBackground,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : BrandPalette.electricBlue.withValues(
                                  alpha: 0.16,
                                ),
                        ),
                      ),
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 68,
                        color: isDark
                            ? const Color(0xFF8DB4FF)
                            : BrandPalette.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '80112818',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.displayName ?? 'Жолооч',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _MenuTile(
                icon: Icons.person_outline_rounded,
                label: 'Миний мэдээлэл',
              ),
              _MenuTile(icon: Icons.local_shipping_outlined, label: 'Хүргэлт'),
              _MenuTile(icon: Icons.location_on_outlined, label: 'Салбарууд'),
              _SwitchTile(
                icon: Icons.dark_mode_outlined,
                label: 'Харанхуй горим',
                value: isDarkMode,
                onChanged: (value) {
                  context.read<SettingsProvider>().setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              _MenuTile(icon: Icons.info_outline_rounded, label: 'Тусламж'),
              _MenuTile(icon: Icons.calculate_outlined, label: 'Тооцоолуур'),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: context.read<AuthProvider>().logout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: BrandPalette.errorRed,
                ),
                label: Text(
                  'Гарах',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: BrandPalette.errorRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.trailingText});

  final IconData icon;
  final String label;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.86)
        : BrandPalette.white.withValues(alpha: 0.82);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : BrandPalette.electricBlue.withValues(alpha: 0.14);
    final iconColor = isDark
        ? theme.colorScheme.onSurface
        : BrandPalette.primaryText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              )
            : const Icon(
                Icons.chevron_right_rounded,
                size: 36,
                color: BrandPalette.electricBlue,
              ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.86)
        : BrandPalette.white.withValues(alpha: 0.82);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : BrandPalette.electricBlue.withValues(alpha: 0.14);
    final iconColor = isDark
        ? theme.colorScheme.onSurface
        : BrandPalette.primaryText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        trailing: Switch.adaptive(
          value: value,
          activeThumbColor: BrandPalette.white,
          activeTrackColor: BrandPalette.electricBlue,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
