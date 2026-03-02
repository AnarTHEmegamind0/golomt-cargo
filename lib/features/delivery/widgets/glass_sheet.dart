import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF2B2326) : Colors.white).withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? const Color(0xFF645055) : Colors.white).withValues(
                alpha: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF231B1D).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
