import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('system language follows resolved app locale without currency',
      (tester) async {
    await _pumpLanguageProbe(
      tester,
      languagePreference: LanguagePreference.system,
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'USD',
      ),
    );

    expect(find.text('en:USD'), findsOneWidget);
  });

  testWidgets('Arabic language does not change USD base currency',
      (tester) async {
    await _pumpLanguageProbe(
      tester,
      languagePreference: LanguagePreference.arabic,
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'USD',
      ),
    );

    expect(find.text('ar:USD'), findsOneWidget);
  });

  testWidgets('English language does not change EGP base currency',
      (tester) async {
    await _pumpLanguageProbe(
      tester,
      languagePreference: LanguagePreference.english,
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
      ),
    );

    expect(find.text('en:EGP'), findsOneWidget);
  });
}

Future<void> _pumpLanguageProbe(
  WidgetTester tester, {
  required LanguagePreference languagePreference,
  required UserSettings settings,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: languagePreference.forcedLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final locale = Localizations.localeOf(context).languageCode;
          return Text('$locale:${settings.baseCurrency}');
        },
      ),
    ),
  );
  await tester.pump();
}
