import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('essentials step shows required controls and gates continue',
      (tester) async {
    final fixture = _OnboardingFixture();
    await fixture.pump(tester);

    expect(find.text('Choose your essentials'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-currency')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-payment')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('onboarding-primary-action')),
          )
          .onPressed,
      isNull,
    );

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

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('onboarding-primary-action')),
          )
          .onPressed,
      isNotNull,
    );

    await fixture.dispose();
  });

  testWidgets('AI intro explains preview, free limits, and manual fallback',
      (tester) async {
    final fixture = _OnboardingFixture();
    await fixture.cubit.load();
    fixture.cubit.selectLanguage(LanguagePreference.english);
    fixture.cubit.selectBaseCurrency('USD');
    fixture.cubit.selectPaymentMethod(PaymentMethod.wallet);
    fixture.cubit.continueFromEssentials();
    await fixture.pump(tester, loaded: true);

    expect(find.text('AI stays under your control'), findsOneWidget);
    expect(find.text('Preview first'), findsOneWidget);
    expect(find.text('Free daily limits'), findsOneWidget);
    expect(find.text('Manual entry always works'), findsOneWidget);
    expect(
      find.text(
          'Example only: "Lunch 12 USD by wallet". This sample is not sent to AI.'),
      findsOneWidget,
    );

    await fixture.dispose();
  });

  testWidgets('reminder step is optional and exposes daily and weekly choices',
      (tester) async {
    final fixture = _OnboardingFixture();
    await fixture.cubit.load();
    fixture.cubit.selectLanguage(LanguagePreference.english);
    fixture.cubit.selectBaseCurrency('USD');
    fixture.cubit.selectPaymentMethod(PaymentMethod.wallet);
    fixture.cubit.continueFromEssentials();
    fixture.cubit.continueFromAiIntro();
    await fixture.pump(tester, loaded: true);

    expect(find.text('Optional reminders'), findsOneWidget);
    expect(find.text('Daily expense check-in'), findsOneWidget);
    expect(find.text('Weekly spending digest'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-skip-reminders')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-daily-reminder')));
    await tester.pumpAndSettle();
    expect(fixture.cubit.state.notificationChoice.dailyReminderEnabled, isTrue);

    await fixture.dispose();
  });

  testWidgets('Arabic small viewport keeps setup usable', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _OnboardingFixture();
    await fixture.pump(tester, locale: const Locale('ar'));

    expect(find.text('إعداد أول تشغيل'), findsOneWidget);
    expect(find.text('اختر الأساسيات'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await fixture.dispose();
  });
}

class _OnboardingFixture {
  _OnboardingFixture()
      : settingsRepository = FakeSettingsRepository(
          UserSettings.defaults(
            userId: 'user-1',
            updatedAt: DateTime(2026, 5, 18),
          ),
        ) {
    cubit = OnboardingCubit(settingsRepository: settingsRepository);
  }

  final FakeSettingsRepository settingsRepository;
  late final OnboardingCubit cubit;
  int completedCalls = 0;

  Future<void> pump(
    WidgetTester tester, {
    bool loaded = false,
    Locale locale = const Locale('en'),
  }) async {
    if (!loaded) {
      await cubit.load();
    }
    await tester.pumpWidget(
      localizedTestApp(
        locale: locale,
        home: FirstRunSetupScreen.withCubit(
          cubit: cubit,
          onCompleted: (_) => completedCalls += 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose() => cubit.close();
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
