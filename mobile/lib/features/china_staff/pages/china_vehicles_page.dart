import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/vehicle.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// China staff vehicle management page
class ChinaVehiclesPage extends StatefulWidget {
  const ChinaVehiclesPage({super.key});

  @override
  State<ChinaVehiclesPage> createState() => _ChinaVehiclesPageState();
}

class _ChinaVehiclesPageState extends State<ChinaVehiclesPage> {
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
                  'Машин',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: BrandPalette.logoOrange,
                ),
              ),
            ],
          ),
        ),

        // Error display
        if (provider.error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrandPalette.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: BrandPalette.errorRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: BrandPalette.errorRed),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: provider.clearError,
                  iconSize: 18,
                ),
              ],
            ),
          ),

        // Vehicle list
        Expanded(
          child: provider.isLoading && provider.vehicles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.vehicles.isEmpty
                  ? _EmptyState(onAdd: () => _showCreateDialog(context))
                  : RefreshIndicator(
                      onRefresh: () => provider.loadVehicles(forceRefresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: provider.vehicles.length,
                        itemBuilder: (context, index) => _VehicleCard(
                          vehicle: provider.vehicles[index],
                          onEdit: () => _showEditDialog(context, provider.vehicles[index]),
                          onToggle: () => provider.toggleActive(provider.vehicles[index].id),
                          onDelete: () => _confirmDelete(context, provider.vehicles[index]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final plateController = TextEditingController();
    final nameController = TextEditingController();
    VehicleType selectedType = VehicleType.truck;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Шинэ машин'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Улсын дугаар',
                    hintText: '1234УБА',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Нэр / тайлбар',
                    hintText: 'Ачааны машин #1',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VehicleType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Төрөл'),
                  items: VehicleType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Болих'),
            ),
            FilledButton(
              onPressed: () {
                if (plateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Улсын дугаар оруулна уу')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                this.context.read<AdminVehiclesProvider>().createVehicle(
                  plateNumber: plateController.text.trim(),
                  name: nameController.text.trim().isEmpty
                      ? plateController.text.trim()
                      : nameController.text.trim(),
                  type: selectedType,
                );
              },
              style: FilledButton.styleFrom(backgroundColor: BrandPalette.logoOrange),
              child: const Text('Бүртгэх'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Vehicle vehicle) {
    final plateController = TextEditingController(text: vehicle.plateNumber);
    final nameController = TextEditingController(text: vehicle.name);
    VehicleType selectedType = vehicle.type;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Машин засах'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: plateController,
                  decoration: const InputDecoration(labelText: 'Улсын дугаар'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Нэр / тайлбар'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VehicleType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Төрөл'),
                  items: VehicleType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ],
            ),
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
              style: FilledButton.styleFrom(backgroundColor: BrandPalette.logoOrange),
              child: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Vehicle vehicle) {
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
              this.context.read<AdminVehiclesProvider>().deleteVehicle(vehicle.id);
            },
            style: FilledButton.styleFrom(backgroundColor: BrandPalette.errorRed),
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
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminVehiclesProvider>();
    final isProcessing = provider.processingVehicleId == vehicle.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: vehicle.isActive
                      ? BrandPalette.logoOrange.withValues(alpha: 0.1)
                      : BrandPalette.mutedText.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ShipIcon(
                    _getVehicleIcon(vehicle.type),
                    color: vehicle.isActive
                        ? BrandPalette.logoOrange
                        : BrandPalette.mutedText,
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
                        color: vehicle.isActive
                            ? BrandPalette.primaryText
                            : BrandPalette.mutedText,
                      ),
                    ),
                    Text(
                      '${vehicle.name} - ${vehicle.type.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: vehicle.isActive
                      ? BrandPalette.successGreen.withValues(alpha: 0.1)
                      : BrandPalette.mutedText.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vehicle.isActive ? 'Идэвхтэй' : 'Идэвхгүй',
                  style: TextStyle(
                    color: vehicle.isActive
                        ? BrandPalette.successGreen
                        : BrandPalette.mutedText,
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
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Засах'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : onToggle,
                  icon: Icon(
                    vehicle.isActive ? Icons.pause_outlined : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(vehicle.isActive ? 'Зогсоох' : 'Идэвхжүүлэх'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isProcessing ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
                color: BrandPalette.errorRed,
                style: IconButton.styleFrom(
                  backgroundColor: BrandPalette.errorRed.withValues(alpha: 0.1),
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

  String _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.truck:
        return ShipAssets.truck;
      case VehicleType.van:
        return ShipAssets.car;
      case VehicleType.container:
        return ShipAssets.boxReturn;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShipIcon(
            ShipAssets.car,
            size: 64,
            color: BrandPalette.mutedText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Машин бүртгэгдээгүй',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BrandPalette.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Машин бүртгэх'),
            style: FilledButton.styleFrom(
              backgroundColor: BrandPalette.logoOrange,
            ),
          ),
        ],
      ),
    );
  }
}
