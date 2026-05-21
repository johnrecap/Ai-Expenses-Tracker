import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('quick capture keeps AI draft above fields when selected',
      (tester) async {
    final fixture = _AddExpenseFixture();
    await fixture.pump(tester);

    expect(find.text('Quick'), findsOneWidget);
    expect(find.byKey(const Key('add-expense-amount-field')), findsOneWidget);
    expect(find.byKey(const Key('ai-expense-form-fill-input')), findsNothing);

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();

    final aiInput = find.byKey(const Key('ai-expense-form-fill-input'));
    final amountField = find.byKey(const Key('add-expense-amount-field'));
    expect(aiInput, findsOneWidget);
    expect(amountField, findsOneWidget);
    expect(
      tester.getTopLeft(aiInput).dy < tester.getTopLeft(amountField).dy,
      isTrue,
    );

    await tester.enterText(
      aiInput,
      'spent 12.5 dollars on food last night with visa',
    );
    await tester.tap(find.byKey(const Key('ai-expense-form-fill-button')));
    await tester.pumpAndSettle();

    final amountWidget = tester.widget<TextFormField>(amountField);
    final descriptionWidget = tester.widget<TextFormField>(
      find.byKey(const Key('add-expense-description-field')),
    );
    final categoryWidget = tester.widget<TextFormField>(
      find.byKey(const Key('add-expense-category-field')),
    );

    expect(amountWidget.controller?.text, '12.5');
    expect(descriptionWidget.controller?.text, 'AI Food expense');
    expect(categoryWidget.controller?.text, 'Food');
    expect(find.text('USD'), findsWidgets);
    expect(find.text('Visa'), findsWidgets);

    await fixture.dispose();
  });

  testWidgets('AI form fill card accepts long Arabic input on compact width',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _AddExpenseFixture();
    await fixture.pump(tester);

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ai-expense-form-fill-input')),
      'دفعت ١٢٥ جنيه على أكل ومستلزمات بيت من السوبر ماركت بالكاش',
    );
    await tester.ensureVisible(
      find.byKey(const Key('ai-expense-form-fill-button')),
    );

    expect(find.byKey(const Key('ai-expense-form-fill-input')), findsOneWidget);
    expect(find.byKey(const Key('ai-expense-form-fill-button')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await fixture.dispose();
  });
}

class _AddExpenseFixture {
  _AddExpenseFixture()
      : user = AppUser(
          userId: 'user-1',
          email: 'user@example.com',
          displayName: 'User',
          photoUrl: null,
          createdAt: DateTime(2026, 5, 1),
        ) {
    authRepository = FakeAuthRepository(user);
    expenseRepository = FakeExpenseRepository();
    categoryRepository = FakeCategoryRepository([food]);
    budgetRepository = FakeBudgetRepository();
    settingsRepository = FakeSettingsRepository(
      UserSettings.defaults(userId: user.userId).copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        defaultPaymentMethod: PaymentMethod.cash,
      ),
    );
  }

  late final AppUser user;
  late final FakeAuthRepository authRepository;
  late final FakeExpenseRepository expenseRepository;
  late final FakeCategoryRepository categoryRepository;
  late final FakeBudgetRepository budgetRepository;
  late final FakeSettingsRepository settingsRepository;

  final food = Category(
    categoryId: 'food',
    userId: 'user-1',
    name: 'Food',
    totalExpenses: 0,
    icon: 'food',
    color: 0xFFE65100,
  );

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
          RepositoryProvider<CategoryRepository>.value(
              value: categoryRepository),
          RepositoryProvider<SettingsRepository>.value(
              value: settingsRepository),
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
            BlocProvider(
              create: (_) => CreateCategoryBloc(categoryRepository),
            ),
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
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AddExpense(),
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
