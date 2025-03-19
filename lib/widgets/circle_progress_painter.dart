import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Glow effect background
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,  // Começa do topo
      2 * math.pi * progress,  // Progresso completo
      false,
      glowPaint,
    );

    // Main progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw little dots at the beginning and the end of the arc
    final startAngle = -math.pi / 2;
    final endAngle = startAngle + (2 * math.pi * progress);

    // Draw the main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      paint,
    );

    // Add a dot at the end of the progress arc (if not complete)
    if (progress > 0 && progress < 1) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth / 1.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}