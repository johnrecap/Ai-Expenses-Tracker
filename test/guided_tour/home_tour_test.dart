import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('auto-shows AI spotlight after onboarding completion', (
    tester,
  ) async {
    final fixture = _HomeTourFixture();
    await fixture.pump(tester);

    expect(find.text('Meet the AI Assistant'), findsOneWidget);
    expect(fixture.guidedTourCubit.state.activeStep?.stepId, 'ai_assistant');
    expect(fixture.guidedTourCubit.state.targetAvailable, isTrue);

    await fixture.dispose();
  });

  testWidgets('completed tour version suppresses auto-show', (tester) async {
    final fixture = _HomeTourFixture(
      settings: _settings().copyWith(
        guidedTourCompletedVersion: guidedTourVersion,
      ),
    );
    await fixture.pump(tester);

    expect(find.text('Meet the AI Assistant'), findsNothing);
    expect(fixture.guidedTourCubit.state.isActive, isFalse);

    await fixture.dispose();
  });

  testWidgets('advancing AI spotlight does not call ad services', (
    tester,
  ) async {
    final fixture = _HomeTourFixture();
    await fixture.pump(tester);
    final initialInterstitialShows = fixture.adService.interstitialShows;
    final initialRewardedShows = fixture.adService.rewardedShows;

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(fixture.adService.interstitialShows, initialInterstitialShows);
    expect(fixture.adService.rewardedShows, initialRewardedShows);
    expect(fixture.guidedTourCubit.state.activeStep?.stepId, 'manual_expense');

    await fixture.dispose();
  });

  testWidgets('core Home targets register for the tour sequence', (
    tester,
  ) async {
    final fixture = _HomeTourFixture();
    await fixture.pump(tester);

    expect(
      fixture.guidedTourCubit.state.activeStep?.targetId,
      GuidedTourTargetIds.aiAssistant,
    );
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(
      fixture.guidedTourCubit.state.activeStep?.targetId,
      GuidedTourTargetIds.manualExpense,
    );
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(
      fixture.guidedTourCubit.state.activeStep?.targetId,
      GuidedTourTargetIds.budget,
    );

    await fixture.dispose();
  });
}

UserSettings _settings() {
  return UserSettings.defaults(
    userId: 'user-1',
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
    updatedAt: DateTime(2026, 5, 18),
  );
}

class _HomeTourFixture {
  _HomeTourFixture({UserSettings? settings})
    : user = AppUser(
        userId: 'user-1',
        email: 'john@example.com',
        displayName: 'John Doe',
        photoUrl: null,
        createdAt: DateTime(2026, 5, 1),
      ),
      settings = settings ?? _settings() {
    authRepository = FakeAuthRepository(user);
    expenseRepository = FakeExpenseRepository(expenses);
    categoryRepository = FakeCategoryRepository([category]);
    settingsRepository = FakeSettingsRepository(this.settings);
    budgetRepository = FakeBudgetRepository(budget);
    adService = FakeAdService();
    monetizationCubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService: FakeAdConsentService(
        consentState: ConsentState.allowed(),
      ),
      adService: adService,
    );
    appLockCubit = AppLockCubit(appLockService: fakeAppLockService());
    guidedTourCubit = GuidedTourCubit(settingsRepository: settingsRepository);
  }

  late final AppUser user;
  final UserSettings settings;
  late final FakeAuthRepository authRepository;
  late final FakeExpenseRepository expenseRepository;
  late final FakeCategoryRepository categoryRepository;
  late final FakeSettingsRepository settingsRepository;
  late final FakeBudgetRepository budgetRepository;
  late final FakeAdService adService;
  late final MonetizationCubit monetizationCubit;
  late final AppLockCubit appLockCubit;
  late final GuidedTourCubit guidedTourCubit;

  final category = Category(
    categoryId: 'transport',
    userId: 'user-1',
    name: 'Transport',
    totalExpenses: 0,
    icon: 'transport',
    color: 0xFF1565C0,
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

  Future<void> pump(WidgetTester tester) async {
    await monetizationCubit.load();
    await appLockCubit.initialize();

    final authBloc = AuthBloc(authRepository)..add(AuthUserChanged(user));
    final expensesBloc = GetExpensesBloc(expenseRepository)
      ..add(const GetExpenses());

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
          RepositoryProvider<CategoryRepository>.value(
            value: categoryRepository,
          ),
          RepositoryProvider<SettingsRepository>.value(
            value: settingsRepository,
          ),
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
          RepositoryProvider<AdService>.value(value: adService),
          RepositoryProvider<ObservabilityService>.value(
            value: const NoopObservabilityService(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<GetExpensesBloc>.value(value: expensesBloc),
            BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
            BlocProvider<AppLockCubit>.value(value: appLockCubit),
            BlocProvider<GuidedTourCubit>.value(value: guidedTourCubit),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GuidedTourHost(child: HomeScreen()),
          ),
        ),
      ),
    );
    expenseRepository.emit(expenses);
    await guidedTourCubit.maybeStart();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> dispose() async {
    await expenseRepository.close();
    await authRepository.close();
    await guidedTourCubit.close();
    await monetizationCubit.close();
    await appLockCubit.close();
  }
}
