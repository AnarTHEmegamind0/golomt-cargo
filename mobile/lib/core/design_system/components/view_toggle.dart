import 'package:flutter/material.dart';

/// Toggle between list and grid view
class ViewToggle extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.isGridView,
    required this.onToggle,
  });

  final bool isGridView;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE4E8EE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: !isGridView,
            onTap: isGridView ? onToggle : null,
            primaryColor: primaryColor,
            isDark: isDark,
            isLeft: true,
          ),
          Container(
            width: 1,
            height: 24,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE4E8EE),
          ),
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: isGridView,
            onTap: !isGridView ? onToggle : null,
            primaryColor: primaryColor,
            isDark: isDark,
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
    required this.isLeft,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color primaryColor;
  final bool isDark;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(11) : Radius.zero,
          right: !isLeft ? const Radius.circular(11) : Radius.zero,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(11) : Radius.zero,
              right: !isLeft ? const Radius.circular(11) : Radius.zero,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF8B95A8) : const Color(0xFF808CA2)),
          ),
        ),
      ),
    );
  }
}
