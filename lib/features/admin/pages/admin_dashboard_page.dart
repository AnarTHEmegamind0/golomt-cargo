import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/providers/admin_cargos_provider.dart';
import 'package:core/features/admin/providers/admin_users_provider.dart';
import 'package:core/features/admin/widgets/admin_stat_card.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin dashboard with statistics overview
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
      context.read<AdminCargosProvider>().loadCargos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<AdminUsersProvider>().loadUsers(forceRefresh: true),
          context.read<AdminCargosProvider>().loadCargos(forceRefresh: true),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Тойм',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: BrandPalette.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Өнөөдрийн байдал',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BrandPalette.mutedText),
          ),
          const SizedBox(height: 20),

          // User stats
          _UserStatsSection(),
          const SizedBox(height: 16),

          // Cargo stats
          _CargoStatsSection(),
          const SizedBox(height: 24),

          // Recent activity
          _RecentActivitySection(),
        ],
      ),
    );
  }
}

class _UserStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = provider.users;
    final adminCount = users.where((u) => u.role == UserRole.admin).length;
    final customerCount = users
        .where((u) => u.role == UserRole.customer)
        .length;
    final bannedCount = users.where((u) => u.banned).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Хэрэглэгчид',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: BrandPalette.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Нийт',
                value: users.length.toString(),
                icon: Icons.people_rounded,
                color: BrandPalette.electricBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Админ',
                value: adminCount.toString(),
                icon: Icons.admin_panel_settings_rounded,
                color: BrandPalette.logoOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Хэрэглэгч',
                value: customerCount.toString(),
                icon: Icons.person_rounded,
                color: BrandPalette.navyBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Хориглогдсон',
                value: bannedCount.toString(),
                icon: Icons.block_rounded,
                color: BrandPalette.errorRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CargoStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCargosProvider>();

    if (provider.isLoading && provider.cargos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final cargos = provider.cargos;
    final pendingCount = cargos
        .where((c) => c.status == OrderStatus.pending)
        .length;
    final processingCount = cargos
        .where((c) => c.status == OrderStatus.processing)
        .length;
    final transitCount = cargos
        .where((c) => c.status == OrderStatus.transit)
        .length;
    final deliveredCount = cargos
        .where((c) => c.status == OrderStatus.delivered)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Бараа',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: BrandPalette.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Хүлээгдэж буй',
                value: pendingCount.toString(),
                icon: Icons.schedule_rounded,
                color: const Color(0xFFFBBF24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Боловсруулж буй',
                value: processingCount.toString(),
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                title: 'Тээвэрлэж буй',
                value: transitCount.toString(),
                icon: Icons.local_shipping_rounded,
                color: BrandPalette.electricBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Хүргэгдсэн',
                value: deliveredCount.toString(),
                icon: Icons.check_circle_rounded,
                color: BrandPalette.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cargosProvider = context.watch<AdminCargosProvider>();

    // Get recent cargos (last 5)
    final recentCargos = cargosProvider.cargos.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сүүлийн бараанууд',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: BrandPalette.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (recentCargos.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandPalette.softBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Бараа байхгүй байна',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BrandPalette.mutedText),
              ),
            ),
          )
        else
          ...recentCargos.map((cargo) => _RecentCargoTile(cargo: cargo)),
      ],
    );
  }
}

class _RecentCargoTile extends StatelessWidget {
  const _RecentCargoTile({required this.cargo});

  final Order cargo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cargo.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(cargo.status.icon, color: cargo.status.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cargo.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BrandPalette.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  cargo.trackingCode,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BrandPalette.mutedText,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cargo.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cargo.status.label,
              style: TextStyle(
                color: cargo.status.color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
