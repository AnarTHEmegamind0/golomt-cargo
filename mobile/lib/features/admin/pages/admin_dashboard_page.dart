import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/providers/admin_cargos_provider.dart';
import 'package:core/features/admin/providers/admin_finance_provider.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:core/features/admin/widgets/admin_stat_card.dart';
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
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    final futures = <Future>[
      context.read<AdminCargosProvider>().loadCargos(),
      context.read<AdminShipmentsProvider>().loadShipments(),
      context.read<AdminVehiclesProvider>().loadVehicles(),
      context.read<AdminFinanceProvider>().loadSummary(),
    ];
    await Future.wait(futures);
  }

  Future<void> _refreshAllData() async {
    final futures = <Future>[
      context.read<AdminCargosProvider>().loadCargos(forceRefresh: true),
      context.read<AdminShipmentsProvider>().loadShipments(forceRefresh: true),
      context.read<AdminVehiclesProvider>().loadVehicles(forceRefresh: true),
      context.read<AdminFinanceProvider>().loadSummary(forceRefresh: true),
    ];
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BrandPalette.mutedText,
            ),
          ),
          const SizedBox(height: 20),

          // Financial overview
          const _FinanceOverviewSection(),
          const SizedBox(height: 24),

          // Quick stats row
          const _QuickStatsRow(),
          const SizedBox(height: 24),

          // Cargo stats
          const _CargoStatsSection(),
          const SizedBox(height: 24),

          // Shipment stats
          const _ShipmentStatsSection(),
          const SizedBox(height: 24),

          // Recent activity
          const _RecentActivitySection(),
        ],
      ),
    );
  }
}

/// Financial overview cards
class _FinanceOverviewSection extends StatelessWidget {
  const _FinanceOverviewSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminFinanceProvider>();
    final summary = provider.summary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BrandPalette.electricBlue,
            BrandPalette.electricBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShipIcon(ShipAssets.wallet, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                'Санхүүгийн тойм',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else ...[
            Text(
              summary.totalRevenueDisplay,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Нийт орлого',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _FinanceMiniCard(
                    label: 'Төлсөн',
                    value: summary.paidAmountDisplay,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinanceMiniCard(
                    label: 'Төлөөгүй',
                    value: summary.unpaidAmountDisplay,
                    icon: Icons.pending_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinanceMiniCard(
                    label: 'Цуглуулалт',
                    value: '${summary.collectionRate.toStringAsFixed(0)}%',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FinanceMiniCard extends StatelessWidget {
  const _FinanceMiniCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Quick stats row (vehicles, total cargos, shipments)
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    final vehiclesProvider = context.watch<AdminVehiclesProvider>();
    final cargosProvider = context.watch<AdminCargosProvider>();
    final shipmentsProvider = context.watch<AdminShipmentsProvider>();

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: ShipAssets.car,
            value: '${vehiclesProvider.activeVehicles.length}',
            label: 'Машин',
            color: BrandPalette.navyBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: ShipAssets.boxReturn,
            value: '${cargosProvider.cargos.length}',
            label: 'Нийт карго',
            color: BrandPalette.logoOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: ShipAssets.truck,
            value: '${shipmentsProvider.shipments.length}',
            label: 'Ачилт',
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final String icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ShipIcon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: BrandPalette.primaryText,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BrandPalette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cargo stats by status
class _CargoStatsSection extends StatelessWidget {
  const _CargoStatsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCargosProvider>();

    if (provider.isLoading && provider.cargos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final cargos = provider.cargos;
    final pendingCount = cargos.where((c) => c.status == OrderStatus.pending).length;
    final processingCount = cargos.where((c) => c.status == OrderStatus.processing).length;
    final transitCount = cargos.where((c) => c.status == OrderStatus.transit).length;
    final deliveredCount = cargos.where((c) => c.status == OrderStatus.delivered).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Бараа төлөв',
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
                assetPath: ShipAssets.clockAndHome,
                color: const Color(0xFFFBBF24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Боловсруулж буй',
                value: processingCount.toString(),
                assetPath: ShipAssets.delivery,
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
                assetPath: ShipAssets.truck,
                color: BrandPalette.electricBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                title: 'Хүргэгдсэн',
                value: deliveredCount.toString(),
                assetPath: ShipAssets.mailArrivedAndHand,
                color: BrandPalette.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shipment stats by status
class _ShipmentStatsSection extends StatelessWidget {
  const _ShipmentStatsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShipmentsProvider>();

    if (provider.isLoading && provider.shipments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ачилт төлөв',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: BrandPalette.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ShipmentStatus.values.map((status) {
            final count = provider.getByStatus(status).length;
            return _ShipmentStatusChip(status: status, count: count);
          }).toList(),
        ),
      ],
    );
  }
}

class _ShipmentStatusChip extends StatelessWidget {
  const _ShipmentStatusChip({required this.status, required this.count});

  final ShipmentStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent cargo activity
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final cargosProvider = context.watch<AdminCargosProvider>();
    final recentCargos = cargosProvider.cargos.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сүүлийн каргонууд',
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrandPalette.mutedText,
                ),
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
            child: ShipIcon(
              cargo.status.shipAsset,
              color: cargo.status.color,
              size: 18,
            ),
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
