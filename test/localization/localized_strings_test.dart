import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('core release strings are available in English', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Column(
            textDirection: TextDirection.ltr,
            children: [
              Text(context.l10n.confirmLogoutTitle),
              Text(context.l10n.categoryBudgets),
              Text(context.l10n.subscriptionCenter),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.text('Category Budgets'), findsOneWidget);
    expect(find.text('Subscription Center'), findsOneWidget);
  });

  testWidgets('core release strings are available in Arabic', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale('ar'),
        home: Builder(
          builder: (context) => Column(
            textDirection: TextDirection.rtl,
            children: [
              Text(context.l10n.confirmLogoutTitle),
              Text(context.l10n.categoryBudgets),
              Text(context.l10n.subscriptionCenter),
            ],
          ),
        ),
      ),
    );

    final renderedTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .toList();

    expect(renderedTexts, hasLength(3));
    expect(renderedTexts, isNot(contains('Log out?')));
    expect(renderedTexts, isNot(contains('Category Budgets')));
    expect(renderedTexts, isNot(contains('Subscription Center')));
  });
}
