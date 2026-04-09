import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/china_staff/pages/china_dashboard_page.dart';
import 'package:core/features/china_staff/pages/china_cargo_import_page.dart';
import 'package:core/features/china_staff/pages/china_vehicles_page.dart';
import 'package:core/features/china_staff/pages/china_shipments_page.dart';
import 'package:core/features/china_staff/widgets/china_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// China staff shell with drawer navigation
class ChinaStaffShellPage extends StatefulWidget {
  const ChinaStaffShellPage({super.key});

  @override
  State<ChinaStaffShellPage> createState() => _ChinaStaffShellPageState();
}

class _ChinaStaffShellPageState extends State<ChinaStaffShellPage> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _pages = const [
    ChinaDashboardPage(), // 0: Тойм
    ChinaCargoImportPage(), // 1: Бараа бүртгэл
    ChinaVehiclesPage(), // 2: Машин
    ChinaShipmentsPage(), // 3: Ачилт
  ];

  final _titles = const ['Тойм', 'Бараа бүртгэл', 'Машин', 'Ачилт'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChinaDrawer(
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
                        backgroundColor: BrandPalette.logoOrange.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: BrandPalette.logoOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Logo / Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: BrandPalette.logoOrange.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const ShipIcon(
                            ShipAssets.handWithCare,
                            color: BrandPalette.logoOrange,
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
                              'Хятад агуулах',
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
