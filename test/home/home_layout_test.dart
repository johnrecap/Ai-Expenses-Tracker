import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/ui_fixture_data.dart';

void main() {
  testWidgets('Home finance and transaction cards fit compact stress data',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _HomeLayoutFixture();
    await fixture.pump(tester);

    expect(find.text('This Month Spending'), findsOneWidget);
    expect(find.textContaining('987,654,321'), findsWidgets);
    await tester.ensureVisible(find.textContaining('وصف عربي طويل'));
    expect(tester.takeException(), isNull);

    await fixture.dispose();
  });
}

class _HomeLayoutFixture {
  _HomeLayoutFixture() {
    authRepository = FakeAuthRepository(UiFixtureData.user);
    expenseRepository = FakeExpenseRepository(UiFixtureData.expenses());
    categoryRepository = FakeCategoryRepository(UiFixtureData.categories());
    settingsRepository = FakeSettingsRepository(UiFixtureData.settings());
    budgetRepository = FakeBudgetRepository(UiFixtureData.budget());
    monetizationCubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.allowed()),
      adService: FakeAdService(),
    );
    appLockCubit = AppLockCubit(appLockService: fakeAppLockService());
  }

  late final FakeAuthRepository authRepository;
  late final FakeExpenseRepository expenseRepository;
  late final FakeCategoryRepository categoryRepository;
  late final FakeSettingsRepository settingsRepository;
  late final FakeBudgetRepository budgetRepository;
  late final MonetizationCubit monetizationCubit;
  late final AppLockCubit appLockCubit;

  Future<void> pump(WidgetTester tester) async {
    await monetizationCubit.load();
    await appLockCubit.initialize();
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
          RepositoryProvider<AdService>.value(value: FakeAdService()),
          RepositoryProvider<ObservabilityService>.value(
            value: const NoopObservabilityService(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
            BlocProvider<AppLockCubit>.value(value: appLockCubit),
            BlocProvider<BudgetBloc>(
              create: (_) => BudgetBloc(budgetRepository)
                ..add(const BudgetWatchRequested(month: 5, year: 2026)),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MainScreen(
              UiFixtureData.expenses(),
              user: UiFixtureData.user,
              settings: UiFixtureData.settings(),
              localDisplayName: UiFixtureData.user.displayName,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    await expenseRepository.close();
    await authRepository.close();
    await monetizationCubit.close();
    await appLockCubit.close();
  }
}
