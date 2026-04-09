import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/admin/pages/admin_branches_page.dart';
import 'package:core/features/admin/pages/admin_cargos_page.dart';
import 'package:core/features/admin/pages/admin_dashboard_page.dart';
import 'package:core/features/admin/pages/admin_finance_page.dart';
import 'package:core/features/admin/pages/admin_logs_page.dart';
import 'package:core/features/admin/pages/admin_shipments_page.dart';
import 'package:core/features/admin/pages/admin_users_page.dart';
import 'package:core/features/admin/pages/admin_vehicles_page.dart';
import 'package:core/features/admin/widgets/admin_drawer.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin shell with drawer navigation (8 sections)
class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _pages = const [
    AdminDashboardPage(), // 0: Тойм
    AdminCargosPage(), // 1: Бараа
    AdminShipmentsPage(), // 2: Ачилт
    AdminVehiclesPage(), // 3: Машин
    AdminUsersPage(), // 4: Хэрэглэгчид
    AdminBranchesPage(), // 5: Салбар
    AdminFinancePage(), // 6: Санхүү
    AdminLogsPage(), // 7: Лог
  ];

  final _titles = const [
    'Тойм',
    'Бараа',
    'Ачилт',
    'Машин',
    'Хэрэглэгчид',
    'Салбар',
    'Санхүү',
    'Лог',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      body: CargoBackdrop(
        light: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    // Menu button
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: BrandPalette.electricBlue.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: BrandPalette.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titles[_currentIndex],
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: BrandPalette.primaryText,
                                  ),
                            ),
                            Text(
                              'Админ панел',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: BrandPalette.mutedText,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
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
    );
  }
}
