import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('incomplete onboarding settings show setup before Home',
      (tester) async {
    final settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(
        userId: 'user-1',
        updatedAt: DateTime(2026, 5, 18),
      ),
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: FirstRunOnboardingGate(
          settingsRepository: settingsRepository,
          expenseRepository: FakeExpenseRepository(),
          authenticatedBuilder: (_, __) => const Text('Authenticated Home'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First-run setup'), findsOneWidget);
    expect(find.text('Authenticated Home'), findsNothing);
  });

  testWidgets('completed onboarding settings bypass setup', (tester) async {
    final settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(
        userId: 'user-1',
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
        updatedAt: DateTime(2026, 5, 18),
      ),
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: FirstRunOnboardingGate(
          settingsRepository: settingsRepository,
          expenseRepository: FakeExpenseRepository(),
          authenticatedBuilder: (_, settings) => Text(
            'Authenticated Home ${settings.baseCurrency}',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First-run setup'), findsNothing);
    expect(find.text('Authenticated Home EGP'), findsOneWidget);
  });

  testWidgets('completion updates gate and opens authenticated content',
      (tester) async {
    final settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(
        userId: 'user-1',
        updatedAt: DateTime(2026, 5, 18),
      ),
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: FirstRunOnboardingGate(
          settingsRepository: settingsRepository,
          expenseRepository: FakeExpenseRepository(),
          authenticatedBuilder: (_, settings) => Text(
            'Authenticated Home ${settings.baseCurrency}',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-language-en')));
    await tester.pumpAndSettle();
    await _selectDropdownValue(
      tester,
      const Key('onboarding-currency'),
      'USD',
    );
    await _selectDropdownValue(
      tester,
      const Key('onboarding-payment'),
      'Wallet',
    );
    await tester.tap(find.byKey(const Key('onboarding-primary-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-primary-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-skip-reminders')));
    await tester.pumpAndSettle();

    expect(find.text('First-run setup'), findsNothing);
    expect(find.text('Authenticated Home USD'), findsOneWidget);
    expect(settingsRepository.settings.onboardingCompleted, isTrue);
  });
}

Future<void> _selectDropdownValue(
  WidgetTester tester,
  Key dropdownKey,
  String value,
) async {
  await tester.tap(find.byKey(dropdownKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}
