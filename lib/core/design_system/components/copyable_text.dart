import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text widget that can be copied to clipboard with a tap
class CopyableText extends StatefulWidget {
  const CopyableText({
    super.key,
    required this.text,
    this.label,
    this.style,
    this.iconSize = 18,
    this.showIcon = true,
    this.toastMessage,
  });

  final String text;
  final String? label;
  final TextStyle? style;
  final double iconSize;
  final bool showIcon;
  final String? toastMessage;

  @override
  State<CopyableText> createState() => _CopyableTextState();
}

class _CopyableTextState extends State<CopyableText>
    with SingleTickerProviderStateMixin {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (mounted) {
      setState(() => _copied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.toastMessage ?? 'Хуулагдлаа'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _copied = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _copyToClipboard,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE4E8EE),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null) ...[
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF8B95A8)
                              : const Color(0xFF7D8799),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      widget.text,
                      style:
                          widget.style ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFE8ECF4)
                                : const Color(0xFF1E2638),
                          ),
                    ),
                  ],
                ),
              ),
              if (widget.showIcon) ...[
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    key: ValueKey(_copied),
                    size: widget.iconSize,
                    color: _copied ? const Color(0xFF10B981) : primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
