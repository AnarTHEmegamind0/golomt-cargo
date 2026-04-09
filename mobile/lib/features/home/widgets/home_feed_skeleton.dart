import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeFeedSkeleton extends StatefulWidget {
  const HomeFeedSkeleton({super.key});

  @override
  State<HomeFeedSkeleton> createState() => _HomeFeedSkeletonState();
}

class _HomeFeedSkeletonState extends State<HomeFeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= 1200
            ? 4
            : width >= 900
            ? 3
            : 2;

        final placeholderSizes = <double>[
          0.72,
          0.95,
          0.82,
          1.09,
          0.8,
          1.04,
          0.75,
          0.92,
        ];
        final columns = List.generate(columnCount, (_) => <double>[]);
        final heights = List<double>.filled(columnCount, 0);

        for (final ratio in placeholderSizes) {
          var target = 0;
          for (var index = 1; index < columnCount; index++) {
            if (heights[index] < heights[target]) {
              target = index;
            }
          }
          columns[target].add(ratio);
          heights[target] += (1 / ratio) + 0.55;
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final wave =
                0.45 + (0.25 * math.sin(_controller.value * math.pi * 2));

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(columnCount, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                    child: Column(
                      children: [
                        for (var i = 0; i < columns[index].length; i++) ...[
                          _SkeletonPinTile(
                            aspectRatio: columns[index][i],
                            opacity: wave,
                          ),
                          if (i != columns[index].length - 1)
                            const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}

class _SkeletonPinTile extends StatelessWidget {
  const _SkeletonPinTile({required this.aspectRatio, required this.opacity});

  final double aspectRatio;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              color: const Color(0xFFE8E4E0).withValues(alpha: opacity),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFE8E4E0).withValues(alpha: opacity),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 94,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFE8E4E0).withValues(alpha: opacity),
          ),
        ),
      ],
    );
  }
}
