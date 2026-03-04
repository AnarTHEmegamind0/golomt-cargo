import 'package:core/core/design_system/components/app_card.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/core/design_system/components/filter_chips.dart';
import 'package:core/core/design_system/components/process_timeline.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({super.key});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DeliveryProvider>();
      if (!provider.hasLoaded) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DeliveryProvider>();

    final filterChips = [
      const FilterChipData(
        label: 'Бүгд',
        value: 'all',
        icon: Icons.list_rounded,
      ),
      const FilterChipData(
        label: 'Хүргэлтэд гарсан',
        value: 'transit',
        icon: Icons.local_shipping_rounded,
      ),
      const FilterChipData(
        label: 'Хүргэлт дууссан',
        value: 'completed',
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
                  child: _Header(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: FilterChipsRow(
                  chips: filterChips,
                  selectedValue: _selectedFilter,
                  onSelected: (value) {
                    setState(() => _selectedFilter = value);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AddDeliveryButton(
                    onTap: () {
                      _showAddDeliverySheet(context);
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
                    title: 'Хүргэлт олдсонгүй',
                    description: 'Идэвхтэй хүргэлт байхгүй байна.',
                    icon: Icons.local_shipping_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final order = provider.orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _DeliveryCard(
                          trackingCode: order.id,
                          productName: order.restaurantName,
                          status: _getStatusLabel(order.step.index),
                          currentStep: order.step.index,
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

  String _getStatusLabel(int step) {
    switch (step) {
      case 0:
        return 'Хүлээгдэж буй';
      case 1:
        return 'Хүлээн авсан';
      case 2:
        return 'Ачиж байна';
      case 3:
        return 'Хүргэлтэд гарсан';
      case 4:
        return 'Очсон';
      case 5:
        return 'Баталгаажуулж байна';
      case 6:
        return 'Хүргэгдсэн';
      default:
        return 'Тодорхойгүй';
    }
  }

  void _showAddDeliverySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddDeliverySheet(),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Хүргэлт',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          'Хүргэлтийн явцыг хянана уу',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF8B95A8)
                : const Color(0xFF677186),
          ),
        ),
      ],
    );
  }
}

class _AddDeliveryButton extends StatelessWidget {
  const _AddDeliveryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Хүргэлт нэмэх'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.trackingCode,
    required this.productName,
    required this.status,
    required this.currentStep,
  });

  final String trackingCode;
  final String productName;
  final String status;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: () => _showDeliveryDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trackingCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      productName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFF8B95A8)
                            : const Color(0xFF677186),
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
                  color: _getStatusColor(currentStep).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(currentStep),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniTimeline(currentStep: currentStep),
        ],
      ),
    );
  }

  Color _getStatusColor(int step) {
    if (step >= 6) return const Color(0xFF10B981);
    if (step >= 3) return const Color(0xFF3B82F6);
    if (step >= 1) return const Color(0xFFF59E0B);
    return const Color(0xFF8B95A8);
  }

  void _showDeliveryDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeliveryDetailSheet(
        trackingCode: trackingCode,
        productName: productName,
        currentStep: currentStep,
      ),
    );
  }
}

class _MiniTimeline extends StatelessWidget {
  const _MiniTimeline({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['Хүлээгдэж буй', 'Ачиж байна', 'Хүргэлтэд', 'Хүргэгдсэн'];

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep ~/ 2;
        final isActive = index == currentStep ~/ 2;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : (isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : const Color(0xFFD1D5DB)),
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 8,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isCompleted || isActive
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFFE8ECF4)
                                  : const Color(0xFF374151))
                            : const Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DeliveryDetailSheet extends StatelessWidget {
  const _DeliveryDetailSheet({
    required this.trackingCode,
    required this.productName,
    required this.currentStep,
  });

  final String trackingCode;
  final String productName;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timelineSteps = [
      TimelineStepData(
        title: 'Захиалга үүссэн',
        subtitle: 'Захиалга амжилттай бүртгэгдлээ',
        icon: Icons.inventory_2_rounded,
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TimelineStepData(
        title: 'Ачаа бэлтгэгдэж байна',
        subtitle: 'Хятад агуулахад хүлээн авсан',
        icon: Icons.warehouse_rounded,
        dateTime: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TimelineStepData(
        title: 'Ачаа ачигдаж байна',
        subtitle: 'Тээврийн хэрэгсэлд ачиж байна',
        icon: Icons.local_shipping_rounded,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TimelineStepData(
        title: 'Хүргэлтэд гарсан',
        subtitle: 'Монгол руу явж байна',
        icon: Icons.flight_takeoff_rounded,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      const TimelineStepData(
        title: 'Гаалийн шалгалт',
        subtitle: 'Гааль дээр шалгагдаж байна',
        icon: Icons.security_rounded,
      ),
      const TimelineStepData(
        title: 'Хүргэгдсэн',
        subtitle: 'Ачаа амжилттай хүргэгдлээ',
        icon: Icons.check_circle_rounded,
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trackingCode,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFF8B95A8)
                              : const Color(0xFF677186),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProcessTimeline(
                steps: timelineSteps,
                currentStep: currentStep,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Холбоо барих'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Байршил харах'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddDeliverySheet extends StatelessWidget {
  const _AddDeliverySheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
            child: Text(
              'Хүргэлт нэмэх',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Трак код',
                hintText: 'BD2024XXXXXX',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    // Scan QR code
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Хүргэлтийн хаяг',
                hintText: 'Хаягаа оруулна уу',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Хүргэлт амжилттай нэмэгдлээ'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Хүргэлт нэмэх'),
            ),
          ),
        ],
      ),
    );
  }
}
