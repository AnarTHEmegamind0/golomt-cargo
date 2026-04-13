import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Model for grouped user cargos
class _UserCargoGroup {
  const _UserCargoGroup({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cargos,
  });

  final String userId;
  final String userName;
  final String userEmail;
  final List<CargoModel> cargos;

  int get cargoCount => cargos.length;

  double get totalWeight => cargos.fold(
    0.0,
    (sum, cargo) => sum + (cargo.weightGrams ?? 0) / 1000,
  );

  int get totalFee => cargos.fold(
    0,
    (sum, cargo) => sum + cargo.finalFeeMnt,
  );
}

/// Page showing shipment details - users who have cargos in this shipment
class AdminShipmentDetailPage extends StatefulWidget {
  const AdminShipmentDetailPage({super.key, required this.shipment});

  final Shipment shipment;

  @override
  State<AdminShipmentDetailPage> createState() =>
      _AdminShipmentDetailPageState();
}

class _AdminShipmentDetailPageState extends State<AdminShipmentDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShipmentsProvider>().loadShipmentCargos(widget.shipment.id);
    });
  }

  List<_UserCargoGroup> _groupCargosByUser(List<CargoModel> cargos) {
    final Map<String, List<CargoModel>> grouped = {};

    for (final cargo in cargos) {
      final customerId = cargo.customer?.id ?? 'unknown';
      grouped.putIfAbsent(customerId, () => []);
      grouped[customerId]!.add(cargo);
    }

    return grouped.entries.map((entry) {
      final cargos = entry.value;
      final customer = cargos.first.customer;
      return _UserCargoGroup(
        userId: entry.key,
        userName: customer?.name ?? 'Хэрэглэгч',
        userEmail: customer?.email ?? '',
        cargos: cargos,
      );
    }).toList()
      ..sort((a, b) => b.cargoCount.compareTo(a.cargoCount));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShipmentsProvider>();

    return Scaffold(
      backgroundColor: BrandPalette.softBlueBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shipment.vehiclePlateNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              widget.shipment.dateRangeDisplay,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BrandPalette.mutedText,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.shipment.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.shipment.status.label,
              style: TextStyle(
                color: widget.shipment.status.color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Shipment info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.shipment.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: ShipIcon(
                      ShipAssets.truck,
                      color: widget.shipment.status.color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Хэрэглэгчид',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${widget.shipment.cargoCount} бараа',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrandPalette.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // User list
          Expanded(
            child: _buildUserList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context, AdminShipmentsProvider provider) {
    if (provider.isLoadingCargos) {
      return const Center(child: CircularProgressIndicator());
    }

    final cargos = provider.shipmentCargos;

    if (cargos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: BrandPalette.mutedText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Энэ ачилтад бараа байхгүй',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BrandPalette.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    final userGroups = _groupCargosByUser(cargos);

    return RefreshIndicator(
      onRefresh: () => provider.loadShipmentCargos(widget.shipment.id),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userGroups.length,
        itemBuilder: (context, index) {
          final group = userGroups[index];
          return _UserCard(
            group: group,
            shipment: widget.shipment,
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.group,
    required this.shipment,
  });

  final _UserCargoGroup group;
  final Shipment shipment;

  void _openUserCargos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => _UserCargosPage(
          group: group,
          shipment: shipment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openUserCargos(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E9F2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BrandPalette.electricBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    group.userName.isNotEmpty
                        ? group.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: BrandPalette.electricBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.userName.isNotEmpty ? group.userName : 'Хэрэглэгч',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (group.userEmail.isNotEmpty)
                      Text(
                        group.userEmail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrandPalette.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BrandPalette.electricBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${group.cargoCount} бараа',
                      style: const TextStyle(
                        color: BrandPalette.electricBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.totalWeight.toStringAsFixed(2)} кг',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BrandPalette.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: BrandPalette.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page showing a user's cargos in the shipment
class _UserCargosPage extends StatelessWidget {
  const _UserCargosPage({
    required this.group,
    required this.shipment,
  });

  final _UserCargoGroup group;
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandPalette.softBlueBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.userName.isNotEmpty ? group.userName : 'Хэрэглэгч',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              shipment.vehiclePlateNumber,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BrandPalette.mutedText,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                _SummaryChip(
                  icon: Icons.inventory_2_outlined,
                  label: '${group.cargoCount} бараа',
                  color: BrandPalette.electricBlue,
                ),
                const SizedBox(width: 12),
                _SummaryChip(
                  icon: Icons.scale_rounded,
                  label: '${group.totalWeight.toStringAsFixed(2)} кг',
                  color: BrandPalette.logoOrange,
                ),
                const SizedBox(width: 12),
                _SummaryChip(
                  icon: Icons.attach_money_rounded,
                  label: '${group.totalFee}₮',
                  color: BrandPalette.successGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Cargo list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: group.cargos.length,
              itemBuilder: (context, index) {
                final cargo = group.cargos[index];
                return _CargoCard(cargo: cargo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CargoCard extends StatelessWidget {
  const _CargoCard({required this.cargo});
  final CargoModel cargo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cargo.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ShipIcon(
                    cargo.status.shipAsset,
                    color: cargo.status.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cargo.description?.trim().isNotEmpty == true
                          ? cargo.description!.trim()
                          : 'Cargo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrandPalette.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cargo.trackingNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cargo.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cargo.status.label,
                  style: TextStyle(
                    color: cargo.status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.scale_rounded,
                label: cargo.weightGrams != null
                    ? '${cargo.weightKg.toStringAsFixed(2)} кг'
                    : '- кг',
              ),
              _InfoChip(
                icon: Icons.straighten_rounded,
                label: cargo.dimensionsDisplay,
              ),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label: cargo.finalFeeMnt > 0 ? '${cargo.finalFeeMnt}₮' : '-₮',
              ),
              _InfoChip(
                icon: cargo.paymentStatus == PaymentStatus.paid
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                label: cargo.paymentStatus.label,
                color: cargo.paymentStatus == PaymentStatus.paid
                    ? BrandPalette.successGreen
                    : BrandPalette.logoOrange,
              ),
              if (cargo.isFragile)
                const _InfoChip(
                  icon: Icons.warning_amber_rounded,
                  label: 'Эмзэг',
                  color: BrandPalette.errorRed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = BrandPalette.mutedText,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
