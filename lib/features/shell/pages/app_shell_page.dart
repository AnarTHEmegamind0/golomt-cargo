import 'package:core/features/home/pages/home_page.dart';
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

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomePage(), ProfilePage(), SettingsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: context.read<NavigationController>().setIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

