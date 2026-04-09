import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/core/services/export_service.dart';
import 'package:core/features/admin/models/shipment.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:core/features/china_staff/providers/china_cargo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// China staff shipment detail page - view and manage cargos in a shipment
class ChinaShipmentDetailPage extends StatefulWidget {
  const ChinaShipmentDetailPage({super.key, required this.shipment});

  final Shipment shipment;

  @override
  State<ChinaShipmentDetailPage> createState() =>
      _ChinaShipmentDetailPageState();
}

class _ChinaShipmentDetailPageState extends State<ChinaShipmentDetailPage> {
  late Shipment _shipment;
  final _barcodeController = TextEditingController();
  final _barcodeFocusNode = FocusNode();
  final _selectedCargoIds = <String>{};
  bool _isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _shipment = widget.shipment;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShipmentsProvider>().loadShipmentDetails(_shipment.id);
      context.read<ChinaCargoProvider>().loadCargos();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<AdminShipmentsProvider>();
    final cargoProvider = context.watch<ChinaCargoProvider>();

    // Update local shipment when provider updates
    if (shipmentProvider.selectedShipment?.id == _shipment.id) {
      _shipment = shipmentProvider.selectedShipment!;
    }

    // Get cargos in this shipment
    final shipmentCargos = cargoProvider.cargos
        .where((c) => _shipment.cargoIds.contains(c.id))
        .toList();

