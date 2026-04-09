import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin shipment management page
class AdminShipmentsPage extends StatefulWidget {
  const AdminShipmentsPage({super.key});

  @override
  State<AdminShipmentsPage> createState() => _AdminShipmentsPageState();
}

class _AdminShipmentsPageState extends State<AdminShipmentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShipmentsProvider>().loadShipments();
      context.read<AdminVehiclesProvider>().loadVehicles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShipmentsProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ачилт',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: BrandPalette.electricBlue,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: BrandPalette.softBlueBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: BrandPalette.primaryText,
            unselectedLabelColor: BrandPalette.mutedText,
            dividerColor: Colors.transparent,
            tabs: [
              _buildTab(
                'Бэлтгэж',
                provider.getByStatus(ShipmentStatus.draft).length,
                ShipmentStatus.draft.color,
              ),
              _buildTab(
                'Хөдөлсөн',
                provider.getByStatus(ShipmentStatus.departed).length,
                ShipmentStatus.departed.color,
              ),
              _buildTab(
                'Замд',
                provider.getByStatus(ShipmentStatus.inTransit).length,
                ShipmentStatus.inTransit.color,
              ),
              _buildTab(
                'Ирсэн',
                provider.getByStatus(ShipmentStatus.arrived).length,
                ShipmentStatus.arrived.color,
              ),
              _buildTab(
                'Дууссан',
                provider.getByStatus(ShipmentStatus.completed).length,
                ShipmentStatus.completed.color,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: ShipmentStatus.values
                .map((status) => _ShipmentList(status: status))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final vehicles = context.read<AdminVehiclesProvider>().activeVehicles;
    if (vehicles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Эхлээд машин бүртгэнэ үү')));
      return;
    }
    String? selectedVehicleId = vehicles.first.id;
    DateTime? departureDate;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Шинэ ачилт'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedVehicleId,
                decoration: const InputDecoration(labelText: 'Машин'),
                items: vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.id,
                        child: Text('${v.plateNumber} - ${v.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedVehicleId = v),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Гарах огноо'),
                subtitle: Text(
                  departureDate != null
                      ? '${departureDate!.year}/${departureDate!.month}/${departureDate!.day}'
                      : 'Сонгоогүй',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => departureDate = date);
                },
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Тэмдэглэл'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Болих'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedVehicleId == null) return;
                Navigator.pop(ctx);
                this.context.read<AdminShipmentsProvider>().createShipment(
                  vehicleId: selectedVehicleId!,
                  departureDate: departureDate,
                  note: noteController.text.isNotEmpty
                      ? noteController.text
                      : null,
                );
              },
              child: const Text('Үүсгэх'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentList extends StatelessWidget {
  const _ShipmentList({required this.status});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShipmentsProvider>();
    final shipments = provider.getByStatus(status);

    if (provider.isLoading && shipments.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShipIcon(
              ShipAssets.truck,
              size: 64,
              color: BrandPalette.mutedText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '${status.label} ачилт байхгүй',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadShipments(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: shipments.length,
        itemBuilder: (context, index) =>
            _ShipmentCard(shipment: shipments[index]),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminShipmentsProvider>();
    final isProcessing = provider.processingShipmentId == shipment.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: shipment.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ShipIcon(
                    ShipAssets.truck,
                    color: shipment.status.color,
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
                      shipment.vehiclePlateNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      shipment.dateRangeDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: shipment.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  shipment.status.label,
                  style: TextStyle(
                    color: shipment.status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: '${shipment.cargoCount} бараа',
              ),
              const Spacer(),
              if (shipment.status.nextStatuses.isNotEmpty)
                ...shipment.status.nextStatuses.map(
                  (next) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilledButton.tonal(
                      onPressed: isProcessing
                          ? null
                          : () => provider.updateStatus(
                              shipmentId: shipment.id,
                              status: next,
                            ),
                      child: Text(next.label),
                    ),
                  ),
                ),
            ],
          ),
          if (isProcessing) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BrandPalette.softBlueBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BrandPalette.mutedText),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: BrandPalette.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
