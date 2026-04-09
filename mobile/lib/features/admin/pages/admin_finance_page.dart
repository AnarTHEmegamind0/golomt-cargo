import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/providers/admin_finance_provider.dart';
import 'package:core/features/admin/widgets/admin_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin finance page
class AdminFinancePage extends StatefulWidget {
  const AdminFinancePage({super.key});

  @override
  State<AdminFinancePage> createState() => _AdminFinancePageState();
}

class _AdminFinancePageState extends State<AdminFinancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFinanceProvider>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminFinanceProvider>();
    final summary = provider.summary;

    return RefreshIndicator(
      onRefresh: () => provider.loadSummary(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Санхүүгийн тайлан',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            provider.dateRangeDisplay,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BrandPalette.mutedText),
          ),
          const SizedBox(height: 16),

          // Date range filter
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('7 хоног'),
                selected: false,
                onSelected: (_) => provider.setLastDays(7),
              ),
              FilterChip(
                label: const Text('30 хоног'),
                selected: false,
                onSelected: (_) => provider.setLastDays(30),
              ),
              FilterChip(
                label: const Text('Бүгд'),
                selected: !provider.hasDateRange,
                onSelected: (_) => provider.clearDateRange(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Revenue cards
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    title: 'Нийт орлого',
                    value: summary.totalRevenueDisplay,
                    assetPath: ShipAssets.wallet,
                    color: BrandPalette.electricBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    title: 'Төлөгдсөн',
                    value: summary.paidAmountDisplay,
                    assetPath: ShipAssets.mailArrivedAndHand,
                    color: BrandPalette.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    title: 'Төлөгдөөгүй',
                    value: summary.unpaidAmountDisplay,
                    assetPath: ShipAssets.clockAndHome,
                    color: BrandPalette.logoOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdminStatCard(
                    title: 'Цуглуулалт',
                    value: '${summary.collectionRate.toStringAsFixed(0)}%',
                    assetPath: ShipAssets.moneyBack,
                    color: BrandPalette.navyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cargo stats
            Text(
              'Карго статистик',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Нийт карго',
                    value: '${summary.totalCargos}',
                    color: BrandPalette.electricBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Төлсөн',
                    value: '${summary.paidCargos}',
                    color: BrandPalette.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Төлөөгүй',
                    value: '${summary.unpaidCargos}',
                    color: BrandPalette.logoOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Daily revenues
            if (summary.dailyRevenues.isNotEmpty) ...[
              Text(
                'Өдрийн орлого',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...summary.dailyRevenues.map(
                (daily) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9F2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        daily.dateDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${daily.cargoCount} карго',
                        style: TextStyle(
                          color: BrandPalette.mutedText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        daily.revenueDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: BrandPalette.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BrandPalette.mutedText),
          ),
        ],
      ),
    );
  }
}
