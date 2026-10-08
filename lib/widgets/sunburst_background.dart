import 'dart:math';
import 'package:flutter/material.dart';

class SunburstBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Alignment originAlignment;

  const SunburstBackground({
    super.key,
    required this.child,
    this.opacity = 0.5,
    this.originAlignment = const Alignment(0, -0.6),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SunburstPainter(
              opacity: opacity,
              alignment: originAlignment,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final double opacity;
  final Alignment alignment;

  _SunburstPainter({required this.opacity, required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2 + alignment.x * (size.width / 2),
      size.height / 2 + alignment.y * (size.height / 2),
    );

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    const int rayCount = 18;
    final double maxDim = sqrt(size.width * size.width + size.height * size.height) * 1.5;
    final double angleStep = (2 * pi) / rayCount;

    for (int i = 0; i < rayCount; i += 2) {
      final double startAngle = i * angleStep;
      final double endAngle = (i + 1) * angleStep;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + maxDim * cos(startAngle),
          center.dy + maxDim * sin(startAngle),
        )
        ..lineTo(
          center.dx + maxDim * cos(endAngle),
          center.dy + maxDim * sin(endAngle),
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.alignment != alignment;
}