    return Scaffold(
      backgroundColor: BrandPalette.softBlueBackground,
      appBar: AppBar(
        title: Text(_shipment.vehiclePlateNumber),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              try {
                final exportService = context.read<ExportService>();
                final result = value == 'pdf'
                    ? await exportService.exportShipmentPdf(_shipment.id)
                    : await exportService.exportShipmentXlsx(_shipment.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result.message)));
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString().replaceFirst('Exception: ', ''),
                      ),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
              PopupMenuItem(value: 'xlsx', child: Text('Export Excel')),
            ],
          ),
          if (_shipment.status == ShipmentStatus.draft)
            IconButton(
              onPressed: () => _showAddCargoDialog(context),
              icon: const Icon(Icons.add),
              tooltip: 'Бараа нэмэх',
            ),
        ],
      ),
      body: Column(
        children: [
          // Shipment info header
          _ShipmentHeader(
            shipment: _shipment,
            onStatusChange: (status) => _updateStatus(context, status),
          ),

          // Cargo list
          Expanded(
            child: shipmentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : shipmentCargos.isEmpty
                ? _EmptyCargoState(
                    onAddCargo: _shipment.status == ShipmentStatus.draft
                        ? () => _showAddCargoDialog(context)
                        : null,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${shipmentCargos.length} бараа',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (_shipment.status == ShipmentStatus.draft)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isSelectMode = !_isSelectMode;
                                    if (!_isSelectMode) {
                                      _selectedCargoIds.clear();
                                    }
                                  });
                                },
                                icon: Icon(
                                  _isSelectMode ? Icons.close : Icons.checklist,
                                  size: 18,
                                ),
                                label: Text(_isSelectMode ? 'Болих' : 'Сонгох'),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: shipmentCargos.length,
                          itemBuilder: (context, index) => _CargoCard(
                            cargo: shipmentCargos[index],
                            isSelectMode: _isSelectMode,
                            isSelected: _selectedCargoIds.contains(
                              shipmentCargos[index].id,
                            ),
                            onSelect: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCargoIds.add(
                                    shipmentCargos[index].id,
                                  );
                                } else {
                                  _selectedCargoIds.remove(
                                    shipmentCargos[index].id,
                                  );
                                }
                              });
                            },
                            onRemove: _shipment.status == ShipmentStatus.draft
                                ? () => _removeCargo(
                                    context,
                                    shipmentCargos[index].id,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Selection action bar
          if (_isSelectMode && _selectedCargoIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E9F2))),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedCargoIds.length} сонгосон',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _removeSelectedCargos(context),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Хасах'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BrandPalette.errorRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    ShipmentStatus status,
  ) async {
    final success = await context.read<AdminShipmentsProvider>().updateStatus(
      shipmentId: _shipment.id,
      status: status,
    );
    if (success && context.mounted) {
      await context.read<ChinaCargoProvider>().loadCargos(forceRefresh: true);
    }
  }

  void _removeCargo(BuildContext context, String cargoId) async {
    final shipmentsProvider = context.read<AdminShipmentsProvider>();
    final cargoProvider = context.read<ChinaCargoProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Бараа хасах'),
        content: const Text('Энэ барааг ачилтаас хасах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: BrandPalette.errorRed,
            ),
            child: const Text('Хасах'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await shipmentsProvider.removeCargos(
        shipmentId: _shipment.id,
        cargoIds: [cargoId],
      );
      if (success && mounted) {
        cargoProvider.unassignCargoFromShipment(cargoId);
      }
    }
  }

  void _removeSelectedCargos(BuildContext context) async {
    final shipmentsProvider = context.read<AdminShipmentsProvider>();
    final cargoProvider = context.read<ChinaCargoProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Бараа хасах'),
        content: Text('${_selectedCargoIds.length} барааг ачилтаас хасах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: BrandPalette.errorRed,
            ),
            child: const Text('Хасах'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final cargoIds = _selectedCargoIds.toList();
      final success = await shipmentsProvider.removeCargos(
        shipmentId: _shipment.id,
        cargoIds: cargoIds,
      );
      if (success && mounted) {
        for (final cargoId in cargoIds) {
          cargoProvider.unassignCargoFromShipment(cargoId);
        }
        setState(() {
          _selectedCargoIds.clear();
          _isSelectMode = false;
        });
      }
    }
  }

  void _showAddCargoDialog(BuildContext context) {
    final cargoProvider = context.read<ChinaCargoProvider>();
    final unassignedCargos = cargoProvider.unassignedCargos;
    final selectedIds = <String>{};
    final scannedCodes = <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Бараа нэмэх',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Barcode scan input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Barcode уншуулна уу...',
                    prefixIcon: const Icon(Icons.qr_code_scanner),
                    filled: true,
                    fillColor: BrandPalette.softBlueBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    final code = value.trim();
                    if (code.isNotEmpty && !scannedCodes.contains(code)) {
                      // Find cargo by tracking number
                      final cargo = unassignedCargos.firstWhere(
                        (c) => c.trackingNumber == code,
                        orElse: () => CargoModel(
                          id: '',
                          trackingNumber: code,
                          status: CargoStatus.created,
                          paymentStatus: PaymentStatus.unpaid,
                        ),
                      );
                      if (cargo.id.isNotEmpty) {
                        setState(() {
                          selectedIds.add(cargo.id);
                          scannedCodes.add(code);
                        });
                        HapticFeedback.mediumImpact();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$code - бараа олдсонгүй')),
                        );
                      }
                    }
                    _barcodeController.clear();
                    _barcodeFocusNode.requestFocus();
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Scanned/selected count
              if (selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BrandPalette.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: BrandPalette.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedIds.length} бараа сонгосон',
                          style: const TextStyle(
                            color: BrandPalette.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {
                            selectedIds.clear();
                            scannedCodes.clear();
                          }),
                          child: const Text('Цэвэрлэх'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Unassigned cargo list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Ачилтгүй бараанууд (${unassignedCargos.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: unassignedCargos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShipIcon(
                              ShipAssets.boxReturn,
                              size: 48,
                              color: BrandPalette.mutedText.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ачилтгүй бараа байхгүй',
                              style: TextStyle(color: BrandPalette.mutedText),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: unassignedCargos.length,
                        itemBuilder: (ctx, index) {
                          final cargo = unassignedCargos[index];
                          final isSelected = selectedIds.contains(cargo.id);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? BrandPalette.logoOrange.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? BrandPalette.logoOrange
                                    : const Color(0xFFE5E9F2),
                              ),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      selectedIds.add(cargo.id);
                                    } else {
                                      selectedIds.remove(cargo.id);
                                    }
                                  });
                                },
                                activeColor: BrandPalette.logoOrange,
                              ),
                              title: Text(
                                cargo.trackingNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                cargo.weightGrams != null
                                    ? '${(cargo.weightGrams! / 1000).toStringAsFixed(2)} кг'
                                    : 'Жин бүртгэгдээгүй',
                                style: TextStyle(
                                  color: BrandPalette.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedIds.remove(cargo.id);
                                  } else {
                                    selectedIds.add(cargo.id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),

              // Add button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E9F2))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: selectedIds.isEmpty
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            await _addCargosToShipment(selectedIds.toList());
                          },
                    icon: const Icon(Icons.add),
                    label: Text(
                      selectedIds.isEmpty
                          ? 'Бараа сонгоно уу'
                          : '${selectedIds.length} бараа нэмэх',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: BrandPalette.logoOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCargosToShipment(List<String> cargoIds) async {
    final shipmentProvider = context.read<AdminShipmentsProvider>();
    final cargoProvider = context.read<ChinaCargoProvider>();

    final success = await shipmentProvider.addCargos(
      shipmentId: _shipment.id,
      cargoIds: cargoIds,
    );

    if (success && mounted) {
      // Update local cargo assignments
      for (final cargoId in cargoIds) {
        cargoProvider.assignCargoToShipment(cargoId, _shipment.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cargoIds.length} бараа нэмэгдлээ'),
          backgroundColor: BrandPalette.successGreen,
        ),
      );
    }
  }
}

