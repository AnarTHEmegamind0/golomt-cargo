import 'package:flutter/material.dart';

class MetricCounter extends StatelessWidget {
  const MetricCounter({
    super.key,
    required this.value,
    required this.prefix,
    this.suffix = '',
    this.decimals = 0,
  });

  final double value;
  final String prefix;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 860),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) {
        final valueText = current.toStringAsFixed(decimals);
        return Text(
          '$prefix$valueText$suffix',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}
