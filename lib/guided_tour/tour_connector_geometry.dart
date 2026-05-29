import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

enum TourConnectorSide { top, right, bottom, left }

@immutable
class TourConnectorGeometry {
  const TourConnectorGeometry({
    required this.cardRect,
    required this.targetRect,
    required this.screenSize,
    required this.textDirection,
  });

  final Rect cardRect;
  final Rect targetRect;
  final Size screenSize;
  final TextDirection textDirection;

  TourConnectorLayout resolve() {
    final side = _nearestCardSide();
    final source = _sourceFor(side);
    final target = _targetFor(source);
    final controlOffset = _controlOffsetFor(side, source, target);
    final firstControl = source + controlOffset;
    final secondControl = target - controlOffset;

    return TourConnectorLayout(
      side: side,
      source: _clampToScreen(source),
      target: _clampToScreen(target),
      firstControl: _clampToScreen(firstControl),
      secondControl: _clampToScreen(secondControl),
      arrowAngle: math.atan2(target.dy - source.dy, target.dx - source.dx),
    );
  }

  TourConnectorSide _nearestCardSide() {
    final delta = targetRect.center - cardRect.center;
    if (delta.dy.abs() >= delta.dx.abs()) {
      return delta.dy >= 0 ? TourConnectorSide.bottom : TourConnectorSide.top;
    }
    return delta.dx >= 0 ? TourConnectorSide.right : TourConnectorSide.left;
  }

  Offset _sourceFor(TourConnectorSide side) {
    final target = targetRect.center;
    switch (side) {
      case TourConnectorSide.top:
        return Offset(
          _clamp(target.dx, cardRect.left + 28, cardRect.right - 28),
          cardRect.top,
        );
      case TourConnectorSide.bottom:
        return Offset(
          _clamp(target.dx, cardRect.left + 28, cardRect.right - 28),
          cardRect.bottom,
        );
      case TourConnectorSide.left:
        return Offset(
          cardRect.left,
          _clamp(target.dy, cardRect.top + 28, cardRect.bottom - 28),
        );
      case TourConnectorSide.right:
        return Offset(
          cardRect.right,
          _clamp(target.dy, cardRect.top + 28, cardRect.bottom - 28),
        );
    }
  }

  Offset _targetFor(Offset source) {
    final center = targetRect.center;
    final dx = source.dx - center.dx;
    final dy = source.dy - center.dy;
    if (dx == 0 && dy == 0) return center;

    if (dx.abs() > dy.abs()) {
      return Offset(
        dx > 0 ? targetRect.right : targetRect.left,
        _clamp(source.dy, targetRect.top, targetRect.bottom),
      );
    }

    return Offset(
      _clamp(source.dx, targetRect.left, targetRect.right),
      dy > 0 ? targetRect.bottom : targetRect.top,
    );
  }

  Offset _controlOffsetFor(
    TourConnectorSide side,
    Offset source,
    Offset target,
  ) {
    final distance = (target - source).distance;
    final strength = _clamp(distance * 0.35, 36, 120);
    final rtlSign = textDirection == TextDirection.rtl ? -1.0 : 1.0;

    switch (side) {
      case TourConnectorSide.top:
        return Offset(18 * rtlSign, -strength);
      case TourConnectorSide.bottom:
        return Offset(18 * rtlSign, strength);
      case TourConnectorSide.left:
        return Offset(-strength, 18);
      case TourConnectorSide.right:
        return Offset(strength, 18);
    }
  }

  Offset _clampToScreen(Offset offset) {
    return Offset(
      _clamp(offset.dx, 8, screenSize.width - 8),
      _clamp(offset.dy, 8, screenSize.height - 8),
    );
  }

  double _clamp(double value, double min, double max) {
    if (max < min) return (min + max) / 2;
    return value.clamp(min, max).toDouble();
  }
}

@immutable
class TourConnectorLayout {
  const TourConnectorLayout({
    required this.side,
    required this.source,
    required this.target,
    required this.firstControl,
    required this.secondControl,
    required this.arrowAngle,
  });

  final TourConnectorSide side;
  final Offset source;
  final Offset target;
  final Offset firstControl;
  final Offset secondControl;
  final double arrowAngle;

  Path toPath() {
    return Path()
      ..moveTo(source.dx, source.dy)
      ..cubicTo(
        firstControl.dx,
        firstControl.dy,
        secondControl.dx,
        secondControl.dy,
        target.dx,
        target.dy,
      );
  }
}
