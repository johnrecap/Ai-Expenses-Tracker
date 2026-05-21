import 'package:expense_repository/expense_repository.dart';

import 'backup_document.dart';

class BackupSerializer {
  const BackupSerializer();

  BackupDocument createBackup({
    required String userId,
    required DateTime createdAt,
    String appVersion = 'unknown',
    List<Expense> expenses = const [],
    List<Category> categories = const [],
    List<Budget> budgets = const [],
    List<CategoryBudget> categoryBudgets = const [],
    List<RecurringExpense> recurringExpenses = const [],
    List<SavingGoal> savingGoals = const [],
    UserSettings? settings,
    List<CategoryAlias> categoryAliases = const [],
    List<WalletAccount> wallets = const [],
    List<Transfer> transfers = const [],
  }) {
    final document = BackupDocument(
      manifest: BackupManifest(
        schemaVersion: currentBackupSchemaVersion,
        appVersion: appVersion,
        createdAt: createdAt,
        sourceUserId: userId,
        collections: BackupCollection.supported,
        counts: const {},
        warnings: _warningsFor(settings),
      ),
      expenses: expenses,
      categories: categories,
      budgets: budgets,
      categoryBudgets: categoryBudgets,
      recurringExpenses: recurringExpenses,
      savingGoals: savingGoals,
      settings: settings,
      categoryAliases: categoryAliases,
      wallets: wallets,
      transfers: transfers,
    );
    document.validateOwnership(userId);

    return BackupDocument(
      manifest: BackupManifest(
        schemaVersion: currentBackupSchemaVersion,
        appVersion: appVersion,
        createdAt: createdAt,
        sourceUserId: userId,
        collections: BackupCollection.supported,
        counts: backupCountsFor(document),
        warnings: _warningsFor(settings),
      ),
      expenses: expenses,
      categories: categories,
      budgets: budgets,
      categoryBudgets: categoryBudgets,
      recurringExpenses: recurringExpenses,
      savingGoals: savingGoals,
      settings: settings,
      categoryAliases: categoryAliases,
      wallets: wallets,
      transfers: transfers,
    );
  }

  List<String> _warningsFor(UserSettings? settings) {
    if (settings == null || settings.conversionRates.isNotEmpty) {
      return const [];
    }
    return const [
      'No saved exchange rates were included; mixed-currency restore previews may show missing-rate warnings.',
    ];
  }
}
