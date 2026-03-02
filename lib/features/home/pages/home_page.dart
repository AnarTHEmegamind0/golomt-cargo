import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/home/providers/pin_feed_provider.dart';
import 'package:core/features/home/widgets/home_feed_skeleton.dart';
import 'package:core/features/home/widgets/live_pulse_dot.dart';
import 'package:core/features/home/widgets/pinterest_masonry_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PinFeedProvider>();
      if (!provider.hasLoaded) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail =
        context.select((AuthProvider provider) => provider.user?.email) ??
        'guest@pincargo.app';

    final isLoading = context.select((PinFeedProvider p) => p.isLoading);
    final error = context.select((PinFeedProvider p) => p.error);
    final selectedBoard = context.select((PinFeedProvider p) => p.selectedBoard);
    final boards = context.select((PinFeedProvider p) => p.boards);
    final pins = context.select((PinFeedProvider p) => p.pins);

    return SafeArea(
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () => context.read<PinFeedProvider>().load(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Home', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        userEmail,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF676264),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _TrendBadge(),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9E3DD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF8B8689)),
                  const SizedBox(width: 10),
                  Text(
                    'Search boards, authors, and ideas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B8689),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: boards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final board = boards[index];
                  final selected = board == selectedBoard;

                  return ChoiceChip(
                    label: Text(board),
                    selected: selected,
                    onSelected: (_) => context.read<PinFeedProvider>().selectBoard(board),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFE3DCD6),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.14),
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF676264),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const HomeFeedSkeleton()
            else if (error != null)
              _ErrorState(
                message: error,
                onRetry: () => context.read<PinFeedProvider>().load(forceRefresh: true),
              )
            else if (pins.isEmpty)
              const _EmptyState()
            else
              PinterestMasonryGrid(items: pins),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE3DCD6)),
      ),
      child: Row(
        children: [
          const LivePulseDot(),
          const SizedBox(width: 8),
          Text(
            'Live trend',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF676264),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3DCD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Could not load feed', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3DCD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.grid_view_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text('No ideas in this board yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Switch to another board or refresh to get new recommendations.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF676264)),
          ),
        ],
      ),
    );
  }
}
