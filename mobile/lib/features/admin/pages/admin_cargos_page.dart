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

  int get paidCount =>
      cargos.where((c) => c.paymentStatus == PaymentStatus.paid).length;
  int get unpaidCount =>
      cargos.where((c) => c.paymentStatus != PaymentStatus.paid).length;
}

/// Admin cargo management page with 3 tabs
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
    _tabController = TabController(length: 3, vsync: this);
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

  List<_UserCargoGroup> _groupCargosByUser(List<CargoModel> cargos) {
    final Map<String, List<CargoModel>> grouped = {};

    for (final cargo in cargos) {
      final customerId = cargo.customer?.id ?? 'unknown';
      grouped.putIfAbsent(customerId, () => []);
      grouped[customerId]!.add(cargo);
    }

    return grouped.entries.map((entry) {
      final userCargos = entry.value;
      final customer = userCargos.first.customer;
      return _UserCargoGroup(
        userId: entry.key,
        userName: customer?.name ?? 'Хэрэглэгч',
        userEmail: customer?.email ?? '',
        cargos: userCargos,
      );
    }).toList()
      ..sort((a, b) => b.cargoCount.compareTo(a.cargoCount));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCargosProvider>();

    // Check for errors and show dialog
    _checkAndShowError(provider);

    // Filter cargos for each tab
    final receivedCargos = provider.cargos.where((c) =>
      c.status == CargoStatus.receivedChina ||
      c.status == CargoStatus.inTransitToMn
    ).toList();

    final pendingCargos = provider.cargos.where((c) =>
      c.status == CargoStatus.created ||
      c.status == CargoStatus.arrivedMn ||
      c.status == CargoStatus.awaitingFulfillmentChoice
    ).toList();

    final userGroups = _groupCargosByUser(receivedCargos);

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

        // 3 Status tabs
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
                label: 'Хэрэглэгчээр',
                count: userGroups.length,
                color: BrandPalette.electricBlue,
              ),
              _StatusTab(
                label: 'Бүх бараа',
                count: receivedCargos.length,
                color: BrandPalette.logoOrange,
              ),
              _StatusTab(
                label: 'Хүлээгдэж буй',
                count: pendingCargos.length,
                color: BrandPalette.mutedText,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Received goods grouped by customer
              _ReceivedGoodsTab(
                groups: userGroups,
                isLoading: provider.isLoading,
              ),
              // Tab 2: All cargos list (for search results etc)
              _AllCargosTab(
                cargos: receivedCargos,
                isLoading: provider.isLoading,
                processingCargoId: provider.processingCargoId,
              ),
              // Tab 3: Pending/held goods history
              _PendingGoodsTab(
                cargos: pendingCargos,
                isLoading: provider.isLoading,
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

/// Tab 1: Received goods grouped by customer with navigation
class _ReceivedGoodsTab extends StatelessWidget {
  const _ReceivedGoodsTab({
    required this.groups,
    required this.isLoading,
  });

  final List<_UserCargoGroup> groups;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminCargosProvider>();

    if (isLoading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groups.isEmpty) {
      return _EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Хүлээн авсан бараа байхгүй',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCargos(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _UserCard(group: group);
        },
      ),
    );
  }
}

/// Tab 2: All cargos list (for search, individual management)
class _AllCargosTab extends StatelessWidget {
  const _AllCargosTab({
    required this.cargos,
    required this.isLoading,
    required this.processingCargoId,
  });

  final List<CargoModel> cargos;
  final bool isLoading;
  final String? processingCargoId;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminCargosProvider>();

