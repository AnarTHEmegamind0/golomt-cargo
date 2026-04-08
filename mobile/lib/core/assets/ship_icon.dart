import 'package:flutter/material.dart';

/// A widget for displaying ship icons with optional color tinting.
///
/// Usage:
/// ```dart
/// ShipIcon(
///   ShipAssets.truck,
///   size: 24,
///   color: Colors.blue, // optional tint color
/// )
/// ```
class ShipIcon extends StatelessWidget {
  const ShipIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
  });

  /// The asset path from [ShipAssets].
  final String assetPath;

  /// The size of the icon (both width and height).
  final double size;

  /// Optional color to tint the icon. If null, the original colors are used.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image_outlined,
          size: size,
          color: color ?? Theme.of(context).colorScheme.error,
        );
      },
    );
  }
}

/// A circular container with a ship icon inside.
///
/// Usage:
/// ```dart
/// ShipIconCircle(
///   ShipAssets.truck,
///   size: 44,
///   iconSize: 22,
///   backgroundColor: Colors.blue.withOpacity(0.15),
///   iconColor: Colors.blue,
/// )
/// ```
class ShipIconCircle extends StatelessWidget {
  const ShipIconCircle(
    this.assetPath, {
    super.key,
    this.size = 44,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  /// The asset path from [ShipAssets].
  final String assetPath;

  /// The size of the container (both width and height).
  final double size;

  /// The size of the icon. Defaults to size * 0.5.
  final double? iconSize;

  /// The background color of the container.
  final Color? backgroundColor;

  /// The color to tint the icon.
  final Color? iconColor;

  /// Optional border radius. If null, creates a circle.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? size * 0.5;
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
        shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
      ),
      child: Center(
        child: ShipIcon(
          assetPath,
          size: effectiveIconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
