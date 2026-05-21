import 'package:expenses_tracker/screens/settings/widgets/support_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('support section states that expense data is not attached',
      (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: const Scaffold(
          body: SupportSettingsSection(),
        ),
      ),
    );

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
    expect(
      find.text('Send feedback without attaching expense data.'),
      findsOneWidget,
    );
  });
}
