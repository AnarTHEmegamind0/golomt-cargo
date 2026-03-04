import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/pages/chat_page.dart';
import 'package:core/features/delivery/pages/order_detail_page.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/widgets/status_chip.dart';
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
    final featured = orders.isEmpty ? null : orders.first;

    return CargoBackdrop(
      light: true,
      child: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFF08A1A),
          onRefresh: () =>
              context.read<DeliveryProvider>().load(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              const _TopBar(),
              const SizedBox(height: 14),
              const _SearchField(),
              const SizedBox(height: 14),
              const _WorkflowSection(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Одоогийн хүргэлт',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Илүү')),
                ],
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                EmptyState(
                  title: 'Захиалгын мэдээлэл авахад алдаа гарлаа',
                  description: provider.error!,
                  actionLabel: 'Дахин оролдох',
                  onAction: () =>
                      context.read<DeliveryProvider>().load(forceRefresh: true),
                  icon: Icons.error_outline_rounded,
                )
              else if (featured == null)
                const EmptyState(
                  title: 'Идэвхтэй хүргэлт алга',
                  description: 'Шинэ захиалга орж ирэхэд энд харагдана.',
                  icon: Icons.local_shipping_outlined,
                )
              else
                _CurrentShippingCard(order: featured),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Сүүлийн захиалгууд',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Бүгд')),
                ],
              ),
              const SizedBox(height: 8),
              if (orders.isNotEmpty)
                ...orders
                    .take(4)
                    .map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RecentShipmentRow(
                          order: order,
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideFade(
                                OrderDetailPage(orderId: order.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFade(
                      const ChatPage(orderId: 'ORD-31041'),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Оператортой холбогдох'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сайн уу',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF75819A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Жолооч 80112818',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            foregroundColor: const Color(0xFF1E2638),
          ),
          icon: const Icon(Icons.person_rounded),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF808CA2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Трак дугаар эсвэл хаяг хайх',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF808CA2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.tune_rounded, color: Color(0xFF808CA2)),
        ],
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Хялбар ажлын урсгал',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _WorkflowItem(
                  icon: Icons.storefront_outlined,
                  title: 'Салбар сонгох',
                  step: '01',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _WorkflowItem(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Трак код бүртгэх',
                  step: '02',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _WorkflowItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Барааг хүргүүлэх',
                  step: '03',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowItem extends StatelessWidget {
  const _WorkflowItem({
    required this.icon,
    required this.title,
    required this.step,
  });

  final IconData icon;
  final String title;
  final String step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF08A1A).withValues(alpha: 0.16),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFD77112)),
          ),
          const SizedBox(height: 8),
          Text(
            step,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7D8799),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF293247),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentShippingCard extends StatelessWidget {
  const _CurrentShippingCard({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(PageTransitions.slideFade(OrderDetailPage(orderId: order.id)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E7EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusChip(step: order.step),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Трак: ${order.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF677186),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5DDB6), Color(0xFFECC98F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Барааг хүргүүлэх',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.deliveryAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF5F4D32),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, size: 34),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentShipmentRow extends StatelessWidget {
  const _RecentShipmentRow({required this.order, required this.onTap});

  final DeliveryOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E7EF)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [order.primaryColor, order.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.restaurantName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF667286),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.etaMinutes} мин',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF677286),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.earnings.toStringAsFixed(2)} \$',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD77112),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7B8598)),
          ],
        ),
      ),
    );
  }
}
