import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/services/earning_service.dart';
import 'package:core/features/delivery/widgets/metric_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = context.select(
      (DeliveryProvider provider) => provider.todayEarnings,
    );
    final payout = context.read<EarningService>().estimatedPayout(
      completedTotal: total,
      feeRate: 0.08,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Орлого')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFCB3D5A), Color(0xFF9D1F3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Татах боломжтой үлдэгдэл',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                MetricCounter(
                  value: payout,
                  suffix: ' \$',
                  decimals: 2,
                  prefix: '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Задалгаа',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _RowValue(
                    label: 'Нийт орлого',
                    value: '${total.toStringAsFixed(2)} \$',
                  ),
                  _RowValue(
                    label: 'Платформын шимтгэл',
                    value: '${(total - payout).toStringAsFixed(2)} \$',
                  ),
                  _RowValue(
                    label: 'Гар дээр',
                    value: '${payout.toStringAsFixed(2)} \$',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Таталтын хүсэлт амжилттай илгээгдлээ.'),
                ),
              );
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Таталт хүсэх'),
          ),
        ],
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  const _RowValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
