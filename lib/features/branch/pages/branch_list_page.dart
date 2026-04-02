import 'package:core/core/animations/page_transitions.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/core/design_system/components/view_toggle.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/pages/branch_detail_page.dart';
import 'package:core/features/branch/providers/branch_provider.dart';
import 'package:core/features/branch/widgets/branch_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BranchListPage extends StatefulWidget {
  const BranchListPage({super.key});

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BranchProvider>();
      if (!provider.hasLoaded) {
        provider.load();
      }
    });
  }

  void _openBranchDetail(Branch branch) {
    Navigator.of(
      context,
    ).push(PageTransitions.slideFade(BranchDetailPage(branch: branch)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<BranchProvider>();

    return CargoBackdrop(
      light: !isDark,
      child: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () =>
              context.read<BranchProvider>().load(forceRefresh: true),
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
              else if (provider.branches.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'Салбар олдсонгүй',
                    description: 'Одоогоор бүртгэлтэй салбар байхгүй байна.',
                    icon: Icons.storefront_outlined,
                  ),
                )
              else if (provider.isGridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final branch = provider.branches[index];
                      return BranchGridCard(
                        branch: branch,
                        onTap: () => _openBranchDetail(branch),
                      );
                    }, childCount: provider.branches.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final branch = provider.branches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BranchListCard(
                          branch: branch,
                          onTap: () => _openBranchDetail(branch),
                        ),
                      );
                    }, childCount: provider.branches.length),
                  ),
                ),
            ],
          ),
        ),
      ),
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
                'Салбарууд',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ойролцоох салбараа сонгоно уу',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8B95A8)
                      : const Color(0xFF677186),
                ),
              ),
            ],
          ),
        ),
        ViewToggle(isGridView: isGridView, onToggle: onToggle),
      ],
    );
  }
}
