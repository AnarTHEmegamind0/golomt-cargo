import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/admin/pages/admin_cargos_page.dart';
import 'package:core/features/admin/pages/admin_dashboard_page.dart';
import 'package:core/features/admin/pages/admin_users_page.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin shell with bottom navigation (3 tabs: Dashboard, Users, Cargos)
class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _currentIndex = 0;

  final _pages = const [
    AdminDashboardPage(),
    AdminUsersPage(),
    AdminCargosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CargoBackdrop(
        light: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    // Logo / Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: BrandPalette.electricBlue.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const ShipIcon(
                            ShipAssets.handWithCare,
                            color: BrandPalette.electricBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Админ',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: BrandPalette.primaryText,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Logout button
                    TextButton.icon(
                      onPressed: context.read<AuthProvider>().logout,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Гарах'),
                      style: TextButton.styleFrom(
                        foregroundColor: BrandPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  assetPath: ShipAssets.clockAndHome,
                  label: 'Тойм',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  assetPath: ShipAssets.manDeliveringPackage,
                  label: 'Хэрэглэгчид',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  assetPath: ShipAssets.boxReturn,
                  label: 'Бараа',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? BrandPalette.electricBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShipIcon(
              assetPath,
              color: isSelected
                  ? BrandPalette.electricBlue
                  : BrandPalette.mutedText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? BrandPalette.electricBlue
                    : BrandPalette.mutedText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
