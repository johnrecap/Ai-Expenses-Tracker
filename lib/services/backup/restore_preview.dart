import 'package:expense_repository/expense_repository.dart';

import 'backup_document.dart';

enum ImportConflictReason {
  duplicateId,
  existingNewer,
  missingCategory,
}

enum ImportConflictResolution {
  add,
  skip,
  update,
}

class ImportConflict {
  const ImportConflict({
    required this.collection,
    required this.itemId,
    required this.reason,
    this.existingUpdatedAt,
    this.incomingUpdatedAt,
  });

  final String collection;
  final String itemId;
  final ImportConflictReason reason;
  final DateTime? existingUpdatedAt;
  final DateTime? incomingUpdatedAt;
}

class RestorePreview {
  const RestorePreview({
    required this.addCounts,
    required this.updateCounts,
    required this.skipCounts,
    required this.conflicts,
    required this.warnings,
  });

  final Map<String, int> addCounts;
  final Map<String, int> updateCounts;
  final Map<String, int> skipCounts;
  final List<ImportConflict> conflicts;
  final List<String> warnings;

  int get totalAdds => addCounts.values.fold(0, (sum, count) => sum + count);
  int get totalUpdates =>
      updateCounts.values.fold(0, (sum, count) => sum + count);
  int get totalSkips => skipCounts.values.fold(0, (sum, count) => sum + count);
  int get totalConflicts => conflicts.length;
  bool get hasConflicts => conflicts.isNotEmpty;
}

class RestorePreviewBuilder {
  const RestorePreviewBuilder();

