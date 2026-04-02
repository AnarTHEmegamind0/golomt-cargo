import 'package:core/core/app_theme.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/pages/branch_detail_page.dart';
import 'package:core/features/branch/pages/branch_list_page.dart';
import 'package:core/features/capture/di/capture_providers.dart';
import 'package:core/features/capture/models/capture_request.dart';
import 'package:core/features/delivery/pages/chat_page.dart';
import 'package:core/features/delivery/pages/delivery_home_page.dart';
import 'package:core/features/delivery/pages/delivery_proof_page.dart';
import 'package:core/features/delivery/pages/delivery_tracking_page.dart';
import 'package:core/features/delivery/pages/earnings_page.dart';
import 'package:core/features/delivery/pages/notifications_page.dart'
    as delivery_notifications;
import 'package:core/features/delivery/pages/onboarding_page.dart';
import 'package:core/features/delivery/pages/order_detail_page.dart';
import 'package:core/features/delivery/pages/order_map_navigation_page.dart';
import 'package:core/features/home/pages/home_page.dart';
import 'package:core/features/notifications/pages/notifications_page.dart'
    as app_notifications;
import 'package:core/features/orders/pages/orders_page.dart';
import 'package:core/features/profile/pages/profile_page.dart';
import 'package:core/features/settings/pages/settings_page.dart';
import 'package:core/features/shell/pages/app_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/features/auth/pages/login_page.dart';
import 'package:core/features/auth/pages/signup_page.dart';

class CaptureHarnessApp extends StatelessWidget {
  const CaptureHarnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final request = CaptureRequest.fromUri(Uri.base);
    final brightness = request.theme == CaptureThemeVariant.dark
        ? Brightness.dark
        : Brightness.light;

    return MultiProvider(
      providers: buildCaptureProviders(preset: request.state),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.design(DesignVersion.glassmorphism, Brightness.light),
        darkTheme: AppTheme.design(
          DesignVersion.glassmorphism,
          Brightness.dark,
        ),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: CaptureHarnessPage(request: request),
      ),
    );
  }
}

class CaptureHarnessPage extends StatelessWidget {
  const CaptureHarnessPage({super.key, required this.request});

  final CaptureRequest request;

  static const _screens = <String>[
    'login',
    'signup',
    'shell',
    'home',
    'orders',
    'delivery_tracking',
    'branch_list',
    'branch_detail',
    'settings',
    'profile',
    'notifications',
    'delivery_notifications',
    'delivery_home',
    'order_detail',
    'delivery_proof',
    'chat',
    'earnings',
    'order_map',
    'onboarding',
  ];

  @override
  Widget build(BuildContext context) {
    final target = _buildScreen(request.screenId);
    if (target == null) {
      return _CaptureIndex(request: request);
    }

    return Stack(
      children: [
        Positioned.fill(child: target),
        Positioned(
          top: 12,
          right: 12,
          child: _CaptureBadge(
            screenId: request.screenId,
            theme: request.theme,
            state: request.state,
          ),
        ),
      ],
    );
  }

  Widget? _buildScreen(String screenId) {
    if (screenId == 'all') {
      return _AllScreensGallery(
        screens: _screens,
        buildScreen: _buildSingleScreen,
      );
    }

    return _buildSingleScreen(screenId);
  }

  Widget? _buildSingleScreen(String screenId) {
    final sampleBranch = Branch(
      id: 'branch-capture',
      name: 'Голомт карго - Capture',
      address: 'Хан-Уул дүүрэг, Улаанбаатар',
      chinaAddress: 'Guangzhou, China Warehouse',
      latitude: 47.9184,
      longitude: 106.9177,
      phone: '+976 7711-1234',
      workingHours: '09:00-18:00',
      iconColor: const Color(0xFFF08A1A),
      description: 'Capture sample branch',
    );

    return switch (screenId) {
      'login' => const LoginPage(),
      'signup' => const SignUpPage(),
      'shell' => const AppShellPage(),
      'home' => const HomePage(),
      'orders' => const OrdersPage(),
      'delivery_tracking' => const DeliveryTrackingPage(),
      'branch_list' => const BranchListPage(),
      'branch_detail' => BranchDetailPage(branch: sampleBranch),
      'settings' => const SettingsPage(),
      'profile' => const ProfilePage(),
      'notifications' => const app_notifications.NotificationsPage(),
      'delivery_notifications' =>
        const delivery_notifications.NotificationsPage(),
      'delivery_home' => const DeliveryHomePage(),
      'order_detail' => const OrderDetailPage(orderId: 'ORD-31041'),
      'delivery_proof' => const DeliveryProofPage(orderId: 'ORD-31041'),
      'chat' => const ChatPage(orderId: 'ORD-31041'),
      'earnings' => const EarningsPage(),
      'order_map' => const OrderMapNavigationPage(orderId: 'ORD-31041'),
      'onboarding' => OnboardingPage(onFinish: () {}),
      _ => null,
    };
  }
}

class _AllScreensGallery extends StatelessWidget {
  const _AllScreensGallery({required this.screens, required this.buildScreen});

  final List<String> screens;
  final Widget? Function(String screenId) buildScreen;

  @override
  Widget build(BuildContext context) {
    final sections = screens
        .map((screenId) => (id: screenId, widget: buildScreen(screenId)))
        .where((entry) => entry.widget != null)
        .toList();

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  section.id,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                height: 880,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: section.widget!,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaptureIndex extends StatelessWidget {
  const _CaptureIndex({required this.request});

  final CaptureRequest request;

  @override
  Widget build(BuildContext context) {
    final base = Uri.base.replace(queryParameters: {});
    final examples = CaptureHarnessPage._screens
        .map(
          (screen) =>
              '${base.toString()}?screen=$screen&theme=light&state=default',
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Capture Index')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Pass query params: screen, theme (light/dark), state (default/loading/error/empty)',
            ),
            const SizedBox(height: 12),
            Text(
              'Current -> screen=${request.screenId}, theme=${request.theme.name}, state=${request.state.name}',
            ),
            const SizedBox(height: 16),
            ...examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectableText(example),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureBadge extends StatelessWidget {
  const _CaptureBadge({
    required this.screenId,
    required this.theme,
    required this.state,
  });

  final String screenId;
  final CaptureThemeVariant theme;
  final CaptureStatePreset state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : const Color(0xFFD4D8DF),
        ),
      ),
      child: Text(
        '$screenId • ${theme.name} • ${state.name}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF222A38),
        ),
      ),
    );
  }
}
