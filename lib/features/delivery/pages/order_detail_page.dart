import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/pages/chat_page.dart';
import 'package:core/features/delivery/pages/delivery_proof_page.dart';
import 'package:core/features/delivery/pages/order_map_navigation_page.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = context.select(
      (DeliveryProvider provider) => provider.findById(orderId),
    );

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Захиалгын дэлгэрэнгүй')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: EmptyState(
            title: 'Захиалга олдсонгүй',
            description:
                'Энэ захиалга идэвхтэй жагсаалтаас хасагдсан байж болно.',
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: Text(order.id),
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: order.imageHeroTag,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [order.primaryColor, order.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.restaurantName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    StatusChip(step: order.step),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  order.deliveryAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Захиалгын бараа',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Chip(label: Text(order.items[index]));
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Хүргэлтийн тэмдэглэл',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  order.instructions,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (order.proofImagePath != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Хавсаргасан баталгаа: ${order.proofImagePath}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransitions.slideFade(
                              OrderMapNavigationPage(orderId: order.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Зам нээх'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransitions.slideFade(
                              ChatPage(orderId: order.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Мессеж'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransitions.slideFade(
                        DeliveryProofPage(orderId: order.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Хүргэлтийн баталгаа оруулах'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    context.read<DeliveryProvider>().advanceStep(order);
                  },
                  child: Text(_nextStepLabel(order.step)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _nextStepLabel(DeliveryStep step) {
    return switch (step) {
      DeliveryStep.pending => 'Захиалга хүлээж авах',
      DeliveryStep.accepted => 'Барааг авсан гэж тэмдэглэх',
      DeliveryStep.pickedUp => 'Замд гарсан гэж тэмдэглэх',
      DeliveryStep.enRoute => 'Ирсэн гэж тэмдэглэх',
      DeliveryStep.arrived => 'Баталгаажуулах алхам руу орох',
      DeliveryStep.proof => 'Захиалга дуусгах',
      DeliveryStep.completed => 'Дууссан',
    };
  }
}