  RestorePreview preview({
    required BackupDocument incoming,
    String? targetUserId,
    List<Expense> existingExpenses = const [],
    List<Category> existingCategories = const [],
    List<Budget> existingBudgets = const [],
    List<CategoryBudget> existingCategoryBudgets = const [],
    List<RecurringExpense> existingRecurringExpenses = const [],
    List<SavingGoal> existingSavingGoals = const [],
    UserSettings? existingSettings,
    List<CategoryAlias> existingCategoryAliases = const [],
    List<WalletAccount> existingWallets = const [],
    List<Transfer> existingTransfers = const [],
  }) {
    if (targetUserId != null) incoming.validateTargetUser(targetUserId);

    final adds = _emptyCounts();
    final updates = _emptyCounts();
    final skips = _emptyCounts();
    final conflicts = <ImportConflict>[];
    final warnings = [...incoming.manifest.warnings];

    _classifyCollection(
      collection: BackupCollection.expenses,
      incoming: incoming.expenses.map(
        (item) => _PreviewItem(item.expenseId, item.updatedAt),
      ),
      existing: existingExpenses.map(
        (item) => _PreviewItem(item.expenseId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.categories,
      incoming: incoming.categories.map(
        (item) => _PreviewItem(item.categoryId, item.updatedAt),
      ),
      existing: existingCategories.map(
        (item) => _PreviewItem(item.categoryId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.budgets,
      incoming: incoming.budgets.map(
        (item) => _PreviewItem(item.budgetId, item.updatedAt),
      ),
      existing: existingBudgets.map(
        (item) => _PreviewItem(item.budgetId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.categoryBudgets,
      incoming: incoming.categoryBudgets.map(
        (item) => _PreviewItem(item.categoryBudgetId, item.updatedAt),
      ),
      existing: existingCategoryBudgets.map(
        (item) => _PreviewItem(item.categoryBudgetId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.recurringExpenses,
      incoming: incoming.recurringExpenses.map(
        (item) => _PreviewItem(item.recurringExpenseId, item.updatedAt),
      ),
      existing: existingRecurringExpenses.map(
        (item) => _PreviewItem(item.recurringExpenseId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.savingGoals,
      incoming: incoming.savingGoals.map(
        (item) => _PreviewItem(item.goalId, item.updatedAt),
      ),
      existing: existingSavingGoals.map(
        (item) => _PreviewItem(item.goalId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.categoryAliases,
      incoming: incoming.categoryAliases.map(
        (item) => _PreviewItem(item.aliasId, item.updatedAt),
      ),
      existing: existingCategoryAliases.map(
        (item) => _PreviewItem(item.aliasId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.wallets,
      incoming: incoming.wallets.map(
        (item) => _PreviewItem(item.walletId, item.updatedAt),
      ),
      existing: existingWallets.map(
        (item) => _PreviewItem(item.walletId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _classifyCollection(
      collection: BackupCollection.transfers,
      incoming: incoming.transfers.map(
        (item) => _PreviewItem(item.transferId, item.updatedAt),
      ),
      existing: existingTransfers.map(
        (item) => _PreviewItem(item.transferId, item.updatedAt),
      ),
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );

    _classifySettings(
      incoming: incoming.settings,
      existing: existingSettings,
      adds: adds,
      updates: updates,
      skips: skips,
      conflicts: conflicts,
    );
    _detectMissingExpenseCategories(incoming, existingCategories, conflicts);

    return RestorePreview(
      addCounts: Map.unmodifiable(adds),
      updateCounts: Map.unmodifiable(updates),
      skipCounts: Map.unmodifiable(skips),
      conflicts: List.unmodifiable(conflicts),
      warnings: List.unmodifiable(warnings),
    );
  }

  Map<String, int> _emptyCounts() {
    return {
      for (final collection in BackupCollection.supported) collection: 0,
    };
  }

  void _classifyCollection({
    required String collection,
    required Iterable<_PreviewItem> incoming,
    required Iterable<_PreviewItem> existing,
    required Map<String, int> adds,
    required Map<String, int> updates,
    required Map<String, int> skips,
    required List<ImportConflict> conflicts,
  }) {
    final existingById = {
      for (final item in existing)
        if (item.id.isNotEmpty) item.id: item,
    };
    final seenIncomingIds = <String>{};
    for (final item in incoming) {
      if (item.id.isEmpty || !seenIncomingIds.add(item.id)) {
        skips[collection] = skips[collection]! + 1;
        conflicts.add(
          ImportConflict(
            collection: collection,
            itemId: item.id,
            reason: ImportConflictReason.duplicateId,
            incomingUpdatedAt: item.updatedAt,
          ),
        );
        continue;
      }

      final existingItem = existingById[item.id];
      if (existingItem == null) {
        adds[collection] = adds[collection]! + 1;
      } else if (item.updatedAt.isAfter(existingItem.updatedAt)) {
        updates[collection] = updates[collection]! + 1;
        conflicts.add(
          ImportConflict(
            collection: collection,
            itemId: item.id,
            reason: ImportConflictReason.duplicateId,
            existingUpdatedAt: existingItem.updatedAt,
            incomingUpdatedAt: item.updatedAt,
          ),
        );
      } else {
        skips[collection] = skips[collection]! + 1;
        conflicts.add(
          ImportConflict(
            collection: collection,
            itemId: item.id,
            reason: ImportConflictReason.existingNewer,
            existingUpdatedAt: existingItem.updatedAt,
            incomingUpdatedAt: item.updatedAt,
          ),
        );
      }
    }
  }

  void _classifySettings({
    required UserSettings? incoming,
    required UserSettings? existing,
    required Map<String, int> adds,
    required Map<String, int> updates,
    required Map<String, int> skips,
    required List<ImportConflict> conflicts,
  }) {
    if (incoming == null) return;
    if (existing == null) {
      adds[BackupCollection.settings] = 1;
    } else if (incoming.updatedAt.isAfter(existing.updatedAt)) {
      updates[BackupCollection.settings] = 1;
      conflicts.add(
        ImportConflict(
          collection: BackupCollection.settings,
          itemId: incoming.userId,
          reason: ImportConflictReason.duplicateId,
          existingUpdatedAt: existing.updatedAt,
          incomingUpdatedAt: incoming.updatedAt,
        ),
      );
    } else {
      skips[BackupCollection.settings] = 1;
      conflicts.add(
        ImportConflict(
          collection: BackupCollection.settings,
          itemId: incoming.userId,
          reason: ImportConflictReason.existingNewer,
          existingUpdatedAt: existing.updatedAt,
          incomingUpdatedAt: incoming.updatedAt,
        ),
      );
    }
  }

  void _detectMissingExpenseCategories(
    BackupDocument incoming,
    List<Category> existingCategories,
    List<ImportConflict> conflicts,
  ) {
    final categoryIds = {
      ...existingCategories.map((category) => category.categoryId),
      ...incoming.categories.map((category) => category.categoryId),
    };
    for (final expense in incoming.expenses) {
      if (expense.categoryId.isNotEmpty &&
          !categoryIds.contains(expense.categoryId)) {
        conflicts.add(
          ImportConflict(
            collection: BackupCollection.expenses,
            itemId: expense.expenseId,
            reason: ImportConflictReason.missingCategory,
            incomingUpdatedAt: expense.updatedAt,
          ),
        );
      }
    }
  }
}

class _PreviewItem {
  const _PreviewItem(this.id, this.updatedAt);

  final String id;
  final DateTime updatedAt;
}
