import 'dart:math' as math;

import 'package:expenses_tracker/guided_tour/tour_connector_geometry.dart';
import 'package:expenses_tracker/guided_tour/tour_surface_style.dart';
import 'package:flutter/material.dart';

class TourConnectorPainter extends CustomPainter {
  const TourConnectorPainter({
    required this.cardRect,
    required this.targetRect,
    required this.textDirection,
    required this.style,
    required this.pulse,
  });

  final Rect cardRect;
  final Rect targetRect;
  final TextDirection textDirection;
  final TourSurfaceStyle style;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (cardRect.isEmpty || targetRect.isEmpty) return;

    final layout = TourConnectorGeometry(
      cardRect: cardRect,
      targetRect: targetRect,
      screenSize: size,
      textDirection: textDirection,
    ).resolve();
    final path = layout.toPath();
    final animatedWidth = 4.0 + (pulse * 1.5);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 18 + (pulse * 8)
        ..color = style.connectorGlowColor,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = animatedWidth
        ..color = style.connectorColor.withValues(alpha: 0.9),
    );

    final dotRadius = 5 + (pulse * 2);
    canvas.drawCircle(
      layout.source,
      dotRadius,
      Paint()..color = style.cardColor,
    );
    canvas.drawCircle(
      layout.source,
      dotRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = style.connectorColor,
    );

    final arrow = _arrowPath(layout.target, layout.arrowAngle);
    canvas.drawPath(arrow, Paint()..color = style.connectorColor);
  }

  Path _arrowPath(Offset tip, double angle) {
    const length = 13.0;
    const spread = math.pi / 7;
    final p1 =
        tip -
        Offset(
          math.cos(angle - spread) * length,
          math.sin(angle - spread) * length,
        );
    final p2 =
        tip -
        Offset(
          math.cos(angle + spread) * length,
          math.sin(angle + spread) * length,
        );
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
  }

  @override
  bool shouldRepaint(covariant TourConnectorPainter oldDelegate) {
    return oldDelegate.cardRect != cardRect ||
        oldDelegate.targetRect != targetRect ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.style != style ||
        oldDelegate.pulse != pulse;
  }
}
