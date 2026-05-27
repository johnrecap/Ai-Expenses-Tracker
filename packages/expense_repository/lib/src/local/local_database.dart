import 'tables/synced_tables.dart';

class LocalDatabaseSchema {
  static const schemaVersion = 1;

  const LocalDatabaseSchema._();

  static const syncedEntityTables = <Type>[
    LocalUserSettings,
    LocalCategories,
    LocalCategoryAliases,
    LocalExpenses,
    LocalBudgets,
    LocalCategoryBudgets,
    LocalRecurringExpenses,
    LocalSavingGoals,
    LocalWalletAccounts,
    LocalTransfers,
    LocalAiActionLogs,
    LocalSyncChanges,
  ];
}
