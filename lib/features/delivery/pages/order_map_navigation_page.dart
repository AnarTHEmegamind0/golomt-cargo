import 'package:core/features/delivery/services/location_service.dart';
import 'package:core/features/delivery/widgets/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderMapNavigationPage extends StatelessWidget {
  const OrderMapNavigationPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final locationService = context.read<LocationService>();

    return Scaffold(
      appBar: AppBar(title: Text('Navigation $orderId')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A4C57), Color(0xFF92ABB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _RoutePainter()),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GlassSheet(
              child: StreamBuilder<DriverLocation>(
                stream: locationService.trackDriver(),
                builder: (context, snapshot) {
                  final location = snapshot.data;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.navigation_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Live tracking',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        location == null
                            ? 'Locking GPS...'
                            : 'Lat ${location.latitude.toStringAsFixed(4)} • Lng ${location.longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Mark arrived'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF0A9A0), Color(0xFFFFE7DC)],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.58,
        size.width * 0.47,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.48,
        size.width * 0.86,
        size.height * 0.24,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
