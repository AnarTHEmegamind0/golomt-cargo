import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:core/features/china_staff/providers/china_cargo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// China staff dashboard with overview stats
class ChinaDashboardPage extends StatefulWidget {
  const ChinaDashboardPage({super.key});

  @override
  State<ChinaDashboardPage> createState() => _ChinaDashboardPageState();
}

class _ChinaDashboardPageState extends State<ChinaDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChinaCargoProvider>().loadCargos();
      context.read<AdminShipmentsProvider>().loadShipments();
      context.read<AdminVehiclesProvider>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cargoProvider = context.watch<ChinaCargoProvider>();
    final shipmentProvider = context.watch<AdminShipmentsProvider>();
    final vehicleProvider = context.watch<AdminVehiclesProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          cargoProvider.loadCargos(forceRefresh: true),
          shipmentProvider.loadShipments(forceRefresh: true),
          vehicleProvider.loadVehicles(forceRefresh: true),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Өнөөдрийн тойм',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _StatCard(
                  title: 'Хүлээн авсан',
                  value: '${cargoProvider.receivedCargos.length}',
                  subtitle: 'бараа',
                  icon: ShipAssets.boxReturn,
                  color: BrandPalette.successGreen,
                ),
                _StatCard(
                  title: 'Ачилтанд бэлэн',
                  value: '${cargoProvider.readyForShipmentCargos.length}',
                  subtitle: 'бараа',
                  icon: ShipAssets.truck,
                  color: BrandPalette.electricBlue,
                ),
                _StatCard(
                  title: 'Бэлтгэж буй',
                  value:
                      '${shipmentProvider.getByStatus(ShipmentStatus.draft).length}',
                  subtitle: 'ачилт',
                  icon: ShipAssets.clockAndHome,
                  color: BrandPalette.logoOrange,
                ),
                _StatCard(
                  title: 'Идэвхтэй машин',
                  value: '${vehicleProvider.activeVehicles.length}',
                  subtitle: 'машин',
                  icon: ShipAssets.car,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent shipments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Сүүлийн ачилтууд',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (shipmentProvider.shipments.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to shipments tab - handled by parent
                    },
                    child: const Text('Бүгд'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (shipmentProvider.isLoading &&
                shipmentProvider.shipments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (shipmentProvider.shipments.isEmpty)
              _EmptyState(
                icon: ShipAssets.truck,
                title: 'Ачилт байхгүй',
                subtitle: 'Шинэ ачилт үүсгэхийн тулд "Ачилт" хэсэгт очно уу',
              )
            else
              ...shipmentProvider.shipments
                  .take(3)
                  .map((shipment) => _ShipmentItem(shipment: shipment)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ShipIcon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: BrandPalette.primaryText,
            ),
          ),
          Text(
            '$title $subtitle',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BrandPalette.mutedText,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ShipmentItem extends StatelessWidget {
  const _ShipmentItem({required this.shipment});
  final Shipment shipment;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: shipment.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: ShipIcon(
                ShipAssets.truck,
                color: shipment.status.color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shipment.vehiclePlateNumber,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '${shipment.cargoCount} бараа',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BrandPalette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: shipment.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              shipment.status.label,
              style: TextStyle(
                color: shipment.status.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        children: [
          ShipIcon(
            icon,
            size: 48,
            color: BrandPalette.mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BrandPalette.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
