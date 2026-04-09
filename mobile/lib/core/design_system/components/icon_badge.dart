import 'package:core/core/assets/ship_icon.dart';
import 'package:flutter/material.dart';

/// Colored icon badge for workflow items
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    this.icon,
    this.assetPath,
    this.color,
    this.backgroundColor,
    this.size = 48,
    this.iconSize,
    this.onTap,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided',
       );

  final IconData? icon;
  final String? assetPath;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double? iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final badgeColor = color ?? primaryColor;
    final bgColor = backgroundColor ?? badgeColor.withValues(alpha: 0.15);
    final effectiveIconSize = iconSize ?? size * 0.5;

    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Center(
        child: assetPath != null
            ? ShipIcon(assetPath!, size: effectiveIconSize, color: badgeColor)
            : Icon(icon, size: effectiveIconSize, color: badgeColor),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size * 0.32),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Workflow item with icon badge, title and optional step number
class WorkflowIconItem extends StatelessWidget {
  const WorkflowIconItem({
    super.key,
    this.icon,
    this.assetPath,
    required this.title,
    this.color,
    this.onTap,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided',
       );

  final IconData? icon;
  final String? assetPath;
  final String title;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final itemColor = color ?? primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(
                icon: icon,
                assetPath: assetPath,
                color: itemColor,
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFE8ECF4)
                      : const Color(0xFF293247),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
