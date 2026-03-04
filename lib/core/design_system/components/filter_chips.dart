import 'package:flutter/material.dart';

/// Filter chip data model
class FilterChipData {
  const FilterChipData({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;
}

/// Horizontal scrollable filter chips
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.chips,
    required this.selectedValue,
    required this.onSelected,
    this.padding,
  });

  final List<FilterChipData> chips;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((chip) {
          final isSelected = chip.value == selectedValue;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppFilterChip(
              label: chip.label,
              icon: chip.icon,
              isSelected: isSelected,
              onTap: () => onSelected(chip.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single filter chip
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 14 : 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFE4E8EE)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFFAAB3C6)
                            : const Color(0xFF677186)),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFFAAB3C6)
                            : const Color(0xFF3D4556)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
