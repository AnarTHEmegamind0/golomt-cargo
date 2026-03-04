import 'package:core/features/delivery/pages/delivery_home_page.dart';
import 'package:core/features/delivery/pages/notifications_page.dart';
import 'package:core/features/delivery/providers/driver_notification_provider.dart';
import 'package:core/features/profile/pages/profile_page.dart';
import 'package:core/features/settings/pages/settings_page.dart';
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
    final unreadNotifications = context.select(
      (DriverNotificationProvider provider) => provider.unreadCount,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shellDecoration = BoxDecoration(
      color: isDark
          ? const Color(0xFF141D2A).withValues(alpha: 0.94)
          : Colors.white.withValues(alpha: 0.94),
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
              : const Color(0xFF1C2332).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          DeliveryHomePage(),
          NotificationsPage(),
          ProfilePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          decoration: shellDecoration,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: isDark
                  ? const Color(0xFFF08A1A).withValues(alpha: 0.22)
                  : const Color(0xFFF08A1A).withValues(alpha: 0.16),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 12,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: states.contains(WidgetState.selected)
                      ? const Color(0xFFF08A1A)
                      : (isDark
                            ? const Color(0xFFAAB3C1)
                            : const Color(0xFF858E9D)),
                ),
              ),
            ),
            child: NavigationBar(
              height: 74,
              selectedIndex: selectedIndex,
              onDestinationSelected: context
                  .read<NavigationController>()
                  .setIndex,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_rounded, key: ValueKey('nav_home')),
                  selectedIcon: Icon(
                    Icons.home_filled,
                    key: ValueKey('nav_home_selected'),
                  ),
                  label: 'Нүүр',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unreadNotifications > 0,
                    smallSize: 8,
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      key: ValueKey('nav_notifications'),
                    ),
                  ),
                  selectedIcon: const Icon(
                    Icons.local_shipping_rounded,
                    key: ValueKey('nav_notifications_selected'),
                  ),
                  label: 'Захиалга',
                ),
                const NavigationDestination(
                  icon: Icon(
                    Icons.person_outline_rounded,
                    key: ValueKey('nav_profile'),
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    key: ValueKey('nav_profile_selected'),
                  ),
                  label: 'Профайл',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.tune_rounded, key: ValueKey('nav_settings')),
                  selectedIcon: Icon(
                    Icons.tune_rounded,
                    key: ValueKey('nav_settings_selected'),
                  ),
                  label: 'Тохиргоо',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
