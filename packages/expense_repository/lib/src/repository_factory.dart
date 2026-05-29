import 'package:expense_repository/expense_repository.dart';

class AuthenticatedRepositoryBundle {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final CategoryAliasRepository categoryAliasRepository;
  final CategoryBudgetRepository categoryBudgetRepository;
  final BudgetRepository budgetRepository;
  final SettingsRepository settingsRepository;
  final RecurringExpenseRepository recurringExpenseRepository;
  final SavingGoalRepository savingGoalRepository;
  final AiActionLogRepository aiActionLogRepository;
  final SyncCoordinator? syncCoordinator;
  final Stream<List<SyncChange>>? pendingSyncChanges;
  final String? syncDeviceId;

  const AuthenticatedRepositoryBundle({
    required this.expenseRepository,
    required this.categoryRepository,
    required this.categoryAliasRepository,
    required this.categoryBudgetRepository,
    required this.budgetRepository,
    required this.settingsRepository,
    required this.recurringExpenseRepository,
    required this.savingGoalRepository,
    required this.aiActionLogRepository,
    this.syncCoordinator,
    this.pendingSyncChanges,
    this.syncDeviceId,
  });
}

class AuthenticatedRepositoryFactory {
  final RepositoryRuntimeMode runtimeMode;

  const AuthenticatedRepositoryFactory({
    this.runtimeMode = RepositoryRuntimeMode.firebaseLegacy,
  });

  factory AuthenticatedRepositoryFactory.fromEnvironment() {
    return AuthenticatedRepositoryFactory(
      runtimeMode: RepositoryRuntimeMode.fromEnvironment(),
    );
  }

  AuthenticatedRepositoryBundle create({
    required String userId,
    AuthRepository? authRepository,
  }) {
    switch (runtimeMode) {
      case RepositoryRuntimeMode.firebaseLegacy:
        return _createFirebaseLegacyBundle(userId: userId);
      case RepositoryRuntimeMode.vpsLocalFirst:
        return _createVpsLocalFirstMvpBundle(
          userId: userId,
          authRepository: authRepository,
        );
      case RepositoryRuntimeMode.migrationComparison:
        return _createMigrationComparisonBundle(
          userId: userId,
          authRepository: authRepository,
        );
    }
  }

  AuthenticatedRepositoryBundle _createFirebaseLegacyBundle({
    required String userId,
  }) {
    return AuthenticatedRepositoryBundle(
      expenseRepository: FirebaseExpenseRepo(userId: userId),
      categoryRepository: FirebaseCategoryRepository(userId: userId),
      categoryAliasRepository: FirebaseCategoryAliasRepository(userId: userId),
      categoryBudgetRepository:
          FirebaseCategoryBudgetRepository(userId: userId),
      budgetRepository: FirebaseBudgetRepository(userId: userId),
      settingsRepository: FirebaseSettingsRepository(userId: userId),
      recurringExpenseRepository:
          FirebaseRecurringExpenseRepository(userId: userId),
      savingGoalRepository: FirebaseSavingGoalRepository(userId: userId),
      aiActionLogRepository: FirebaseAiActionLogRepository(userId: userId),
    );
  }

  AuthenticatedRepositoryBundle _createVpsLocalFirstMvpBundle({
    required String userId,
    AuthRepository? authRepository,
  }) {
    final store = LocalRepositoryStore(userId: userId);
    final syncCoordinator = authRepository == null
        ? null
        : SyncCoordinator(
            apiClient: VpsApiClient(
              baseUri: VpsApiConfig.fromEnvironment().requireForMode(
                runtimeMode,
              ),
              tokenProvider: RepositoryFirebaseTokenProvider(
                authRepository: authRepository,
              ).call,
            ),
            queue: LocalSyncQueue(
              pending: store.pendingChanges,
              onUploaded: store.markUploadedChanges,
              onChanged: store.markSyncChangesUpdated,
            ),
          );
    return AuthenticatedRepositoryBundle(
      expenseRepository: LocalExpenseRepository(store: store),
      categoryRepository: LocalCategoryRepository(store: store),
      categoryAliasRepository: LocalCategoryAliasRepository(store: store),
      categoryBudgetRepository: LocalCategoryBudgetRepository(store: store),
      budgetRepository: LocalBudgetRepository(store: store),
      settingsRepository: LocalSettingsRepository(store: store),
      recurringExpenseRepository: LocalRecurringExpenseRepository(store: store),
      savingGoalRepository: LocalSavingGoalRepository(store: store),
      aiActionLogRepository: LocalAiActionLogRepository(store: store),
      syncCoordinator: syncCoordinator,
      pendingSyncChanges: syncCoordinator == null
          ? null
          : store.watchPendingChanges(),
      syncDeviceId: syncCoordinator == null ? null : 'flutter-$userId',
    );
  }

  AuthenticatedRepositoryBundle _createMigrationComparisonBundle({
    required String userId,
    AuthRepository? authRepository,
  }) {
    final legacy = _createFirebaseLegacyBundle(userId: userId);
    final migrated = _createVpsLocalFirstMvpBundle(
      userId: userId,
      authRepository: authRepository,
    );
    return AuthenticatedRepositoryBundle(
      expenseRepository: MigrationComparisonExpenseRepository(
        legacy: legacy.expenseRepository,
        migrated: migrated.expenseRepository,
      ),
      categoryRepository: migrated.categoryRepository,
      categoryAliasRepository: migrated.categoryAliasRepository,
      categoryBudgetRepository: migrated.categoryBudgetRepository,
      budgetRepository: migrated.budgetRepository,
      settingsRepository: migrated.settingsRepository,
      recurringExpenseRepository: migrated.recurringExpenseRepository,
      savingGoalRepository: migrated.savingGoalRepository,
      aiActionLogRepository: migrated.aiActionLogRepository,
      syncCoordinator: migrated.syncCoordinator,
      pendingSyncChanges: migrated.pendingSyncChanges,
      syncDeviceId: migrated.syncDeviceId,
    );
  }
}
