import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/design_system/components/app_card.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/icon_badge.dart';
import 'package:core/features/notifications/pages/notifications_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                'Хялбар ажлын урсгал',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _WorkflowGrid(),
              const SizedBox(height: 24),
              Text(
                'Түгээмэл үйлдлүүд',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _QuickActionsRow(),
              const SizedBox(height: 24),
              Text(
                'Статистик',
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
                'Буундуу Карго',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton.filledTonal(
              onPressed: onNotificationsTap,
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.92),
                foregroundColor: isDark
                    ? const Color(0xFFE8ECF4)
                    : const Color(0xFF1E2638),
              ),
              icon: const Icon(Icons.notifications_rounded),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1A2234) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: const [Color(0xFFF08A1A), Color(0xFFE85D04)],
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Таны ачаа аюулгүй, хурдан!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Хятадаас Монгол руу хамгийн хурдан хүргэлт',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowGrid extends StatelessWidget {
  const _WorkflowGrid();

  @override
  Widget build(BuildContext context) {
    final workflows = [
      _WorkflowData(
        icon: Icons.storefront_rounded,
        title: 'Салбар сонгох',
        color: const Color(0xFF8B5CF6),
        step: 1,
      ),
      _WorkflowData(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Трак код бүртгэх',
        color: const Color(0xFF3B82F6),
        step: 2,
      ),
      _WorkflowData(
        icon: Icons.payment_rounded,
        title: 'Төлбөр төлөх',
        color: const Color(0xFF10B981),
        step: 3,
      ),
      _WorkflowData(
        icon: Icons.local_shipping_rounded,
        title: 'Хүргэлт захиалах',
        color: const Color(0xFFF59E0B),
        step: 4,
      ),
      _WorkflowData(
        icon: Icons.check_circle_rounded,
        title: 'Ачаа хүлээн авах',
        color: const Color(0xFFEC4899),
        step: 5,
      ),
      _WorkflowData(
        icon: Icons.support_agent_rounded,
        title: 'Тусламж авах',
        color: const Color(0xFF06B6D4),
        step: 6,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: workflows.length,
      itemBuilder: (context, index) {
        final workflow = workflows[index];
        return WorkflowIconItem(
          icon: workflow.icon,
          title: workflow.title,
          subtitle: '0${workflow.step}',
          color: workflow.color,
          onTap: () {
            // Handle workflow tap
          },
        );
      },
    );
  }
}

class _WorkflowData {
  const _WorkflowData({
    required this.icon,
    required this.title,
    required this.color,
    required this.step,
  });

  final IconData icon;
  final String title;
  final Color color;
  final int step;
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_box_rounded,
            title: 'Захиалга нэмэх',
            color: const Color(0xFF8B5CF6),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.search_rounded,
            title: 'Ачаа хайх',
            color: const Color(0xFF3B82F6),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Нийт захиалга',
            value: '24',
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Хүргэгдсэн',
            value: '18',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Замд яваа',
            value: '6',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFFF59E0B),
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
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFE8ECF4) : const Color(0xFF1E2638),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8B95A8) : const Color(0xFF677186),
            ),
          ),
        ],
      ),
    );
  }
}
