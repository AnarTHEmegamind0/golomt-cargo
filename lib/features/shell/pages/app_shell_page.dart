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

  static const _titles = ['Home', 'Notifications', 'Profile', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select(
      (NavigationController controller) => controller.index,
    );
    final unreadNotifications = context.select(
      (DriverNotificationProvider provider) => provider.unreadCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          DeliveryHomePage(),
          NotificationsPage(),
          ProfilePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: context.read<NavigationController>().setIndex,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, key: ValueKey('nav_home')),
                selectedIcon: Icon(Icons.dashboard_rounded, key: ValueKey('nav_home_selected')),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unreadNotifications > 0,
                  smallSize: 8,
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    key: ValueKey('nav_notifications'),
                  ),
                ),
                selectedIcon: const Icon(
                  Icons.notifications_rounded,
                  key: ValueKey('nav_notifications_selected'),
                ),
                label: 'Notifications',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, key: ValueKey('nav_profile')),
                selectedIcon: Icon(Icons.person_rounded, key: ValueKey('nav_profile_selected')),
                label: 'Profile',
              ),
              const NavigationDestination(
                icon: Icon(Icons.tune_rounded, key: ValueKey('nav_settings')),
                selectedIcon: Icon(Icons.tune_rounded, key: ValueKey('nav_settings_selected')),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
