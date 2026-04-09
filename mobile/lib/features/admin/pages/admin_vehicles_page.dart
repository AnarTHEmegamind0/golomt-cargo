import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin vehicle management page
class AdminVehiclesPage extends StatefulWidget {
  const AdminVehiclesPage({super.key});

  @override
  State<AdminVehiclesPage> createState() => _AdminVehiclesPageState();
}

class _AdminVehiclesPageState extends State<AdminVehiclesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminVehiclesProvider>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminVehiclesProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ачилтын машин',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BrandPalette.primaryText,
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadVehicles(forceRefresh: true),
            child: provider.isLoading && provider.vehicles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.vehicles.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: provider.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return _VehicleCard(
                        vehicle: vehicle,
                        isProcessing:
                            provider.processingVehicleId == vehicle.id,
                        onToggleActive: () => provider.toggleActive(vehicle.id),
                        onEdit: () => _showEditDialog(context, vehicle),
                        onDelete: () => _showDeleteConfirm(context, vehicle),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShipIcon(
            ShipAssets.car,
            size: 64,
            color: BrandPalette.mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Машин байхгүй',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final plateController = TextEditingController();
    final nameController = TextEditingController();
    var selectedType = VehicleType.truck;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Шинэ машин'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Дугаар',
                  hintText: '1234УБА',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Нэр'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VehicleType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Төрөл'),
                items: VehicleType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (t) {
                  if (t != null) setState(() => selectedType = t);
                },
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
                if (plateController.text.isEmpty) return;
                Navigator.pop(ctx);
                this.context.read<AdminVehiclesProvider>().createVehicle(
                  plateNumber: plateController.text.trim(),
                  name: nameController.text.trim(),
                  type: selectedType,
                );
              },
              child: const Text('Үүсгэх'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Vehicle vehicle) {
    final plateController = TextEditingController(text: vehicle.plateNumber);
    final nameController = TextEditingController(text: vehicle.name);
    var selectedType = vehicle.type;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Машин засах'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Дугаар'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Нэр'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VehicleType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Төрөл'),
                items: VehicleType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (t) {
                  if (t != null) setState(() => selectedType = t);
                },
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
                Navigator.pop(ctx);
                this.context.read<AdminVehiclesProvider>().updateVehicle(
                  vehicleId: vehicle.id,
                  plateNumber: plateController.text.trim(),
                  name: nameController.text.trim(),
                  type: selectedType,
                );
              },
              child: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Машин устгах'),
        content: Text('${vehicle.plateNumber} машиныг устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              this.context.read<AdminVehiclesProvider>().deleteVehicle(
                vehicle.id,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: BrandPalette.errorRed,
            ),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.isProcessing,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });
  final Vehicle vehicle;
  final bool isProcessing;
  final VoidCallback onToggleActive, onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vehicle.isActive
              ? const Color(0xFFE5E9F2)
              : BrandPalette.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BrandPalette.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: ShipIcon(
                    ShipAssets.car,
                    color: BrandPalette.electricBlue,
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
                      vehicle.plateNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      vehicle.name,
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
                  color: BrandPalette.navyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vehicle.type.label,
                  style: const TextStyle(
                    color: BrandPalette.navyBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      (vehicle.isActive
                              ? BrandPalette.successGreen
                              : BrandPalette.errorRed)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vehicle.isActive ? 'Идэвхтэй' : 'Идэвхгүй',
                  style: TextStyle(
                    color: vehicle.isActive
                        ? BrandPalette.successGreen
                        : BrandPalette.errorRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: isProcessing ? null : onToggleActive,
                icon: Icon(
                  vehicle.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
              ),
              IconButton(
                onPressed: isProcessing ? null : onEdit,
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  foregroundColor: BrandPalette.electricBlue,
                ),
              ),
              IconButton(
                onPressed: isProcessing ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: BrandPalette.errorRed,
                ),
              ),
            ],
          ),
          if (isProcessing) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
