import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('View All opens the expenses list', (tester) async {
    final fixture = _HomeFixture();
    await fixture.pumpMainScreen(tester);

    await tester.ensureVisible(find.text('View All'));
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();

    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('coffee commute'), findsOneWidget);

    await fixture.dispose();
  });

  testWidgets('settings shortcut opens Settings with required providers', (
    tester,
  ) async {
    final fixture = _HomeFixture();
    await fixture.pumpMainScreen(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);

    await fixture.dispose();
  });

  testWidgets('Home transaction edit updates expense through repository', (
    tester,
  ) async {
    final fixture = _HomeFixture();
    await fixture.pumpMainScreen(tester);

    await tester.ensureVisible(find.byTooltip('Expense actions'));
    await tester.tap(find.byTooltip('Expense actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();

    expect(find.text('Edit expense'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '150'), '175');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fixture.expenseRepository.updatedExpenses, hasLength(1));
    expect(fixture.expenseRepository.updatedExpenses.single.amount, 175);

    await fixture.dispose();
  });

  testWidgets('budget manage action opens Monthly Budget screen', (
    tester,
  ) async {
    final fixture = _HomeFixture();
    await fixture.pumpMainScreen(tester);

    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Budget'), findsWidgets);
    expect(find.text('Budget amount'), findsOneWidget);

    await fixture.dispose();
  });

  testWidgets('Home refreshes daily exchange rates for mixed currencies', (
    tester,
  ) async {
    final fixture = _HomeFixture();
    final usdExpense = Expense(
      expenseId: 'usd-expense',
      userId: fixture.user.userId,
      category: fixture.category,
      date: DateTime(2026, 5, 15),
      amount: 100,
      description: 'usd commute',
      paymentMethod: PaymentMethod.cash,
      currency: 'USD',
    );
    await fixture.pumpHomeScreen(
      tester,
      screenExpenses: [usdExpense],
      exchangeRateService: const _FakeExchangeRateService({'USD': 50}),
    );

    expect(find.text('5,000 EGP'), findsWidgets);
    expect(find.textContaining('Missing rates'), findsNothing);

    await fixture.dispose();
  });

  testWidgets('plus opens Add Expense with AI form fill card', (tester) async {
    final fixture = _HomeFixture();
    await fixture.pumpHomeScreen(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Fill with AI'), findsOneWidget);
    expect(find.byKey(const Key('ai-expense-form-fill-input')), findsOneWidget);

    await fixture.dispose();
  });

  testWidgets('logout asks for confirmation before sign-out', (tester) async {
    final fixture = _HomeFixture();
    await fixture.pumpHomeScreen(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout').last);
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(fixture.authRepository.signOutCalls, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(fixture.authRepository.signOutCalls, 1);

    await fixture.dispose();
  });
}

class _HomeFixture {
  _HomeFixture()
    : user = AppUser(
        userId: 'user-1',
        email: 'john@example.com',
        displayName: 'John Doe',
        photoUrl: null,
        createdAt: DateTime(2026, 5, 1),
      ) {
    authRepository = FakeAuthRepository(user);
    expenseRepository = FakeExpenseRepository(expenses);
    categoryRepository = FakeCategoryRepository([category]);
    settingsRepository = FakeSettingsRepository(settings);
    budgetRepository = FakeBudgetRepository(budget);
    monetizationCubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService: FakeAdConsentService(
        consentState: ConsentState.allowed(),
      ),
      adService: FakeAdService(),
    );
    appLockCubit = AppLockCubit(appLockService: fakeAppLockService());
  }

  late final AppUser user;
  late final FakeAuthRepository authRepository;
  late final FakeExpenseRepository expenseRepository;
  late final FakeCategoryRepository categoryRepository;
  late final FakeSettingsRepository settingsRepository;
  late final FakeBudgetRepository budgetRepository;
  late final MonetizationCubit monetizationCubit;
  late final AppLockCubit appLockCubit;

  final category = Category(
    categoryId: 'transport',
    userId: 'user-1',
    name: 'Transport',
    totalExpenses: 0,
    icon: 'transport',
    color: 0xFF1565C0,
  );

  late final settings = UserSettings.defaults(
    userId: user.userId,
    updatedAt: DateTime(2026, 5, 1),
  );

  late final budget = Budget(
    budgetId: Budget.budgetIdFor(month: 5, year: 2026),
    userId: user.userId,
    month: 5,
    year: 2026,
    amount: 1000,
    currency: 'EGP',
    warningThresholdPercent: 80,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );

  late final expenses = [
    Expense(
      expenseId: 'expense-1',
      userId: user.userId,
      category: category,
      date: DateTime(2026, 5, 15),
      amount: 150,
      description: 'coffee commute',
      paymentMethod: PaymentMethod.cash,
      currency: 'EGP',
    ),
  ];

  Future<void> pumpMainScreen(
    WidgetTester tester, {
    List<Expense>? screenExpenses,
    UserSettings? screenSettings,
  }) async {
    await monetizationCubit.load();
    await appLockCubit.initialize();
    await tester.pumpWidget(
      _withAppProviders(
        BlocProvider<BudgetBloc>(
          create: (_) =>
              BudgetBloc(budgetRepository)
                ..add(const BudgetWatchRequested(month: 5, year: 2026)),
          child: MainScreen(
            screenExpenses ?? expenses,
            user: user,
            settings: screenSettings ?? settings,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    List<Expense>? screenExpenses,
    ExchangeRateService? exchangeRateService,
  }) async {
    await monetizationCubit.load();
    await appLockCubit.initialize();

    final authBloc = AuthBloc(authRepository)..add(AuthUserChanged(user));
    final expensesBloc = GetExpensesBloc(expenseRepository)
      ..add(const GetExpenses());

    await tester.pumpWidget(
      _withAppProviders(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<GetExpensesBloc>.value(value: expensesBloc),
          ],
          child: HomeScreen(
            exchangeRateService:
                exchangeRateService ?? const _FakeExchangeRateService({}),
          ),
        ),
      ),
    );
    await tester.pump();
    expenseRepository.emit(screenExpenses ?? expenses);
    await tester.pumpAndSettle();
  }

  Widget _withAppProviders(Widget home) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
        RepositoryProvider<BudgetRepository>.value(value: budgetRepository),
        RepositoryProvider<CategoryBudgetRepository>(
          create: (_) => FakeCategoryBudgetRepository(),
        ),
        RepositoryProvider<RecurringExpenseRepository>(
          create: (_) => FakeRecurringExpenseRepository(),
        ),
        RepositoryProvider<SavingGoalRepository>(
          create: (_) => FakeSavingGoalRepository(),
        ),
        RepositoryProvider<CategoryAliasRepository>(
          create: (_) => FakeCategoryAliasRepository(),
        ),
        RepositoryProvider<AiActionLogRepository>(
          create: (_) => FakeAiActionLogRepository(),
        ),
        RepositoryProvider<AdService>.value(value: FakeAdService()),
        RepositoryProvider<ObservabilityService>.value(
          value: const NoopObservabilityService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
          BlocProvider<AppLockCubit>.value(value: appLockCubit),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await expenseRepository.close();
    await authRepository.close();
    await monetizationCubit.close();
    await appLockCubit.close();
  }
}

class _FakeExchangeRateService implements ExchangeRateService {
  const _FakeExchangeRateService(this.rates);

  final Map<String, double> rates;

  @override
  Future<Map<String, double>> latestRates({
    required String baseCurrency,
    required Iterable<String> quoteCurrencies,
  }) async {
    return {
      for (final quote in quoteCurrencies)
        if (rates.containsKey(quote.trim().toUpperCase()))
          quote.trim().toUpperCase(): rates[quote.trim().toUpperCase()]!,
    };
  }
}
