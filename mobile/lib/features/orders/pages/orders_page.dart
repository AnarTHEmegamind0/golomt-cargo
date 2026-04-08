import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/design_system/components/app_search_bar.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/core/design_system/components/filter_chips.dart';
import 'package:core/core/design_system/components/view_toggle.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/config/api_config.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/pages/pricing_calculator_page.dart';
import 'package:core/features/orders/providers/order_provider.dart';
import 'package:core/features/orders/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      if (!provider.hasLoaded) {
        provider.load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OrderProvider>();

    final filterChips = [
      const FilterChipData(
        label: 'Бүгд',
        value: 'all',
        icon: Icons.list_rounded,
      ),
      FilterChipData(
        label: 'Хүлээгдэж буй (${provider.pendingCount})',
        value: 'pending',
        icon: Icons.schedule_rounded,
      ),
      FilterChipData(
        label: 'Тээвэрлэгдэж буй (${provider.transitCount})',
        value: 'transit',
        icon: Icons.local_shipping_rounded,
      ),
      FilterChipData(
        label: 'Хүргэгдсэн (${provider.deliveredCount})',
        value: 'delivered',
        icon: Icons.check_circle_rounded,
      ),
    ];

    return CargoBackdrop(
      light: !isDark,
      child: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => provider.load(forceRefresh: true),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _Header(
                    isGridView: provider.isGridView,
                    onToggle: () => provider.toggleView(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppSearchBar(
                    hint: 'Трак код эсвэл бараа хайх...',
                    controller: _searchController,
                    onChanged: (query) => provider.setSearchQuery(query),
                    showFilter: false,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              // SliverToBoxAdapter(
              //   child: FilterChipsRow(
              //     chips: filterChips,
              //     selectedValue: provider.selectedStatus?.name ?? 'all',
              //     onSelected: (value) {
              //       if (value == 'all') {
              //         provider.setFilter(null);
              //       } else {
              //         provider.setFilter(
              //           OrderStatus.values.firstWhere(
              //             (s) => s.name == value,
              //             orElse: () => OrderStatus.pending,
              //           ),
              //         );
              //       }
              //     },
              //   ),
              // ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AddOrderButton(
                    onTap: () {
                      _showAddOrderSheet(context);
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                  child: EmptyState(
                    title: 'Алдаа гарлаа',
                    description: provider.error!,
                    actionLabel: 'Дахин оролдох',
                    onAction: () => provider.load(forceRefresh: true),
                    icon: Icons.error_outline_rounded,
                  ),
                )
              else if (provider.orders.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'Захиалга олдсонгүй',
                    description: 'Шүүлтүүрийн нөхцөлд тохирох захиалга алга.',
                    icon: Icons.inbox_rounded,
                  ),
                )
              else if (provider.isGridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final order = provider.orders[index];
                      return OrderGridCard(
                        order: order,
                        onTap: () => _showOrderDetail(context, order),
                      );
                    }, childCount: provider.orders.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final order = provider.orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderListCard(
                          order: order,
                          onTap: () => _showOrderDetail(context, order),
                          onDelete: () => _confirmDelete(context, order.id),
                          onRequestDelivery:
                              order.status == OrderStatus.processing
                              ? () => provider.requestDelivery(order.id)
                              : null,
                        ),
                      );
                    }, childCount: provider.orders.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Захиалга устгах'),
        content: const Text('Та энэ захиалгыг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderProvider>().deleteOrder(orderId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
  }

  void _showAddOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddOrderSheet(),
    );
  }
}

class _AddOrderButton extends StatelessWidget {
  const _AddOrderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Захиалга нэмэх'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }
}

class _AddOrderSheet extends StatefulWidget {
  const _AddOrderSheet();

  @override
  State<_AddOrderSheet> createState() => _AddOrderSheetState();
}

class _AddOrderSheetState extends State<_AddOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _trackingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.62,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2234) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Захиалга нэмэх',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _trackingController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Трак код',
                    hintText: 'LP009845612CN',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'Трак код оруулна уу';
                    }
                    if (text.length < 3) {
                      return 'Дор хаяж 3 тэмдэгт шаардлагатай';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Тайлбар',
                    hintText: 'Барааны нэр эсвэл нэмэлт мэдээлэл',
                    prefixIcon: Icon(Icons.inventory_2_rounded),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Захиалга нэмэх'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final trackingCode = _trackingController.text.trim();
    final description = _descriptionController.text.trim();

    final order = await context.read<OrderProvider>().createOrder(
      trackingCode: trackingCode,
      productName: description.isEmpty ? null : description,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (order != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Захиалга амжилттай нэмэгдлээ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final error =
        context.read<OrderProvider>().error ?? 'Захиалга нэмэхэд алдаа гарлаа';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isGridView, required this.onToggle});

  final bool isGridView;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Захиалгууд',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Бүх захиалгаа удирдана уу',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8B95A8)
                      : const Color(0xFF677186),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PricingCalculatorPage()),
          ),
          icon: const Icon(Icons.calculate_outlined),
          tooltip: 'Үнийн тооцоолуур',
          style: IconButton.styleFrom(
            backgroundColor: BrandPalette.electricBlue.withValues(alpha: 0.1),
            foregroundColor: BrandPalette.electricBlue,
          ),
        ),
        const SizedBox(width: 8),
        ViewToggle(isGridView: isGridView, onToggle: onToggle),
      ],
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = _resolveImageUrl(context);
    final imageHeaders = _resolveImageHeaders(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2234) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ShipIcon(
                    order.status.shipAsset,
                    color: order.status.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.trackingCode,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFF8B95A8)
                              : const Color(0xFF677186),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    headers: imageHeaders,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE9EDF5),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (imageUrl != null) const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _DetailRow(
                  label: 'Төлөв',
                  value: order.status.label,
                  valueColor: order.status.color,
                ),
                _DetailRow(
                  label: 'Системийн төлөв',
                  value: order.rawStatus ?? '-',
                ),
                _DetailRow(
                  label: 'Жин',
                  value: order.hasWeight
                      ? _formatWeight(order.uiWeight)
                      : '-кг',
                ),
                if (order.deliveryAddress != null)
                  _DetailRow(
                    label: 'Хүргэлтийн хаяг',
                    value: order.deliveryAddress!,
                  ),
                if (order.estimatedDelivery != null)
                  _DetailRow(
                    label: 'Хүлээгдэж буй огноо',
                    value: _formatDate(order.estimatedDelivery!),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (order.status == OrderStatus.processing)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<OrderProvider>().requestDelivery(order.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.local_shipping_rounded),
                      label: const Text('Хүргэлт захиалах'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String? _resolveImageUrl(BuildContext context) {
    final directUrl = (order.imageUrl ?? '').trim();
    if (directUrl.isNotEmpty) {
      return directUrl;
    }

    final apiClient = context.read<ApiClient>();
    final baseUrl = apiClient.dio.options.baseUrl;
    return '$baseUrl${CargoEndpoints.receivedImage(order.id)}';
  }

  Map<String, String>? _resolveImageHeaders(BuildContext context) {
    final token = context.read<ApiClient>().authToken;
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return {'Authorization': 'Bearer $token'};
  }

  String _formatWeight(double weight) {
    final text = weight.toStringAsFixed(weight >= 10 ? 1 : 2);
    return '${text.replaceFirst(RegExp(r'\.0+$'), '').replaceFirst(RegExp(r'(\.\d*[1-9])0+$'), r'$1')}кг';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8B95A8) : const Color(0xFF677186),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    valueColor ??
                    (isDark
                        ? const Color(0xFFE8ECF4)
                        : const Color(0xFF1E2638)),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
