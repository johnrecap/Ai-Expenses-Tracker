import 'package:expenses_tracker/screens/reports/views/reports_screen.dart';
import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';
import '../helpers/ui_fixture_data.dart';

void main() {
  testWidgets('Reports summary fits compact mixed-currency stress data',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      localizedTestApp(
        home: ReportsScreen(
          expenses: UiFixtureData.expenses(),
          settings: UiFixtureData.settings(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.textContaining('Top category'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
