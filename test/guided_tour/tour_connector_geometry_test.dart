import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('connects from card bottom when target is below', () {
    final layout = const TourConnectorGeometry(
      cardRect: Rect.fromLTWH(24, 80, 280, 160),
      targetRect: Rect.fromLTWH(132, 420, 56, 56),
      screenSize: Size(360, 640),
      textDirection: TextDirection.ltr,
    ).resolve();

    expect(layout.side, TourConnectorSide.bottom);
    expect(layout.source.dy, 240);
    expect(layout.target.dy, 420);
  });

  test('connects from card top when target is above', () {
    final layout = const TourConnectorGeometry(
      cardRect: Rect.fromLTWH(24, 360, 280, 160),
      targetRect: Rect.fromLTWH(132, 40, 56, 56),
      screenSize: Size(360, 640),
      textDirection: TextDirection.ltr,
    ).resolve();

    expect(layout.side, TourConnectorSide.top);
    expect(layout.source.dy, 360);
    expect(layout.target.dy, 96);
  });

  test('uses side connector when target is horizontally closer', () {
    final layout = const TourConnectorGeometry(
      cardRect: Rect.fromLTWH(112, 220, 210, 160),
      targetRect: Rect.fromLTWH(18, 252, 52, 52),
      screenSize: Size(360, 640),
      textDirection: TextDirection.ltr,
    ).resolve();

    expect(layout.side, TourConnectorSide.left);
    expect(layout.source.dx, 112);
    expect(layout.target.dx, 70);
  });

  test('keeps RTL connector points inside a compact screen', () {
    final layout = const TourConnectorGeometry(
      cardRect: Rect.fromLTWH(16, 112, 328, 190),
      targetRect: Rect.fromLTWH(286, 28, 54, 54),
      screenSize: Size(360, 640),
      textDirection: TextDirection.rtl,
    ).resolve();

    for (final point in [
      layout.source,
      layout.target,
      layout.firstControl,
      layout.secondControl,
    ]) {
      expect(point.dx, inInclusiveRange(8, 352));
      expect(point.dy, inInclusiveRange(8, 632));
    }
  });
}
