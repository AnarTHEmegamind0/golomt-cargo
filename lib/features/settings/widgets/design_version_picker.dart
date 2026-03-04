import 'package:core/core/app_theme.dart';
import 'package:flutter/material.dart';

class DesignVersionPicker extends StatelessWidget {
  const DesignVersionPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DesignVersion value;
  final ValueChanged<DesignVersion> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DesignVersion.values.map((design) {
        final isSelected = value == design;
        return _DesignSwatch(
          design: design,
          isSelected: isSelected,
          onTap: () => onChanged(design),
        );
      }).toList(),
    );
  }
}

class _DesignSwatch extends StatelessWidget {
  const _DesignSwatch({
    required this.design,
    required this.isSelected,
    required this.onTap,
  });

  final DesignVersion design;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = DesignConfig.forDesign(design);
    final colors = _getDesignColors(design);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Preview circles showing design colors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ColorDot(color: colors.primary, size: 16),
                const SizedBox(width: 4),
                _ColorDot(color: colors.secondary, size: 12),
                const SizedBox(width: 4),
                _ColorDot(color: colors.accent, size: 10),
              ],
            ),
            const SizedBox(height: 8),
            // Design name
            Text(
              design.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Version indicator
            Text(
              'v${design.version}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DesignColors _getDesignColors(DesignVersion design) {
    switch (design) {
      case DesignVersion.glassmorphism:
        return const _DesignColors(
          primary: Color(0xFFF08A1A),
          secondary: Color(0xFFD96A12),
          accent: Color(0xFF2563EB),
          background: Color(0xFFF8F9FC),
          border: Color(0xFFE5DDD7),
        );
      case DesignVersion.neumorphism:
        return const _DesignColors(
          primary: Color(0xFFF08A1A),
          secondary: Color(0xFF2563EB),
          accent: Color(0xFFE4E8EF),
          background: Color(0xFFE4E8EF),
          border: Color(0xFFBEC8D1),
        );
      case DesignVersion.minimal:
        return const _DesignColors(
          primary: Color(0xFFF08A1A),
          secondary: Color(0xFF2563EB),
          accent: Color(0xFF09090B),
          background: Color(0xFFFFFFFF),
          border: Color(0xFFE4E4E7),
        );
      case DesignVersion.cyberpunk:
        return const _DesignColors(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFF00D4FF),
          accent: Color(0xFF0A0A0F),
          background: Color(0xFF1A1A2E),
          border: Color(0xFFFF6B00),
        );
      case DesignVersion.luxury:
        return const _DesignColors(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFF08A1A),
          accent: Color(0xFF1A1614),
          background: Color(0xFFFAF8F5),
          border: Color(0xFFD4AF37),
        );
    }
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _DesignColors {
  const _DesignColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.border,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color border;
}
