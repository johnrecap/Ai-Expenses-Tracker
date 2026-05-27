import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/app_lock/views/create_pin_screen.dart';
import 'package:expenses_tracker/screens/app_lock/views/unlock_screen.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:expenses_tracker/services/recurring_expense_scheduler.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/screens/auth/views/login_screen.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:expenses_tracker/screens/onboarding/onboarding.dart';
import 'package:expenses_tracker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final authRepository = context.read<AuthRepository>();
          final repositories = AuthenticatedRepositoryFactory.fromEnvironment()
              .create(
            userId: state.user.userId,
            authRepository: authRepository,
          );
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<ExpenseRepository>(
                create: (_) => repositories.expenseRepository,
              ),
              RepositoryProvider<CategoryRepository>(
                create: (_) => repositories.categoryRepository,
              ),
              RepositoryProvider<CategoryAliasRepository>(
                create: (_) => repositories.categoryAliasRepository,
              ),
              RepositoryProvider<CategoryBudgetRepository>(
                create: (_) => repositories.categoryBudgetRepository,
              ),
              RepositoryProvider<BudgetRepository>(
                create: (_) => repositories.budgetRepository,
              ),
              RepositoryProvider<SettingsRepository>(
                create: (_) => repositories.settingsRepository,
              ),
              RepositoryProvider<RecurringExpenseRepository>(
                create: (_) => repositories.recurringExpenseRepository,
              ),
              RepositoryProvider<SavingGoalRepository>(
                create: (_) => repositories.savingGoalRepository,
              ),
              RepositoryProvider<AiActionLogRepository>(
                create: (_) => repositories.aiActionLogRepository,
              ),
            ],
            child: Builder(
              builder: (context) {
                final expenseRepository = context.read<ExpenseRepository>();
                final settingsRepository = context.read<SettingsRepository>();
                final recurringExpenseRepository =
                    context.read<RecurringExpenseRepository>();
                final adService = GoogleMobileAdsService();
                final accountProfileService =
                    RepositoryBackedAccountProfileService(
                  settingsRepository: settingsRepository,
                  authRepository: authRepository,
                );
                return MultiRepositoryProvider(
                  providers: [
                    RepositoryProvider<AdService>.value(value: adService),
                    RepositoryProvider<AccountProfileService>.value(
                      value: accountProfileService,
                    ),
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => GetExpensesBloc(expenseRepository)
                          ..add(const GetExpenses()),
                      ),
                      BlocProvider(
                        create: (_) => MonetizationCubit(
                          entitlementRepository: LocalEntitlementRepository(),
                          policyRepository:
                              const LocalMonetizationPolicyRepository(),
                          consentService: const GoogleMobileAdsConsentService(),
                          adService: adService,
                        )..load(),
                      ),
                      BlocProvider(
                        create: (_) => AppLockCubit()..initialize(),
                      ),
                    ],
                    child: _VpsSyncBridge(
                      syncCoordinator: repositories.syncCoordinator,
                      pendingSyncChanges: repositories.pendingSyncChanges,
                      deviceId: repositories.syncDeviceId,
                      child: _SettingsLanguageBridge(
                        settingsRepository: settingsRepository,
                        child: _AppLockGate(
                          child: FirstRunOnboardingGate(
                            settingsRepository: settingsRepository,
                            expenseRepository: expenseRepository,
                            authenticatedBuilder: (context, settings) {
                              return _AuthenticatedHome(
                                expenseRepository: expenseRepository,
                                settingsRepository: settingsRepository,
                                recurringExpenseRepository:
                                    recurringExpenseRepository,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (state is AuthInitial || state is AuthLoading) {
          _resetLanguagePreference(context);
          return const SplashScreen();
        }

        if (state is AuthFailure) {
          _resetLanguagePreference(context);
          return LoginScreen(initialMessage: state.message);
        }

        _resetLanguagePreference(context);
        return const LoginScreen();
      },
    );
  }

  void _resetLanguagePreference(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      try {
        context.read<AppLanguageCubit>().reset();
      } catch (_) {}
    });
  }
}

class _VpsSyncBridge extends StatefulWidget {
  final SyncCoordinator? syncCoordinator;
  final Stream<List<SyncChange>>? pendingSyncChanges;
  final String? deviceId;
  final Widget child;

  const _VpsSyncBridge({
    required this.syncCoordinator,
    required this.pendingSyncChanges,
    required this.deviceId,
    required this.child,
  });

  @override
  State<_VpsSyncBridge> createState() => _VpsSyncBridgeState();
}

class _VpsSyncBridgeState extends State<_VpsSyncBridge>
    with WidgetsBindingObserver {
  StreamSubscription<List<SyncChange>>? _pendingSubscription;
  var _syncing = false;
  var _syncRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscribe();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestSync());
  }

  @override
  void didUpdateWidget(covariant _VpsSyncBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingSyncChanges != widget.pendingSyncChanges) {
      _pendingSubscription?.cancel();
      _subscribe();
    }
    if (oldWidget.syncCoordinator != widget.syncCoordinator ||
        oldWidget.deviceId != widget.deviceId) {
      _requestSync();
    }
  }

  void _subscribe() {
    _pendingSubscription = widget.pendingSyncChanges?.listen(
      (changes) {
        if (changes.isNotEmpty) {
          _requestSync();
        }
      },
      onError: (_) {},
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestSync();
    }
  }

  void _requestSync() {
    if (!mounted) return;
    final coordinator = widget.syncCoordinator;
    final deviceId = widget.deviceId;
    if (coordinator == null || deviceId == null) return;
    if (_syncing) {
      _syncRequested = true;
      return;
    }
    unawaited(_sync(coordinator, deviceId));
  }

  Future<void> _sync(SyncCoordinator coordinator, String deviceId) async {
    _syncing = true;
    try {
      do {
        _syncRequested = false;
        await coordinator.syncNow(deviceId: deviceId);
      } while (_syncRequested && mounted);
    } catch (_) {
      // Sync failures are reflected by pending local changes and must not block
      // auth, onboarding, app lock, or the home screen.
    } finally {
      _syncing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SettingsLanguageBridge extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final Widget child;

  const _SettingsLanguageBridge({
    required this.settingsRepository,
    required this.child,
  });

  @override
  State<_SettingsLanguageBridge> createState() =>
      _SettingsLanguageBridgeState();
}

class _SettingsLanguageBridgeState extends State<_SettingsLanguageBridge> {
  StreamSubscription<UserSettings>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _SettingsLanguageBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsRepository != widget.settingsRepository) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.settingsRepository.watchSettings().listen(
      (settings) {
        if (!mounted) return;
        context
            .read<AppLanguageCubit>()
            .setPreference(settings.languagePreference);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AppLockGate extends StatefulWidget {
  final Widget child;

  const _AppLockGate({required this.child});

  @override
  State<_AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<_AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppLockCubit>().checkOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        if (state.status == AppLockStatus.loading ||
            state.status == AppLockStatus.initial) {
          return const SplashScreen();
        }

        if (state.status == AppLockStatus.setupRequired) {
          return const CreatePinScreen(popOnSave: false);
        }

        if (state.status == AppLockStatus.locked ||
            state.status == AppLockStatus.unlocking) {
          return const UnlockScreen();
        }

        return widget.child;
      },
    );
  }
}

