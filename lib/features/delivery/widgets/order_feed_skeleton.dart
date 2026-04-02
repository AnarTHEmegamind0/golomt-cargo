import 'dart:math' as math;

import 'package:flutter/material.dart';

class OrderFeedSkeleton extends StatefulWidget {
  const OrderFeedSkeleton({super.key});

  @override
  State<OrderFeedSkeleton> createState() => _OrderFeedSkeletonState();
}

class _OrderFeedSkeletonState extends State<OrderFeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final wave = 0.45 + (0.3 * math.sin(_controller.value * math.pi * 2));

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: const [
                  _SkeletonCard(aspectRatio: 0.82),
                  SizedBox(height: 14),
                  _SkeletonCard(aspectRatio: 1.02),
                ].map((widget) {
                  if (widget is _SkeletonCard) {
                    return _SkeletonCard(
                      aspectRatio: widget.aspectRatio,
                      opacity: wave,
                    );
                  }
                  return widget;
                }).toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: const [
                  _SkeletonCard(aspectRatio: 1.06),
                  SizedBox(height: 14),
                  _SkeletonCard(aspectRatio: 0.88),
                ].map((widget) {
                  if (widget is _SkeletonCard) {
                    return _SkeletonCard(
                      aspectRatio: widget.aspectRatio,
                      opacity: wave,
                    );
                  }
                  return widget;
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.aspectRatio, this.opacity = 0.5});

  final double aspectRatio;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              color: const Color(0xFFE8E1DB).withValues(alpha: opacity),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFE8E1DB).withValues(alpha: opacity),
          ),
        ),
      ],
    );
  }
}
