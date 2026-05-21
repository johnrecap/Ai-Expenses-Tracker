import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/engagement/widgets/engagement_summary_panel.dart';
import 'package:expenses_tracker/engagement/widgets/retention_prompt_panel.dart';
import 'package:expenses_tracker/engagement/widgets/weekly_digest_screen.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/models/expense_draft.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/budget/views/budget_screen.dart';
import 'package:expenses_tracker/screens/budget/widgets/budget_progress_card.dart';
import 'package:expenses_tracker/screens/expenses/views/expenses_screen.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/models/home_summary.dart';
import 'package:expenses_tracker/screens/home/services/home_summary_calculator.dart';
import 'package:expenses_tracker/screens/settings/views/settings_screen.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:expenses_tracker/widgets/sync_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatelessWidget {
  final List<Expense> expenses;
  final AppUser user;
  final UserSettings settings;
  final String? localDisplayName;
  final ExpensePageCursor? nextCursor;
  final bool hasMoreExpenses;

  const MainScreen(
    this.expenses, {
    required this.user,
    required this.settings,
    this.localDisplayName,
    this.nextCursor,
    this.hasMoreExpenses = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        final budget = budgetState is BudgetLoaded ? budgetState.budget : null;
        final now = DateTime.now();
        final summary = const HomeSummaryCalculator().calculate(
          expenses: expenses,
          settings: settings,
          user: user,
          localDisplayName: localDisplayName,
          budget: budget,
          now: now,
        );
        final spendingLabel = formatAmountWithCurrency(
          summary.spendingTotal,
          summary.currency,
        );
        final budgetProgress = BudgetCalculator.calculate(
          budget: budget,
          expenses: expenses,
          settings: settings,
        );
        final streak = const TrackingStreakCalculator().calculate(
          expenses: expenses,
          now: now,
        );
        final digest = const WeeklyDigestCalculator().calculate(
          expenses: expenses,
          settings: settings,
          now: now,
        );
        final healthScore = const SpendingHealthScoreService().calculate(
          expenses: expenses,
          budgetProgress: budgetProgress,
          streak: streak,
          currency: budget?.currency ?? settings.baseCurrency,
          now: now,
        );
        final retentionPrompts = const RetentionPromptService().buildPrompts(
          expenses: expenses,
          budgetProgress: budgetProgress,
          streak: streak,
          digest: digest,
        );
        return _buildContent(
          context,
          summary: summary,
          budget: budget,
          budgetState: budgetState,
          budgetProgress: budgetProgress,
          streak: streak,
          digest: digest,
          healthScore: healthScore,
          retentionPrompts: retentionPrompts,
          spendingLabel: spendingLabel,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required HomeSummary summary,
    required Budget? budget,
    required BudgetState budgetState,
    required BudgetProgress budgetProgress,
    required TrackingStreak streak,
    required WeeklyDigest digest,
    required SpendingHealthScore healthScore,
    required List<RetentionPrompt> retentionPrompts,
    required String spendingLabel,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // welcome bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow[700],
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.person_alt,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.welcome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Text(
                                summary.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpotlightTarget(
                    targetId: GuidedTourTargetIds.settings,
                    shape: SpotlightShape.circle,
                    child: IconButton(
                      onPressed: () {
                        final guidedTourCubit = _readGuidedTourCubit(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) {
                              Widget screen =
                                  RepositoryProvider<SettingsRepository>.value(
                                value: context.read<SettingsRepository>(),
                                child: SettingsScreen(expenses: expenses),
                              );
                              screen =
                                  _withSettingsRouteProviders(context, screen);
                              if (guidedTourCubit == null) return screen;
                              return BlocProvider<GuidedTourCubit>.value(
                                value: guidedTourCubit,
                                child: screen,
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        CupertinoIcons.settings,
                        semanticLabel: context.l10n.settings,
                      ),
                      tooltip: context.l10n.settings,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              // card
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width / 2,
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      transform: const GradientRotation(pi / 4),
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.grey.shade300,
                        offset: const Offset(5, 5),
                      )
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.thisMonthSpending,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      spendingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (summary.hasMixedCurrencies) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _currencyStatusLabel(context, summary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.creditcard,
                                      size: 12,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        summary.hasBudget
                                            ? context.l10n.budgetLeft
                                            : context.l10n.budget,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        summary.hasBudget
                                            ? formatAmountWithCurrency(
                                                summary.budgetRemaining ?? 0,
                                                summary.currency,
                                              )
                                            : context.l10n.setMonthlyBudget,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          //expense row
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.arrow_down,
                                      size: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.topCategory,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        summary.topCategoryName ??
                                            context.l10n.noSpendingYet,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // Transactions row
              const SizedBox(height: 20),
              const MonetizationBannerAdSlot(
                placementKey: AdPlacementKey.homeBanner,
              ),
              const SizedBox(height: 20),
              _buildBudgetSection(context, budgetState, budget, budgetProgress),
              EngagementSummaryPanel(
                streak: streak,
                digest: digest,
                healthScore: healthScore,
              ),
              RetentionPromptPanel(
                prompts: retentionPrompts,
                onAction: (prompt) => _handleRetentionPrompt(
                  context,
                  prompt,
                  budget: budget,
                  digest: digest,
                  healthScore: healthScore,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.transactions,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _withMonetizationProviders(
                            context,
                            ExpensesScreen(
                              expenses: expenses,
                              initialCursor: nextCursor,
                              initialHasMore: hasMoreExpenses,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      context.l10n.viewAll,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              expenses.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          context.l10n.noExpensesYet,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, int i) {
                        final expense = expenses[i];
                        final categoryName = expense.categoryName.isNotEmpty
                            ? expense.categoryName
                            : expense.category.name;
                        final categoryIcon = expense.categoryIcon.isNotEmpty
                            ? expense.categoryIcon
                            : expense.category.icon;
                        final categoryColor = expense.categoryColor != 0
                            ? expense.categoryColor
                            : expense.category.color;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CategoryIconView(
                                          iconKey: categoryIcon,
                                          backgroundColor: Color(categoryColor),
                                          size: 50,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoryName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (expense.description.isNotEmpty)
                                                Text(
                                                  expense.description,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              const SizedBox(height: 6),
                                              ExpenseSyncBadge(
                                                expense: expense,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 112),
                                        child: Text(
                                          formatAmountWithCurrency(
                                            expense.amount,
                                            expense.currency,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                          Localizations.localeOf(context)
                                              .toLanguageTag(),
                                        ).format(expense.date),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _withMonetizationProviders(BuildContext context, Widget child) {
    try {
      final cubit = context.read<MonetizationCubit>();
      final adService = context.read<AdService>();
      return RepositoryProvider<AdService>.value(
        value: adService,
        child: BlocProvider<MonetizationCubit>.value(
          value: cubit,
          child: child,
        ),
      );
    } catch (_) {
      return child;
    }
  }

  Widget _withSettingsRouteProviders(BuildContext context, Widget child) {
    var wrapped = _withMonetizationProviders(context, child);

    final appLockCubit = _tryRead<AppLockCubit>(context);
    if (appLockCubit != null) {
      wrapped = BlocProvider<AppLockCubit>.value(
        value: appLockCubit,
        child: wrapped,
      );
    }

    final authBloc = _tryRead<AuthBloc>(context);
    if (authBloc != null) {
      wrapped = BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: wrapped,
      );
    }

    final accountProfileService = _tryRead<AccountProfileService>(context);
    if (accountProfileService != null) {
      wrapped = RepositoryProvider<AccountProfileService>.value(
        value: accountProfileService,
        child: wrapped,
      );
    }

    final observability = _tryRead<ObservabilityService>(context);
    if (observability != null) {
      wrapped = RepositoryProvider<ObservabilityService>.value(
        value: observability,
        child: wrapped,
      );
    }

    return wrapped;
  }

  String _currencyStatusLabel(BuildContext context, HomeSummary summary) {
    if (summary.hasUnconvertedCurrencies) {
      return context.l10n.unconvertedCurrenciesStatus(
        summary.ignoredCurrencyCount,
        summary.unconvertedCurrencies.join(', '),
      );
    }
    return context.l10n.convertedCurrenciesStatus(
      summary.convertedCurrencies.join(', '),
    );
  }

  Widget _buildBudgetSection(
    BuildContext context,
    BudgetState state,
    Budget? budget,
    BudgetProgress progress,
  ) {
    try {
      context.read<BudgetBloc>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    if (state is BudgetLoading || state is BudgetInitial) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: LinearProgressIndicator(),
      );
    }

    return SpotlightTarget(
      targetId: GuidedTourTargetIds.budget,
      child: BudgetProgressCard(
        progress: progress,
        onManage: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<BudgetBloc>(),
                child: BudgetScreen(
                  initialBudget: budget,
                  expenses: expenses,
                  settings: settings,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddExpense(BuildContext context) async {
    final categoryRepository = context.read<CategoryRepository>();
    final expenseRepository = context.read<ExpenseRepository>();
    final budgetRepository = context.read<BudgetRepository>();
    final settingsRepository = context.read<SettingsRepository>();
    final authRepository = _tryRead<AuthRepository>(context);
    final categoryAliasRepository = _tryRead<CategoryAliasRepository>(context);
    final aiActionLogRepository = _tryRead<AiActionLogRepository>(context);

    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute<Expense>(
        builder: (context) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ExpenseRepository>.value(
              value: expenseRepository,
            ),
            RepositoryProvider<CategoryRepository>.value(
              value: categoryRepository,
            ),
            RepositoryProvider<SettingsRepository>.value(
              value: settingsRepository,
            ),
            RepositoryProvider<BudgetRepository>.value(
              value: budgetRepository,
            ),
            if (authRepository != null)
              RepositoryProvider<AuthRepository>.value(value: authRepository),
            if (categoryAliasRepository != null)
              RepositoryProvider<CategoryAliasRepository>.value(
                value: categoryAliasRepository,
              ),
            if (aiActionLogRepository != null)
              RepositoryProvider<AiActionLogRepository>.value(
                value: aiActionLogRepository,
              ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CreateCategoryBloc(categoryRepository),
              ),
              BlocProvider(
                create: (context) => CreateExpenseBloc(
                  expenseRepository,
                  budgetRepository: budgetRepository,
                  settingsRepository: settingsRepository,
                  notificationScheduler: NotificationScheduler.instance,
                ),
              ),
              BlocProvider(
                create: (context) =>
                    GetCategoriesBloc(categoryRepository)..add(GetCategories()),
              ),
            ],
            child: AddExpense(
              recentExpenses: expenses,
              initialCaptureMode: CaptureMode.naturalLanguage,
            ),
          ),
        ),
      ),
    );
    if (!context.mounted || newExpense == null) return;
    context.read<GetExpensesBloc>().add(const GetExpenses());
  }

  void _openBudget(BuildContext context, Budget? budget) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<BudgetBloc>(),
          child: BudgetScreen(
            initialBudget: budget,
            expenses: expenses,
            settings: settings,
          ),
        ),
      ),
    );
  }

  void _handleRetentionPrompt(
    BuildContext context,
    RetentionPrompt prompt, {
    required Budget? budget,
    required WeeklyDigest digest,
    required SpendingHealthScore healthScore,
  }) {
    switch (prompt.kind) {
      case RetentionPromptKind.onboarding:
      case RetentionPromptKind.streak:
        _openAddExpense(context);
        break;
      case RetentionPromptKind.weeklySummary:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => WeeklyDigestScreen(
              digest: digest,
              healthScore: healthScore,
            ),
          ),
        );
        break;
      case RetentionPromptKind.budgetNudge:
      case RetentionPromptKind.spendingChallenge:
        _openBudget(context, budget);
        break;
    }
  }

  GuidedTourCubit? _readGuidedTourCubit(BuildContext context) {
    try {
      return context.read<GuidedTourCubit>();
    } catch (_) {
      return null;
    }
  }

  T? _tryRead<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }
}
