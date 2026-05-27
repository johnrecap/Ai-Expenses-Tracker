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
  }) {
    switch (runtimeMode) {
      case RepositoryRuntimeMode.firebaseLegacy:
        return _createFirebaseLegacyBundle(userId: userId);
      case RepositoryRuntimeMode.vpsLocalFirst:
        return _createVpsLocalFirstMvpBundle(userId: userId);
      case RepositoryRuntimeMode.migrationComparison:
        return _createMigrationComparisonBundle(userId: userId);
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
  }) {
    final store = LocalRepositoryStore(userId: userId);
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
    );
  }

  AuthenticatedRepositoryBundle _createMigrationComparisonBundle({
    required String userId,
  }) {
    final legacy = _createFirebaseLegacyBundle(userId: userId);
    final migrated = _createVpsLocalFirstMvpBundle(userId: userId);
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
    );
  }
}
