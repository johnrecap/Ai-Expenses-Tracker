import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_localizations_ar.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/ui_fixture_data.dart';

void main() {
  testWidgets('compact keyboard viewport keeps required add fields reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _AddExpenseLayoutFixture();
    await fixture.pump(tester, viewInsets: const EdgeInsets.only(bottom: 280));

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ai-expense-form-fill-input')),
      'اشتريت مستلزمات منزلية طويلة الوصف بقيمة 250 جنيه كاش',
    );
    await tester.ensureVisible(
      find.byKey(const Key('add-expense-amount-field')),
    );
    await tester.ensureVisible(
      find.byKey(const Key('add-expense-category-field')),
    );
    await tester.ensureVisible(find.text('Save'));

    expect(find.byKey(const Key('ai-expense-form-fill-input')), findsOneWidget);
    expect(find.byKey(const Key('add-expense-amount-field')), findsOneWidget);
    expect(find.byKey(const Key('add-expense-category-field')), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await fixture.dispose();
  });

  testWidgets('receipt unavailable state stays reachable on compact viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _AddExpenseLayoutFixture();
    await fixture.pump(tester);

    await tester.tap(find.text('Receipt'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));

    expect(
      find.textContaining('Provider-backed AI is unavailable'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await fixture.dispose();
  });

  testWidgets(
    'Arabic RTL add expense controls stay reachable on compact keyboard viewport',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = _AddExpenseLayoutFixture();
      final ar = AppLocalizationsAr();
      await fixture.pump(
        tester,
        locale: const Locale('ar'),
        viewInsets: const EdgeInsets.only(bottom: 280),
      );

      await tester.tap(find.text(ar.quickCaptureNatural));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('ai-expense-form-fill-input')),
        'اشتريت مستلزمات منزلية طويلة الوصف بقيمة 250 جنيه كاش',
      );
      await tester.ensureVisible(
        find.byKey(const Key('add-expense-amount-field')),
      );
      await tester.ensureVisible(
        find.byKey(const Key('add-expense-category-field')),
      );
      await tester.ensureVisible(find.text(ar.save));

      expect(
        find.byKey(const Key('ai-expense-form-fill-input')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('add-expense-amount-field')), findsOneWidget);
      expect(
        find.byKey(const Key('add-expense-category-field')),
        findsOneWidget,
      );
      expect(find.text(ar.save), findsOneWidget);
      expect(tester.takeException(), isNull);

      await fixture.dispose();
    },
  );
}

class _AddExpenseLayoutFixture {
  _AddExpenseLayoutFixture() {
    authRepository = FakeAuthRepository(UiFixtureData.user);
    expenseRepository = FakeExpenseRepository();
    categoryRepository = FakeCategoryRepository(UiFixtureData.categories());
    budgetRepository = FakeBudgetRepository(UiFixtureData.budget());
    settingsRepository = FakeSettingsRepository(UiFixtureData.settings());
  }

  late final FakeAuthRepository authRepository;
  late final FakeExpenseRepository expenseRepository;
  late final FakeCategoryRepository categoryRepository;
  late final FakeBudgetRepository budgetRepository;
  late final FakeSettingsRepository settingsRepository;

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
          RepositoryProvider<CategoryRepository>.value(
            value: categoryRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: settingsRepository,
          ),
          RepositoryProvider<BudgetRepository>.value(value: budgetRepository),
          RepositoryProvider<CategoryAliasRepository>(
            create: (_) => FakeCategoryAliasRepository(),
          ),
          RepositoryProvider<AiActionLogRepository>(
            create: (_) => FakeAiActionLogRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CreateCategoryBloc(categoryRepository)),
            BlocProvider(
              create: (_) => CreateExpenseBloc(
                expenseRepository,
                budgetRepository: budgetRepository,
                settingsRepository: settingsRepository,
              ),
            ),
            BlocProvider(
              create: (_) =>
                  GetCategoriesBloc(categoryRepository)..add(GetCategories()),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
                child: child!,
              );
            },
            home: const AddExpense(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    await authRepository.close();
    await expenseRepository.close();
  }
}