class _AuthenticatedHome extends StatefulWidget {
  final ExpenseRepository expenseRepository;
  final SettingsRepository settingsRepository;
  final RecurringExpenseRepository recurringExpenseRepository;

  const _AuthenticatedHome({
    required this.expenseRepository,
    required this.settingsRepository,
    required this.recurringExpenseRepository,
  });

  @override
  State<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<_AuthenticatedHome> {
  bool _processedDueRules = false;

  @override
  void initState() {
    super.initState();
    _processDueRecurringExpenses();
    _syncEngagementReminders();
  }

  Future<void> _processDueRecurringExpenses() async {
    if (_processedDueRules) return;
    _processedDueRules = true;

    try {
      final generatedCount = await RecurringExpenseScheduler(
        expenseRepository: widget.expenseRepository,
        recurringExpenseRepository: widget.recurringExpenseRepository,
      ).processDueRecurringExpenses();
      if (!mounted || generatedCount == 0) return;
      context.read<GetExpensesBloc>().add(const GetExpenses());
    } catch (_) {
      // Recurring generation must not block the authenticated home screen.
    }
  }

  Future<void> _syncEngagementReminders() async {
    try {
      final settings = await widget.settingsRepository.getSettings();
      final expenses = await widget.expenseRepository.getExpenses();
      await NotificationScheduler.instance.syncDailyReminder(
        settings: settings,
        expenses: expenses,
      );
      await NotificationScheduler.instance.syncWeeklyDigest(
        settings: settings,
      );
    } catch (_) {
      // Notification scheduling must not block the authenticated home screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuidedTourCubit(
        settingsRepository: widget.settingsRepository,
      )..maybeStart(),
      child: const GuidedTourHost(
        child: HomeScreen(),
      ),
    );
  }
}
