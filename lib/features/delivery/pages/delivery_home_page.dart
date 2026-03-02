import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/animations/stagger_fade_slide.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/pages/chat_page.dart';
import 'package:core/features/delivery/pages/earnings_page.dart';
import 'package:core/features/delivery/pages/order_detail_page.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/widgets/delivery_order_card.dart';
import 'package:core/features/delivery/widgets/metric_counter.dart';
import 'package:core/features/delivery/widgets/order_feed_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage> {
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
    final provider = context.watch<DeliveryProvider>();
    final orders = provider.orders;

    return SafeArea(
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () => context.read<DeliveryProvider>().load(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            Text('Home', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Today focus: fast handoff and clean proof.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            _EarningsHero(
              earnings: provider.todayEarnings,
              completed: provider.completedCount,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageTransitions.slideFade(const EarningsPage()),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: const Text('Withdraw'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageTransitions.slideFade(
                          const ChatPage(orderId: 'ORD-31041'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Messages'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const OrderFeedSkeleton()
            else if (provider.error != null)
              EmptyState(
                title: 'Unable to load active orders',
                description: provider.error!,
                actionLabel: 'Retry',
                onAction: () =>
                    context.read<DeliveryProvider>().load(forceRefresh: true),
                icon: Icons.error_outline_rounded,
              )
            else if (orders.isEmpty)
              const EmptyState(
                title: 'No live orders right now',
                description: 'Pull to refresh when you are online for new requests.',
                icon: Icons.delivery_dining_rounded,
              )
            else
              _OrderMasonry(orders: orders),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({required this.earnings, required this.completed});

  final double earnings;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final progress = (completed / 8).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD1455F), Color(0xFFB32B45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today Earnings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                MetricCounter(value: earnings, prefix: '\$', decimals: 2),
                const SizedBox(height: 6),
                Text(
                  '$completed deliveries completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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

class _OrderMasonry extends StatelessWidget {
  const _OrderMasonry({required this.orders});

  final List<DeliveryOrder> orders;

  @override
  Widget build(BuildContext context) {
    final left = <DeliveryOrder>[];
    final right = <DeliveryOrder>[];

    for (var index = 0; index < orders.length; index++) {
      (index.isEven ? left : right).add(orders[index]);
    }

    Widget buildColumn(List<DeliveryOrder> items, int baseIndex) {
      return Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            StaggerFadeSlide(
              index: baseIndex + index,
              child: DeliveryOrderCard(
                order: items[index],
                onTap: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFade(
                      OrderDetailPage(orderId: items[index].id),
                    ),
                  );
                },
                onAccept: () {
                  context.read<DeliveryProvider>().acceptOrder(items[index].id);
                },
              ),
            ),
            if (index != items.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildColumn(left, 0)),
        const SizedBox(width: 12),
        Expanded(child: buildColumn(right, 2)),
      ],
    );
  }
}
