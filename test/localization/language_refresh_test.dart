import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/expenses/views/expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('language preference rebuilds visible and newly opened routes',
      (tester) async {
    final cubit = AppLanguageCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<AppLanguageCubit>.value(
        value: cubit,
        child: BlocBuilder<AppLanguageCubit, LanguagePreference>(
          builder: (context, preference) {
            return MaterialApp(
              locale: preference.forcedLocale ?? const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    appBar: AppBar(title: Text(context.l10n.settings)),
                    body: Column(
                      children: [
                        Text(context.l10n.appLanguage),
                        TextButton(
                          onPressed: () => cubit
                              .setPreference(LanguagePreference.arabic),
                          child: const Text('Arabic'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const ExpensesScreen(expenses: []),
                              ),
                            );
                          },
                          child: const Text('Open expenses'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('App language'), findsOneWidget);
    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    expect(find.text('لغة التطبيق'), findsOneWidget);
    await tester.tap(find.text('Open expenses'));
    await tester.pumpAndSettle();

    expect(find.text('المصروفات'), findsOneWidget);
  });
}
