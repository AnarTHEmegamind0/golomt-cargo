import 'package:flutter/material.dart';

class CargoBackdrop extends StatelessWidget {
  const CargoBackdrop({super.key, required this.child, this.light = false});

  final Widget child;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final decoration = light
        ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F6F8), Color(0xFFEDEFF2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          )
        : const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E1420), Color(0xFF151F31)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          );

    final strokeColor = light
        ? const Color(0xFF2A3347).withValues(alpha: 0.14)
        : const Color(0xFF95A2BE).withValues(alpha: 0.08);

    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        children: [
          Positioned(
            right: -120,
            top: -30,
            child: _RingPattern(
              size: 330,
              borderColor: strokeColor,
              strokeWidth: 42,
            ),
          ),
          Positioned(
            left: -170,
            top: 240,
            child: _RingPattern(
              size: 280,
              borderColor: strokeColor,
              strokeWidth: 36,
            ),
          ),
          Positioned(
            right: -90,
            bottom: -190,
            child: _RingPattern(
              size: 390,
              borderColor: strokeColor,
              strokeWidth: 46,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingPattern extends StatelessWidget {
  const _RingPattern({
    required this.size,
    required this.borderColor,
    required this.strokeWidth,
  });

  final double size;
  final Color borderColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: strokeWidth),
        ),
      ),
    );
  }
}
