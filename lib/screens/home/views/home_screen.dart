import 'dart:async';
import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/categories/blocs/categories_bloc/categories_bloc.dart';
import 'package:expenses_tracker/screens/categories/views/categories_screen.dart';
import 'package:expenses_tracker/screens/category_budgets/cubit/category_budget_cubit.dart';
import 'package:expenses_tracker/screens/category_budgets/views/category_budgets_screen.dart';
import 'package:expenses_tracker/screens/export/views/export_screen.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/models/expense_draft.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/ai_assistant/views/ai_assistant_sheet.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:expenses_tracker/screens/recurring_expenses/blocs/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/screens/recurring_expenses/views/recurring_expenses_screen.dart';
import 'package:expenses_tracker/screens/saving_goals/blocs/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expenses_tracker/screens/saving_goals/views/saving_goals_screen.dart';
import 'package:expenses_tracker/screens/settings/views/settings_screen.dart';
import 'package:expenses_tracker/screens/subscriptions/views/subscription_center_screen.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_refresh_service.dart';
import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:expenses_tracker/screens/stats/stats.dart';
import 'package:expenses_tracker/widgets/sync_status_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';

enum _HomeOverflowAction {
  categoryBudgets,
  subscriptions,
  recurring,
  savingGoals,
  categories,
  settings,
  export,
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.exchangeRateService = const FrankfurterExchangeRateService(),
    super.key,
  });

  final ExchangeRateService exchangeRateService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectedItem = Colors.blue;
  Color unselectedItem = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
        builder: (context, state) {
      if (state is GetExpensesSuccess) {
        final expenseRepository = context.read<ExpenseRepository>();
        final categoryRepository = context.read<CategoryRepository>();
        final categoryAliasRepository = context.read<CategoryAliasRepository>();
        final categoryBudgetRepository =
            context.read<CategoryBudgetRepository>();
        final budgetRepository = context.read<BudgetRepository>();
        final settingsRepository = context.read<SettingsRepository>();
        final aiActionLogRepository = context.read<AiActionLogRepository>();
        final authRepository = _tryRead<AuthRepository>(context);
        final recurringExpenseRepository =
            context.read<RecurringExpenseRepository>();
        final savingGoalRepository = context.read<SavingGoalRepository>();
        final authState = context.read<AuthBloc>().state;
        final currentUser =
            authState is AuthAuthenticated ? authState.user : AppUser.empty;
        final accountProfileService = _accountProfileService(context);

        Future<void> openAiAssistant() async {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) return;
          final created = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<ExpenseRepository>.value(
                  value: expenseRepository,
                ),
                RepositoryProvider<CategoryRepository>.value(
                  value: categoryRepository,
                ),
                RepositoryProvider<CategoryAliasRepository>.value(
                  value: categoryAliasRepository,
                ),
                RepositoryProvider<SettingsRepository>.value(
                  value: settingsRepository,
                ),
                RepositoryProvider<BudgetRepository>.value(
                  value: budgetRepository,
                ),
                RepositoryProvider<AiActionLogRepository>.value(
                  value: aiActionLogRepository,
                ),
              ],
              child: BlocProvider(
                create: (_) => CreateExpenseBloc(
                  expenseRepository,
                  budgetRepository: budgetRepository,
                  settingsRepository: settingsRepository,
                  notificationScheduler: NotificationScheduler.instance,
                ),
                child: AiAssistantSheet(
                  userId: authState.user.userId,
                  expenses: state.expenses,
                ),
              ),
            ),
          );
          if (!context.mounted) return;
          if (created == true) {
            context.read<GetExpensesBloc>().add(const GetExpenses());
          }
        }

        void openRecurringExpenses() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<CategoryRepository>.value(
                    value: categoryRepository,
                  ),
                  RepositoryProvider<SettingsRepository>.value(
                    value: settingsRepository,
                  ),
                ],
                child: BlocProvider(
                  create: (_) => RecurringExpenseBloc(
                    recurringExpenseRepository,
                  )..add(
                      const RecurringExpensesWatchRequested(),
                    ),
                  child: const RecurringExpensesScreen(),
                ),
              ),
            ),
          );
        }

        void openCategoryBudgets() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<CategoryBudgetRepository>.value(
                    value: categoryBudgetRepository,
                  ),
                  RepositoryProvider<CategoryRepository>.value(
                    value: categoryRepository,
                  ),
                  RepositoryProvider<SettingsRepository>.value(
                    value: settingsRepository,
                  ),
                ],
                child: BlocProvider(
                  create: (_) => CategoryBudgetCubit(
                    categoryBudgetRepository: categoryBudgetRepository,
                    categoryRepository: categoryRepository,
                    settingsRepository: settingsRepository,
                  ),
                  child: CategoryBudgetsScreen(expenses: state.expenses),
                ),
              ),
            ),
          );
        }

        void openSubscriptionCenter() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<RecurringExpenseRepository>.value(
                    value: recurringExpenseRepository,
                  ),
                  RepositoryProvider<CategoryRepository>.value(
                    value: categoryRepository,
                  ),
                  RepositoryProvider<SettingsRepository>.value(
                    value: settingsRepository,
                  ),
                ],
                child: const SubscriptionCenterScreen(),
              ),
            ),
          );
        }

        void openSavingGoals() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<SettingsRepository>.value(
                    value: settingsRepository,
                  ),
                ],
                child: BlocProvider(
                  create: (_) => SavingGoalBloc(savingGoalRepository)
                    ..add(const SavingGoalsWatchRequested()),
                  child: const SavingGoalsScreen(),
                ),
              ),
            ),
          );
        }

        void openCategories() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => CategoriesBloc(categoryRepository)
                  ..add(const CategoriesRequested()),
                child: const CategoriesScreen(),
              ),
            ),
          );
        }

        void openSettings() {
          final guidedTourCubit = _readGuidedTourCubit(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) {
                Widget screen = RepositoryProvider<SettingsRepository>.value(
                  value: settingsRepository,
                  child: SettingsScreen(expenses: state.expenses),
                );
                screen = _withSettingsRouteProviders(context, screen);
                if (guidedTourCubit == null) return screen;
                return BlocProvider<GuidedTourCubit>.value(
                  value: guidedTourCubit,
                  child: screen,
                );
              },
            ),
          );
        }

        void openExport() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => _withMonetizationProviders(
                context,
                ExportScreen(expenses: state.expenses),
              ),
            ),
          );
        }

        Future<void> handleOverflowAction(_HomeOverflowAction action) async {
          switch (action) {
            case _HomeOverflowAction.categoryBudgets:
              openCategoryBudgets();
              break;
            case _HomeOverflowAction.subscriptions:
              openSubscriptionCenter();
              break;
            case _HomeOverflowAction.recurring:
              openRecurringExpenses();
              break;
            case _HomeOverflowAction.savingGoals:
              openSavingGoals();
              break;
            case _HomeOverflowAction.categories:
              openCategories();
              break;
            case _HomeOverflowAction.settings:
              openSettings();
              break;
            case _HomeOverflowAction.export:
              openExport();
              break;
            case _HomeOverflowAction.logout:
              final confirmed = await _confirmLogout(context);
              if (!context.mounted || !confirmed) return;
              context.read<AuthBloc>().add(AuthSignOutRequested());
              break;
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.grey[100],
            elevation: 0,
            actions: [
              IconButton(
                onPressed: openAiAssistant,
                icon: SpotlightTarget(
                  targetId: GuidedTourTargetIds.aiAssistant,
                  shape: SpotlightShape.circle,
                  child: Icon(
                    Icons.auto_awesome,
                    semanticLabel: context.l10n.aiAssistant,
                  ),
                ),
                tooltip: context.l10n.aiAssistant,
              ),
              SpotlightTarget(
                targetId: GuidedTourTargetIds.categories,
                shape: SpotlightShape.circle,
                child: PopupMenuButton<_HomeOverflowAction>(
                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                  icon: Icon(
                    Icons.more_vert,
                    semanticLabel:
                        MaterialLocalizations.of(context).moreButtonTooltip,
                  ),
                  onSelected: handleOverflowAction,
                  itemBuilder: (context) => [
                    _homeMenuItem(
                      value: _HomeOverflowAction.categoryBudgets,
                      icon: Icons.pie_chart_outline,
                      label: context.l10n.categoryBudgets,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.subscriptions,
                      icon: Icons.subscriptions_outlined,
                      label: context.l10n.subscriptionCenter,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.recurring,
                      icon: Icons.repeat,
                      label: context.l10n.recurringExpenses,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.savingGoals,
                      icon: Icons.savings_outlined,
                      label: context.l10n.savingGoals,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.categories,
                      icon: Icons.category_outlined,
                      label: context.l10n.categories,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.settings,
                      icon: Icons.settings,
                      label: context.l10n.settings,
                    ),
                    _homeMenuItem(
                      value: _HomeOverflowAction.export,
                      icon: Icons.file_download_outlined,
                      label: context.l10n.exportData,
                    ),
                    const PopupMenuDivider(),
                    _homeMenuItem(
                      value: _HomeOverflowAction.logout,
                      icon: Icons.logout,
                      label: context.l10n.logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // bottomNavBar
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            child: BottomNavigationBar(
                onTap: (value) {
                  setState(() {
                    index = value;
                  });
                  // print(value);
                },
                // backgroundColor: Colors.white,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 3,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.home,
                      color: index == 0 ? selectedItem : unselectedItem,
                    ),
                    label: context.l10n.home,
                  ),
                  BottomNavigationBarItem(
                    icon: SpotlightTarget(
                      targetId: GuidedTourTargetIds.reports,
                      child: Icon(
                        CupertinoIcons.graph_square_fill,
                        color: index == 1 ? selectedItem : unselectedItem,
                      ),
                    ),
                    label: context.l10n.stats,
                  ),
                ]),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SpotlightTarget(
            targetId: GuidedTourTargetIds.manualExpense,
            shape: SpotlightShape.circle,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              tooltip: context.l10n.addExpense,
              onPressed: () async {
                var newExpense = await Navigator.push(
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
                          RepositoryProvider<AuthRepository>.value(
                            value: authRepository,
                          ),
                        RepositoryProvider<CategoryAliasRepository>.value(
                          value: categoryAliasRepository,
                        ),
                        RepositoryProvider<AiActionLogRepository>.value(
                          value: aiActionLogRepository,
                        ),
                      ],
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) =>
                                CreateCategoryBloc(categoryRepository),
                          ),
                          BlocProvider(
                            create: (context) => CreateExpenseBloc(
                              expenseRepository,
                              budgetRepository: budgetRepository,
                              settingsRepository: settingsRepository,
                              notificationScheduler:
                                  NotificationScheduler.instance,
                            ),
                          ),
                          BlocProvider(
                            create: (context) =>
                                GetCategoriesBloc(categoryRepository)
                                  ..add(GetCategories()),
                          ),
                        ],
                        child: const AddExpense(
                          initialCaptureMode: CaptureMode.naturalLanguage,
                        ),
                      ),
                    ),
                  ),
                );
                if (!context.mounted) return;
                if (newExpense != null) {
                  context.read<GetExpensesBloc>().add(const GetExpenses());
                  unawaited(_recordCompletedSaveForAds(context));
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.add,
                  semanticLabel: context.l10n.addExpense,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              SyncStatusBanner(expenses: state.expenses),
              Expanded(
                child: index == 0
                    ? StreamBuilder<String?>(
                        stream: accountProfileService.watchLocalDisplayName(
                          currentUser,
                        ),
                        builder: (context, profileSnapshot) {
                          return StreamBuilder<UserSettings>(
                            stream: settingsRepository.watchSettings(),
                            initialData: UserSettings.defaults(
                              userId: currentUser.userId,
                            ),
                            builder: (context, settingsSnapshot) {
                              final homeSettings = settingsSnapshot.data ??
                                  UserSettings.defaults(
                                    userId: currentUser.userId,
                                  );
                              return FutureBuilder<UserSettings>(
                                future: ExchangeRateRefreshService(
                                  settingsRepository: settingsRepository,
                                  exchangeRateService:
                                      widget.exchangeRateService,
                                ).refreshIfNeeded(homeSettings),
                                builder: (context, refreshSnapshot) {
                                  final effectiveSettings =
                                      refreshSnapshot.data ?? homeSettings;
                                  if (effectiveSettings.onboardingCompleted) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                      (_) {
                                        if (!context.mounted) return;
                                        _readGuidedTourCubit(context)
                                            ?.maybeStart();
                                      },
                                    );
                                  }
                                  return BlocProvider(
                                    create: (_) => BudgetBloc(budgetRepository)
                                      ..add(
                                        BudgetWatchRequested(
                                          month: DateTime.now().month,
                                          year: DateTime.now().year,
                                        ),
                                      ),
                                    child: MainScreen(
                                      state.expenses,
                                      user: currentUser,
                                      settings: effectiveSettings,
                                      localDisplayName: profileSnapshot.data,
                                      nextCursor: state.nextCursor,
                                      hasMoreExpenses: state.hasMore,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      )
                    : StreamBuilder<UserSettings>(
                        stream: settingsRepository.watchSettings(),
                        initialData: UserSettings.defaults(
                          userId: currentUser.userId,
                        ),
                        builder: (context, settingsSnapshot) {
                          return StatScreen(
                            expenses: state.expenses,
                            settings: settingsSnapshot.data ??
                                UserSettings.defaults(
                                  userId: currentUser.userId,
                                ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      } else if (state is GetExpensesFailure) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.failedToLoadExpenses,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.checkConnectionTryAgain,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.read<GetExpensesBloc>().add(const GetExpenses());
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }

  Future<void> _recordCompletedSaveForAds(BuildContext context) async {
    try {
      await context
          .read<MonetizationCubit>()
          .recordCompletedSaveAndMaybeShowInterstitial(
            routeName: '/home/post_save',
          );
    } catch (_) {
      // Monetization must not affect expense persistence or home refresh.
    }
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

  PopupMenuItem<_HomeOverflowAction> _homeMenuItem({
    required _HomeOverflowAction value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<_HomeOverflowAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, semanticLabel: label),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
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

  AccountProfileService _accountProfileService(BuildContext context) {
    return _tryRead<AccountProfileService>(context) ??
        DefaultAccountProfileService.instance;
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirmLogoutTitle),
        content: Text(context.l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
