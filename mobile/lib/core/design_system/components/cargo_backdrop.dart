import 'package:core/core/brand_palette.dart';
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
              colors: [Color(0xFFF9EBD5), Color(0xFFE8EFFC), Color(0xFFDCE7FA)],
              stops: [0.0, 0.48, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          )
        : const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF132A52), Color(0xFF1A3A6A), Color(0xFF234879)],
              stops: [0.0, 0.52, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );

    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _DarkhanHighwayPainter(light: light),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _DarkhanHighwayPainter extends CustomPainter {
  const _DarkhanHighwayPainter({required this.light});

  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSunGlow(canvas, size);
    _drawFarHills(canvas, size);
    _drawCitySilhouette(canvas, size);
    _drawBridge(canvas, size);
    _drawHighway(canvas, size);
  }

  void _drawSunGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.70, size.height * 0.23);
    final rect = Rect.fromCircle(center: center, radius: size.width * 0.36);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: light
            ? [
                BrandPalette.logoOrange.withValues(alpha: 0.20),
                Colors.transparent,
              ]
            : [
                BrandPalette.logoOrange.withValues(alpha: 0.13),
                Colors.transparent,
              ],
      ).createShader(rect);
    canvas.drawCircle(center, size.width * 0.36, paint);
  }

  void _drawFarHills(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.45,
        size.width * 0.45,
        size.height * 0.53,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.44,
        size.width,
        size.height * 0.52,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color = light
          ? BrandPalette.primaryText.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.06);

    canvas.drawPath(path, paint);
  }

  void _drawCitySilhouette(Canvas canvas, Size size) {
    final baseY = size.height * 0.63;

    // Atmospheric haze to keep city soft and non-distracting.
    final hazeRect = Rect.fromLTWH(0, baseY - 70, size.width, 86);
    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: light
            ? [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.0),
              ]
            : [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.0),
              ],
      ).createShader(hazeRect);
    canvas.drawRect(hazeRect, hazePaint);

    final distantColor = light
        ? const Color(0xFF40679F).withValues(alpha: 0.28)
        : const Color(0xFF9EBBEB).withValues(alpha: 0.20);
    final midColor = light
        ? const Color(0xFF2B4E88).withValues(alpha: 0.34)
        : const Color(0xFFC8DAFA).withValues(alpha: 0.24);
    final foregroundColor = light
        ? const Color(0xFF1B3C74).withValues(alpha: 0.42)
        : const Color(0xFFE2ECFF).withValues(alpha: 0.28);

    final distantPath = Path();
    final distantHeights = [
      22.0,
      28.0,
      19.0,
      26.0,
      31.0,
      18.0,
      24.0,
      20.0,
      27.0,
    ];
    var x = size.width * 0.03;
    for (final h in distantHeights) {
      final w = 22.0;
      distantPath.addRect(Rect.fromLTWH(x, baseY - h - 8, w, h));
      x += w + 7;
    }
    canvas.drawPath(distantPath, Paint()..color = distantColor);

    final midPath = Path();
    final midHeights = [
      34.0,
      45.0,
      39.0,
      52.0,
      43.0,
      49.0,
      37.0,
      56.0,
      41.0,
      47.0,
      36.0,
    ];
    x = size.width * 0.04;
    for (var i = 0; i < midHeights.length; i++) {
      final w = i.isEven ? 20.0 : 24.0;
      final h = midHeights[i];
      midPath.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - h, w, h),
          const Radius.circular(1.5),
        ),
      );
      x += w + 8;
    }
    canvas.drawPath(midPath, Paint()..color = midColor);

    final foregroundBuildings = <(double x, double w, double h)>[
      (size.width * 0.06, 24, 36),
      (size.width * 0.13, 28, 56),
      (size.width * 0.21, 20, 42),
      (size.width * 0.28, 30, 62),
      (size.width * 0.37, 24, 48),
      (size.width * 0.45, 20, 72),
      (size.width * 0.53, 26, 44),
      (size.width * 0.62, 30, 66),
      (size.width * 0.72, 22, 46),
      (size.width * 0.79, 30, 58),
      (size.width * 0.89, 24, 40),
    ];

    final lightTones = <Color>[
      const Color(0xFF22C55E).withValues(alpha: 0.75), // fresh green
      const Color(0xFF8B5CF6).withValues(alpha: 0.47), // vibrant purple
      const Color(0xFFEF4444).withValues(alpha: 0.70), // soft red accent
      const Color(0xFF2563EB).withValues(alpha: 0.48), // royal blue
      const Color(0xFF10B981).withValues(alpha: 0.50), // emerald green
      const Color(0xFF1E40AF).withValues(alpha: 0.52), // deep blue
    ];
    final darkTones = <Color>[
      const Color(0xFF22C55E).withValues(alpha: 0.75), // fresh green
      const Color(0xFF8B5CF6).withValues(alpha: 0.47), // vibrant purple
      const Color(0xFF1E40AF).withValues(alpha: 0.52), // deep blue
      const Color(0xFF2563EB).withValues(alpha: 0.48), // royal blue
    ];

    for (var i = 0; i < foregroundBuildings.length; i++) {
      final b = foregroundBuildings[i];
      final buildingRect = Rect.fromLTWH(b.$1, baseY - b.$3 + 4, b.$2, b.$3);
      final buildingPaint = Paint()
        ..color = (light ? lightTones : darkTones)[i % 4]
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(buildingRect, const Radius.circular(2)),
        buildingPaint,
      );
    }

    // Landmark spire for city character.
    final spire = Path()
      ..moveTo(size.width * 0.47, baseY - 72)
      ..lineTo(size.width * 0.485, baseY - 114)
      ..lineTo(size.width * 0.50, baseY - 72)
      ..close();

    final fgPaint = Paint()..color = foregroundColor;
    canvas.drawPath(spire, fgPaint);

    // Tiny windows across building fronts.
    final windowPaint = Paint()
      ..color = BrandPalette.logoOrange.withValues(alpha: light ? 0.40 : 0.30)
      ..style = PaintingStyle.fill;

    final windowW = 2.4;
    final windowH = 3.6;
    for (var i = 0; i < foregroundBuildings.length; i++) {
      final b = foregroundBuildings[i];
      final left = b.$1 + 3;
      final top = baseY - b.$3 + 9;
      final cols = (b.$2 / 5).floor().clamp(2, 5);
      final rows = (b.$3 / 9).floor().clamp(2, 8);
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          if ((r + c + i) % 2 != 0) continue;
          final x = left + c * 4.9;
          final y = top + r * 6.8;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, windowW, windowH),
              const Radius.circular(0.6),
            ),
            windowPaint,
          );
        }
      }
    }

    final baselinePaint = Paint()
      ..color = light
          ? BrandPalette.logoOrange.withValues(alpha: 0.42)
          : BrandPalette.logoOrange.withValues(alpha: 0.34)
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.04, baseY + 3),
      Offset(size.width * 0.96, baseY + 3),
      baselinePaint,
    );
  }

  void _drawBridge(Canvas canvas, Size size) {
    final y = size.height * 0.685;
    final bridgeColor = light
        ? BrandPalette.navyBlue.withValues(alpha: 0.23)
        : Colors.white.withValues(alpha: 0.16);
    final cableColor = light
        ? BrandPalette.electricBlue.withValues(alpha: 0.24)
        : Colors.white.withValues(alpha: 0.18);

    final deckPaint = Paint()
      ..color = bridgeColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.08, y),
      Offset(size.width * 0.92, y),
      deckPaint,
    );

    final pillarPaint = Paint()
      ..color = bridgeColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.34, y),
      Offset(size.width * 0.34, y - 24),
      pillarPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, y),
      Offset(size.width * 0.66, y - 24),
      pillarPaint,
    );

    final cablePaint = Paint()
      ..color = cableColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cablePath = Path()
      ..moveTo(size.width * 0.18, y)
      ..quadraticBezierTo(size.width * 0.34, y - 34, size.width * 0.50, y)
      ..quadraticBezierTo(size.width * 0.66, y - 34, size.width * 0.82, y);
    canvas.drawPath(cablePath, cablePaint);
  }

  void _drawHighway(Canvas canvas, Size size) {
    final roadPath = Path()
      ..moveTo(size.width * 0.16, size.height)
      ..lineTo(size.width * 0.44, size.height * 0.64)
      ..lineTo(size.width * 0.56, size.height * 0.64)
      ..lineTo(size.width * 0.84, size.height)
      ..close();

    final roadPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: light
                ? [
                    BrandPalette.navyBlue.withValues(alpha: 0.10),
                    BrandPalette.primaryText.withValues(alpha: 0.18),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.15),
                  ],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.62, size.width, size.height),
          );

    canvas.drawPath(roadPath, roadPaint);

    final shoulderPaint = Paint()
      ..color = light
          ? BrandPalette.electricBlue.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.44, size.height * 0.64),
      Offset(size.width * 0.16, size.height),
      shoulderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.56, size.height * 0.64),
      Offset(size.width * 0.84, size.height),
      shoulderPaint,
    );

    _drawDashedLine(
      canvas,
      from: Offset(size.width * 0.50, size.height * 0.66),
      to: Offset(size.width * 0.50, size.height * 0.95),
      color: BrandPalette.logoOrange.withValues(alpha: light ? 0.52 : 0.44),
      strokeWidth: 2,
      dashLength: 10,
      gapLength: 10,
    );
  }

  void _drawDashedLine(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Color color,
    required double strokeWidth,
    required double dashLength,
    required double gapLength,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final vector = to - from;
    final totalLength = vector.distance;
    if (totalLength == 0) return;

    final direction = vector / totalLength;
    var drawn = 0.0;
    while (drawn < totalLength) {
      final start = from + direction * drawn;
      final end =
          from + direction * (drawn + dashLength).clamp(0.0, totalLength);
      canvas.drawLine(start, end, paint);
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _DarkhanHighwayPainter oldDelegate) {
    return oldDelegate.light != light;
  }
}