class _ShipmentHeader extends StatelessWidget {
  const _ShipmentHeader({required this.shipment, required this.onStatusChange});

  final Shipment shipment;
  final void Function(ShipmentStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: shipment.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: ShipIcon(
                    ShipAssets.truck,
                    color: shipment.status.color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.vehiclePlateNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shipment.dateRangeDisplay,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
                  ),
                ),
              ),
            ],
          ),
          if (shipment.note != null && shipment.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BrandPalette.softBlueBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shipment.note!,
                style: TextStyle(color: BrandPalette.mutedText),
              ),
            ),
          ],
          if (shipment.status.nextStatuses.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: shipment.status.nextStatuses
                  .map(
                    (next) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilledButton(
                          onPressed: () => onStatusChange(next),
                          style: FilledButton.styleFrom(
                            backgroundColor: next.color,
                          ),
                          child: Text(next.label),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CargoCard extends StatelessWidget {
  const _CargoCard({
    required this.cargo,
    required this.isSelectMode,
    required this.isSelected,
    required this.onSelect,
    this.onRemove,
  });

  final CargoModel cargo;
  final bool isSelectMode;
  final bool isSelected;
  final void Function(bool) onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? BrandPalette.logoOrange.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? BrandPalette.logoOrange : const Color(0xFFE5E9F2),
        ),
      ),
      child: Row(
        children: [
          if (isSelectMode)
            Checkbox(
              value: isSelected,
              onChanged: (v) => onSelect(v ?? false),
              activeColor: BrandPalette.logoOrange,
            ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BrandPalette.softBlueBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: ShipIcon(
                ShipAssets.boxReturn,
                color: BrandPalette.mutedText,
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
                  cargo.trackingNumber,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (cargo.weightGrams != null)
                      Text(
                        '${(cargo.weightGrams! / 1000).toStringAsFixed(2)} кг',
                        style: TextStyle(
                          color: BrandPalette.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    if (cargo.hasDimensions) ...[
                      Text(
                        ' | ${cargo.dimensionsDisplay}',
                        style: TextStyle(
                          color: BrandPalette.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null && !isSelectMode)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: BrandPalette.errorRed,
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}

class _EmptyCargoState extends StatelessWidget {
  const _EmptyCargoState({this.onAddCargo});

  final VoidCallback? onAddCargo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShipIcon(
            ShipAssets.boxReturn,
            size: 64,
            color: BrandPalette.mutedText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Бараа байхгүй',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
          ),
          const SizedBox(height: 4),
          Text(
            'Энэ ачилтанд бараа нэмээгүй байна',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BrandPalette.mutedText),
          ),
          if (onAddCargo != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddCargo,
              icon: const Icon(Icons.add),
              label: const Text('Бараа нэмэх'),
              style: FilledButton.styleFrom(
                backgroundColor: BrandPalette.logoOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
