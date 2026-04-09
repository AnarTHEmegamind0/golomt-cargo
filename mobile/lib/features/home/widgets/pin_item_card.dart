import 'package:core/features/home/models/pin_item.dart';
import 'package:flutter/material.dart';

class PinItemCard extends StatefulWidget {
  const PinItemCard({super.key, required this.item});

  final PinItem item;

  @override
  State<PinItemCard> createState() => _PinItemCardState();
}

class _PinItemCardState extends State<PinItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: widget.item.aspectRatio,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.item.primaryColor,
                        widget.item.secondaryColor,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative elements wrapped in ExcludeSemantics
                      Positioned(
                        left: -20,
                        bottom: -16,
                        child: ExcludeSemantics(
                          child: IgnorePointer(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -18,
                        bottom: 28,
                        child: ExcludeSemantics(
                          child: IgnorePointer(
                            child: Transform.rotate(
                              angle: 0.22,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.item.board,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  widget.item.author,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF656264),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.item.likes}',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF656264),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
