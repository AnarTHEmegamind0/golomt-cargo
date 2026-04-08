import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/app_card.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/address/pages/address_page.dart';
import 'package:core/features/notifications/pages/notifications_page.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/orders/providers/order_provider.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/shell/service/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load orders data for statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().load();
      context.read<DeliveryProvider>().load();
      context.read<DeliveryProvider>().loadEligibleCargos();
      context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CargoBackdrop(
      light: !isDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                onNotificationsTap: () {
                  Navigator.of(
                    context,
                  ).push(PageTransitions.slideFade(const NotificationsPage()));
                },
              ),
              const SizedBox(height: 20),
              _WelcomeCard(),
              const SizedBox(height: 24),
              Text(
                'Үйлдлүүд',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _WorkflowGrid(),
              const SizedBox(height: 24),
              Text(
                'Таны нийт карго',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _StatsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = context.select((AuthProvider p) => p.user?.name?.trim());
    final greetingName = (userName == null || userName.isEmpty)
        ? 'Голомт карго'
        : userName;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сайн уу',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? const Color(0xFF8B95A8)
                      : const Color(0xFF75819A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                greetingName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationsTap,
          icon: Image.asset(ShipAssets.bell, width: 32, height: 32),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2F6A), Color(0xFF165CCB), Color(0xFF1A6FFF)],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandPalette.logoOrange.withValues(alpha: 0.22),
                ),
              ),
            ),
            Positioned(
              bottom: -42,
              left: -30,
              child: Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(130),
                  color: Colors.black.withValues(alpha: 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 350;
                  final truckH = narrow ? 136.0 : 158.0;
                  return Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 4,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(120),
                                  color: Colors.black.withValues(alpha: 0.22),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/truck_man.png',
                                height: truckH,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/truck_man.png',
                                      height: truckH,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 150,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.16),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Icon(
                                                  Icons.local_shipping_rounded,
                                                  color: Colors.white,
                                                  size: 48,
                                                ),
                                              ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '03.08 хүртэлх\nачаа ирлээ.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: narrow ? 20 : 24,
                                fontWeight: FontWeight.w900,
                                height: 1.02,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowGrid extends StatelessWidget {
  const _WorkflowGrid();

  @override
  Widget build(BuildContext context) {
    final navController = context.read<NavigationController>();

    final workflows = [
      _WorkflowData(
        assetPath: ShipAssets.locationMaps,
        title: 'Салбар',
        onTap: () => navController.setIndex(3), // Branch tab
      ),
      _WorkflowData(
        assetPath: ShipAssets.basket,
        title: 'Трак код',
        onTap: () => navController.setIndex(1), // Orders tab
      ),
      _WorkflowData(
        assetPath: ShipAssets.clockAndHome,
        title: 'Хаяг',
        onTap: () {
          Navigator.of(
            context,
          ).push(PageTransitions.slideFade(const AddressPage()));
        },
      ),
      _WorkflowData(
        assetPath: ShipAssets.truck,
        title: 'Хүргэлт',
        onTap: () => navController.setIndex(2), // Delivery tab
      ),
      _WorkflowData(
        assetPath: ShipAssets.handWithCare,
        title: 'Заавар',
        onTap: () => navController.setIndex(2), // Delivery tab
      ),
      _WorkflowData(
        assetPath: ShipAssets.manDeliveringPackage,
        title: 'Тусламж',
        onTap: () => _showSupportDialog(context),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final crossAxisCount = isNarrow ? 3 : 6;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 90,
          ),
          itemCount: workflows.length,
          itemBuilder: (context, index) {
            final workflow = workflows[index];
            return _CompactWorkflowItem(
              assetPath: workflow.assetPath!,
              title: workflow.title,
              onTap: workflow.onTap,
            );
          },
        );
      },
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тусламж'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Холбоо барих:'),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 18),
                SizedBox(width: 8),
                Text('+976 7777-8888'),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.email, size: 18),
                SizedBox(width: 8),
                Text('support@cargo.mn'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Хаах'),
          ),
        ],
      ),
    );
  }
}

class _WorkflowData {
  const _WorkflowData({
    this.icon,
    this.assetPath,
    required this.title,
    required this.onTap,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided',
       );

  final IconData? icon;
  final String? assetPath;
  final String title;
  final VoidCallback onTap;
}

class _CompactWorkflowItem extends StatelessWidget {
  const _CompactWorkflowItem({
    required this.assetPath,
    required this.title,
    required this.onTap,
  });

  final String assetPath;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE4E8EE),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFE8ECF4)
                      : const Color(0xFF293247),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final isLoading = orderProvider.isLoading;

    // Calculate stats from provider
    final totalOrders = orderProvider.orders.length;
    final deliveredCount = orderProvider.deliveredCount;
    final transitCount =
        orderProvider.transitCount + orderProvider.pendingCount;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Нийт',
            value: isLoading ? '-' : '$totalOrders',
            iconAssetPath: 'assets/home_page/orders.png',
            color: const Color(0xFF8B5CF6),
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Замд яваа',
            value: isLoading ? '-' : '$transitCount',
            iconAssetPath: 'assets/home_page/in_progress.png',
            color: const Color(0xFFF59E0B),
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Хүргэгдсэн',
            value: isLoading ? '-' : '$deliveredCount',
            iconAssetPath: 'assets/home_page/done.png',
            color: const Color(0xFF10B981),
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.iconAssetPath,
    required this.color,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final String iconAssetPath;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Image.asset(
              iconAssetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.insert_chart_rounded, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? const Color(0xFFE8ECF4)
                    : const Color(0xFF1E2638),
              ),
            ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8B95A8) : const Color(0xFF677186),
            ),
          ),
        ],
      ),
    );
  }
}
