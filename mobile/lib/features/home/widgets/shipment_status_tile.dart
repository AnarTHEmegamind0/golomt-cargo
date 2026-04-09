import 'package:flutter/material.dart';

class ShipmentStatusTile extends StatelessWidget {
  const ShipmentStatusTile({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF027A48),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
