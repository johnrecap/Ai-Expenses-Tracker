import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/monetization/views/free_premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Free state shows Free active', (tester) async {
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.allowed()),
      adService: FakeAdService(),
    );
    await cubit.load();

    await tester.pumpWidget(
      _localizedApp(FreePremiumScreen(cubit: cubit)),
    );

    expect(find.text('Free plan'), findsOneWidget);
    expect(find.textContaining('Free keeps manual expenses'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('Premium state shows ads disabled', (tester) async {
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(
        initialSnapshot: EntitlementSnapshot.premiumFixture(),
      ),
      policyRepository: const LocalMonetizationPolicyRepository(),
    );
    await cubit.load();

    await tester.pumpWidget(
      _localizedApp(FreePremiumScreen(cubit: cubit)),
    );

    expect(find.text('Premium plan'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Ads disabled'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('Quota usage card renders limits and CTA is honest',
      (tester) async {
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
    );
    await cubit.load();

    await tester.pumpWidget(
      _localizedApp(FreePremiumScreen(cubit: cubit)),
    );

    expect(find.text('Today AI usage'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Premium coming soon'), findsOneWidget);
    final checkAvailability = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Check availability'),
    );
    final restorePurchases = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Restore purchases'),
    );
    expect(checkAvailability.onPressed, isNull);
    expect(restorePurchases.onPressed, isNull);
    expect(find.byType(BackButton), findsOneWidget);
    await cubit.close();
  });
}

Widget _localizedApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
