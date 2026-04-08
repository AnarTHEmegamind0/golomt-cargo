import 'dart:math' as math;
import 'package:core/core/brand_palette.dart';
import 'package:flutter/material.dart';

/// Beautiful animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 8),
  });

  final Widget child;
  final List<Color>? colors;
  final Duration duration;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultColors = isDark
        ? const [Color(0xFF0E1B33), Color(0xFF12396F), Color(0xFF0E1B33)]
        : const [Color(0xFFF5F9FF), Color(0xFFE3EEFF), Color(0xFFF0F6FF)];

    final colors = widget.colors ?? defaultColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_controller.value * 2 * math.pi),
                math.sin(_controller.value * 2 * math.pi),
              ),
              end: Alignment(
                math.cos((_controller.value + 0.5) * 2 * math.pi),
                math.sin((_controller.value + 0.5) * 2 * math.pi),
              ),
              colors: colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Floating shapes decoration
class FloatingShapes extends StatefulWidget {
  const FloatingShapes({super.key, this.shapeCount = 6, this.color});

  final int shapeCount;
  final Color? color;

  @override
  State<FloatingShapes> createState() => _FloatingShapesState();
}

class _FloatingShapesState extends State<FloatingShapes>
    with TickerProviderStateMixin {
  late final List<_ShapeData> _shapes;
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _shapes = List.generate(widget.shapeCount, (index) {
      return _ShapeData(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 60 + random.nextDouble() * 120,
        rotation: random.nextDouble() * 2 * math.pi,
        speed: 3 + random.nextDouble() * 5,
      );
    });

    _controllers = _shapes.map((shape) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: shape.speed.toInt()),
      )..repeat(reverse: true);
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ?? BrandPalette.electricBlue;

    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(_shapes.length, (index) {
            final shape = _shapes[index];
            final controller = _controllers[index];

            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final value = controller.value;
                return Positioned(
                  left:
                      shape.x * MediaQuery.of(context).size.width +
                      math.sin(value * 2 * math.pi) * 20,
                  top:
                      shape.y * MediaQuery.of(context).size.height +
                      math.cos(value * 2 * math.pi) * 30,
                  child: Transform.rotate(
                    angle: shape.rotation + value * math.pi,
                    child: Container(
                      width: shape.size,
                      height: shape.size,
                      decoration: BoxDecoration(
                        shape: index.isEven
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: index.isOdd
                            ? BorderRadius.circular(shape.size * 0.3)
                            : null,
                        gradient: RadialGradient(
                          colors: [
                            baseColor.withValues(alpha: 0.15),
                            baseColor.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _ShapeData {
  const _ShapeData({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
  });

  final double x;
  final double y;
  final double size;
  final double rotation;
  final double speed;
}

/// Modern mesh gradient background
class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0B1A33), Color(0xFF0F2C58)]
                  : const [Color(0xFFF7FBFF), Color(0xFFE1EDFF)],
            ),
          ),
        ),
        // Mesh spots - wrapped in ExcludeSemantics to avoid Flutter bug
        Positioned(
          top: -100,
          right: -100,
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandPalette.electricBlue.withValues(
                        alpha: isDark ? 0.3 : 0.35,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandPalette.navyBlue.withValues(
                        alpha: isDark ? 0.22 : 0.28,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: 50,
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandPalette.logoOrange.withValues(
                        alpha: isDark ? 0.18 : 0.22,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
