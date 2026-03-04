import 'package:flutter/material.dart';

/// A reusable search bar component with filter support
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.hint,
    this.onChanged,
    this.onFilterTap,
    this.showFilter = true,
    this.controller,
    this.enabled = true,
  });

  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final TextEditingController? controller;
  final bool enabled;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C2537).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF8B95A8) : const Color(0xFF808CA2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: widget.enabled
                ? TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? 'Хайлт...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF8B95A8)
                            : const Color(0xFF808CA2),
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text(
                    widget.hint ?? 'Хайлт...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFF8B95A8)
                          : const Color(0xFF808CA2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          if (_hasText)
            IconButton(
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              icon: Icon(
                Icons.close_rounded,
                color: isDark
                    ? const Color(0xFF8B95A8)
                    : const Color(0xFF808CA2),
                size: 20,
              ),
            ),
          if (widget.showFilter) ...[
            Container(
              width: 1,
              height: 24,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE1E6EF),
            ),
            IconButton(
              onPressed: widget.onFilterTap,
              icon: Icon(
                Icons.tune_rounded,
                color: isDark
                    ? const Color(0xFF8B95A8)
                    : const Color(0xFF808CA2),
              ),
            ),
          ] else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}
