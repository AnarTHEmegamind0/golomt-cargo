import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/features/branch/pages/branch_list_page.dart';
import 'package:core/features/delivery/pages/delivery_tracking_page.dart';
import 'package:core/features/home/pages/home_page.dart';
import 'package:core/features/orders/pages/orders_page.dart';
import 'package:core/features/profile/pages/profile_page.dart';
import 'package:core/features/shell/service/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select(
      (NavigationController controller) => controller.index,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final shellDecoration = BoxDecoration(
      color: isDark
          ? const Color(0xFF141D2A).withValues(alpha: 0.96)
          : Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE4E8EE),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.34)
              : const Color(0xFF1C2332).withValues(alpha: 0.1),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
    );

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          HomePage(),
          OrdersPage(),
          DeliveryTrackingPage(),
          BranchListPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: shellDecoration,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: primaryColor.withValues(
                alpha: isDark ? 0.22 : 0.14,
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 11,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : (isDark
                            ? const Color(0xFFAAB3C1)
                            : const Color(0xFF858E9D)),
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  size: 24,
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : (isDark
                            ? const Color(0xFFAAB3C1)
                            : const Color(0xFF858E9D)),
                ),
              ),
            ),
            child: NavigationBar(
              height: 70,
              selectedIndex: selectedIndex,
              onDestinationSelected: context
                  .read<NavigationController>()
                  .setIndex,
              destinations: [
                NavigationDestination(
                  icon: ShipIcon(ShipAssets.clockAndHome, size: 28, key: const ValueKey('nav_home')),
                  selectedIcon: ShipIcon(ShipAssets.clockAndHome, size: 32, key: const ValueKey('nav_home_selected')),
                  label: 'Нүүр',
                ),
                NavigationDestination(
                  icon: ShipIcon(ShipAssets.basket, size: 28, key: const ValueKey('nav_orders')),
                  selectedIcon: ShipIcon(ShipAssets.basket, size: 32, key: const ValueKey('nav_orders_selected')),
                  label: 'Захиалга',
                ),
                NavigationDestination(
                  icon: ShipIcon(ShipAssets.truck, size: 28, key: const ValueKey('nav_delivery')),
                  selectedIcon: ShipIcon(ShipAssets.truck, size: 32, key: const ValueKey('nav_delivery_selected')),
                  label: 'Хүргэлт',
                ),
                NavigationDestination(
                  icon: ShipIcon(ShipAssets.locationMaps, size: 28, key: const ValueKey('nav_branch')),
                  selectedIcon: ShipIcon(ShipAssets.locationMaps, size: 32, key: const ValueKey('nav_branch_selected')),
                  label: 'Салбар',
                ),
                NavigationDestination(
                  icon: ShipIcon(ShipAssets.manDeliveringPackage, size: 28, key: const ValueKey('nav_settings')),
                  selectedIcon: ShipIcon(ShipAssets.manDeliveringPackage, size: 32, key: const ValueKey('nav_settings_selected')),
                  label: 'Профайл',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
