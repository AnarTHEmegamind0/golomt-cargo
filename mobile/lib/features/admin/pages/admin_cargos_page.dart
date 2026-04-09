import 'dart:async';

import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/admin/providers/admin_cargos_provider.dart';
import 'package:core/features/admin/widgets/admin_cargo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows an error dialog with the given message
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.error_outline_rounded,
        color: BrandPalette.errorRed,
        size: 48,
      ),
      title: const Text('Алдаа гарлаа'),
      content: Text(
        message,
        style: Theme.of(dialogContext).textTheme.bodyMedium,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ойлголоо'),
        ),
      ],
    ),
  );
}

/// Admin cargo management page with status flow
class AdminCargosPage extends StatefulWidget {
  const AdminCargosPage({super.key});

  @override
  State<AdminCargosPage> createState() => _AdminCargosPageState();
}

class _AdminCargosPageState extends State<AdminCargosPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String? _lastShownError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCargosProvider>().loadCargos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final provider = context.read<AdminCargosProvider>();
    if (query.trim().isEmpty) {
      provider.loadCargos(forceRefresh: true);
    } else {
      provider.searchCargos(query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {});
    context.read<AdminCargosProvider>().loadCargos(forceRefresh: true);
  }

  void _checkAndShowError(AdminCargosProvider provider) {
    final error = provider.error;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog(context, error);
          provider.clearError();
        }
      });
    } else if (error == null) {
      _lastShownError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCargosProvider>();

    // Check for errors and show dialog
    _checkAndShowError(provider);

    return Column(
      children: [
        // Header with search
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Бараа удирдлага',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: BrandPalette.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Трак код, утас, барааны нэрээр хайх...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: 'Цэвэрлэх',
                        ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () =>
                              _performSearch(_searchController.text),
                          icon: const Icon(Icons.search_rounded),
                          tooltip: 'Хайх',
                        ),
                    ],
                  ),
                  filled: true,
                  fillColor: BrandPalette.softBlueBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _onSearchChanged,
                onSubmitted: _performSearch,
                textInputAction: TextInputAction.search,
              ),
            ],
          ),
        ),

        // Status tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: BrandPalette.softBlueBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: BrandPalette.primaryText,
            unselectedLabelColor: BrandPalette.mutedText,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              _StatusTab(
                label: 'Хүлээж',
                count: provider.pendingCargos.length,
                color: const Color(0xFFFBBF24),
              ),
              _StatusTab(
                label: 'Бэлтгэж',
                count: provider.processingCargos.length,
                color: const Color(0xFF8B5CF6),
              ),
              _StatusTab(
                label: 'Замд',
                count: provider.transitCargos.length,
                color: BrandPalette.electricBlue,
              ),
              _StatusTab(
                label: 'Ирсэн',
                count: provider.deliveredCargos.length,
                color: BrandPalette.successGreen,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Cargo list
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CargoList(
                cargos: provider.pendingCargos,
                isLoading: provider.isLoading,
                processingCargoId: provider.processingCargoId,
                emptyMessage: 'Хүлээгдэж буй бараа байхгүй',
              ),
              _CargoList(
                cargos: provider.processingCargos,
                isLoading: provider.isLoading,
                processingCargoId: provider.processingCargoId,
                emptyMessage: 'Боловсруулж буй бараа байхгүй',
              ),
              _CargoList(
                cargos: provider.transitCargos,
                isLoading: provider.isLoading,
                processingCargoId: provider.processingCargoId,
                emptyMessage: 'Тээвэрлэж буй бараа байхгүй',
              ),
              _CargoList(
                cargos: provider.deliveredCargos,
                isLoading: provider.isLoading,
                processingCargoId: provider.processingCargoId,
                emptyMessage: 'Хүргэгдсэн бараа байхгүй',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            if (count > 0) ...[
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CargoList extends StatelessWidget {
  const _CargoList({
    required this.cargos,
    required this.isLoading,
    required this.processingCargoId,
    required this.emptyMessage,
  });

  final List<CargoModel> cargos;
  final bool isLoading;
  final String? processingCargoId;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminCargosProvider>();

    if (isLoading && cargos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cargos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: BrandPalette.mutedText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCargos(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: cargos.length,
        itemBuilder: (context, index) {
          final cargo = cargos[index];
          final isProcessing = processingCargoId == cargo.id;

          return AdminCargoCard(
            cargo: cargo,
            isProcessing: isProcessing,
            onReceive: cargo.status == CargoStatus.created
                ? (imagePath) =>
                      provider.receiveCargo(cargo.id, imagePath: imagePath)
                : null,
            onRecordWeight: cargo.status == CargoStatus.receivedChina
                ? (weightGrams, fee) =>
                      provider.recordWeight(cargo.id, weightGrams, fee)
                : null,
            onRecordDimensions:
                (cargo.status == CargoStatus.receivedChina ||
                    cargo.status == CargoStatus.inTransitToMn ||
                    cargo.status == CargoStatus.arrivedMn ||
                    cargo.status == CargoStatus.awaitingFulfillmentChoice)
                ? ({
                    required int heightCm,
                    required int widthCm,
                    required int lengthCm,
                    required bool isFragile,
                    int? overrideFeeMnt,
                  }) => provider.recordDimensions(
                    cargoId: cargo.id,
                    heightCm: heightCm,
                    widthCm: widthCm,
                    lengthCm: lengthCm,
                    isFragile: isFragile,
                    overrideFeeMnt: overrideFeeMnt,
                  )
                : null,
            onShip: cargo.status == CargoStatus.receivedChina
                ? () => provider.shipCargo(cargo.id)
                : null,
            onArrive: cargo.status == CargoStatus.inTransitToMn
                ? () => provider.arriveCargo(cargo.id)
                : null,
          );
        },
      ),
    );
  }
}