    if (isLoading && cargos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cargos.isEmpty) {
      return _EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Бараа байхгүй',
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
            onRecordPricing: cargo.status == CargoStatus.receivedChina
                ? ({
                    required int weightGrams,
                    required int heightCm,
                    required int widthCm,
                    required int lengthCm,
                    required bool isFragile,
                    int? overrideFeeMnt,
                  }) => provider.recordPricing(
                    cargoId: cargo.id,
                    weightGrams: weightGrams,
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

class _UserCard extends StatelessWidget {
  const _UserCard({required this.group});

  final _UserCargoGroup group;

  void _openUserCargos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => _UserCargosPage(group: group),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: BrandPalette.mutedText,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Summary chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${group.cargoCount} бараа',
                    color: BrandPalette.electricBlue,
                  ),
                  _SummaryChip(
                    icon: Icons.scale_rounded,
                    label: '${group.totalWeight.toStringAsFixed(2)} кг',
                    color: BrandPalette.logoOrange,
                  ),
                  _SummaryChip(
                    icon: Icons.attach_money_rounded,
                    label: '${group.totalFee}₮',
                    color: BrandPalette.successGreen,
                  ),
                  if (group.paidCount > 0)
                    _SummaryChip(
                      icon: Icons.check_circle_rounded,
                      label: '${group.paidCount} төлсөн',
                      color: BrandPalette.successGreen,
                    ),
                  if (group.unpaidCount > 0)
                    _SummaryChip(
                      icon: Icons.pending_rounded,
                      label: '${group.unpaidCount} төлөөгүй',
                      color: BrandPalette.errorRed,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab 3: Pending/held goods with history table
class _PendingGoodsTab extends StatelessWidget {
  const _PendingGoodsTab({
    required this.cargos,
    required this.isLoading,
  });

  final List<CargoModel> cargos;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminCargosProvider>();

    if (isLoading && cargos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cargos.isEmpty) {
      return _EmptyState(
        icon: Icons.hourglass_empty_rounded,
        message: 'Хүлээгдэж буй бараа байхгүй',
      );
    }

    final totalWeight = cargos.fold(
      0.0,
      (sum, cargo) => sum + (cargo.weightGrams ?? 0) / 1000,
    );

    final totalFee = cargos.fold(
      0,
      (sum, cargo) => sum + cargo.finalFeeMnt,
    );

    return RefreshIndicator(
      onRefresh: () => provider.loadCargos(forceRefresh: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E9F2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Хүлээгдэж буй барааны мэдээлэл',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        icon: Icons.inventory_2_outlined,
                        label: '${cargos.length} бараа',
                        color: BrandPalette.mutedText,
                      ),
                      _SummaryChip(
                        icon: Icons.scale_rounded,
                        label: '${totalWeight.toStringAsFixed(2)} кг',
                        color: BrandPalette.logoOrange,
                      ),
                      _SummaryChip(
                        icon: Icons.attach_money_rounded,
                        label: '$totalFee₮',
                        color: BrandPalette.successGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // History table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E9F2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Түүх',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: BrandPalette.softBlueBackground,
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('Огноо', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('Дүн', style: _headerStyle)),
                        Expanded(flex: 1, child: Text('Тоо', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('Байршил', style: _headerStyle)),
                      ],
                    ),
                  ),
                  // Table rows
                  ...cargos.map((cargo) => _HistoryTableRow(cargo: cargo)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: BrandPalette.mutedText,
  );
}

class _HistoryTableRow extends StatelessWidget {
  const _HistoryTableRow({required this.cargo});

  final CargoModel cargo;

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final date = cargo.updatedAt ?? cargo.createdAt ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E9F2), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${cargo.finalFeeMnt}₮',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              '1',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cargo.status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cargo.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cargo.status.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// User's cargos detail page
class _UserCargosPage extends StatelessWidget {
  const _UserCargosPage({required this.group});

  final _UserCargoGroup group;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCargosProvider>();

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
            if (group.userEmail.isNotEmpty)
              Text(
                group.userEmail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BrandPalette.mutedText,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      icon: Icons.inventory_2_outlined,
                      label: '${group.cargoCount} бараа',
                      color: BrandPalette.electricBlue,
                    ),
                    _SummaryChip(
                      icon: Icons.scale_rounded,
                      label: '${group.totalWeight.toStringAsFixed(2)} кг',
                      color: BrandPalette.logoOrange,
                    ),
                    _SummaryChip(
                      icon: Icons.attach_money_rounded,
                      label: '${group.totalFee}₮',
                      color: BrandPalette.successGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Payment status summary
                Row(
                  children: [
                    if (group.paidCount > 0) ...[
                      const Icon(Icons.check_circle_rounded, size: 16, color: BrandPalette.successGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${group.paidCount} төлсөн',
                        style: const TextStyle(
                          color: BrandPalette.successGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (group.paidCount > 0 && group.unpaidCount > 0)
                      const SizedBox(width: 16),
                    if (group.unpaidCount > 0) ...[
                      const Icon(Icons.pending_rounded, size: 16, color: BrandPalette.errorRed),
                      const SizedBox(width: 4),
                      Text(
                        '${group.unpaidCount} төлөөгүй',
                        style: const TextStyle(
                          color: BrandPalette.errorRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Cargo list with actions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: group.cargos.length,
              itemBuilder: (context, index) {
                final cargo = group.cargos[index];
                final isProcessing = provider.processingCargoId == cargo.id;

                return AdminCargoCard(
                  cargo: cargo,
                  isProcessing: isProcessing,
                  onRecordPricing: cargo.status == CargoStatus.receivedChina
                      ? ({
                          required int weightGrams,
                          required int heightCm,
                          required int widthCm,
                          required int lengthCm,
                          required bool isFragile,
                          int? overrideFeeMnt,
                        }) => provider.recordPricing(
                          cargoId: cargo.id,
                          weightGrams: weightGrams,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: BrandPalette.mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BrandPalette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
