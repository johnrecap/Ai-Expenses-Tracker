import 'package:expenses_tracker/screens/settings/widgets/privacy_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('privacy readiness rows are visible but not actionable',
      (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: const Scaffold(
          body: SingleChildScrollView(
            child: PrivacySettingsSection(),
          ),
        ),
      ),
    );

    for (final label in [
      'Backup export',
      'Restore preview',
      'Restore execution',
      'Wallets',
      'Transfers',
    ]) {
      expect(find.text(label), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.enabled, isFalse);
      expect(tile.onTap, isNull);
    }

    expect(
      find.textContaining('Restore execution is intentionally blocked'),
      findsOneWidget,
    );
  });
}
