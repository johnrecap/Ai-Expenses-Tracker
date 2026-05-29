import 'dart:async';

import 'package:expense_repository/expense_repository.dart';

class LocalRepositoryStore {
  final String userId;
  final Map<String, Expense> expenses = {};
  final Map<String, Category> categories = {};
  final Map<String, CategoryAlias> aliases = {};
  final Map<String, Budget> budgets = {};
  final Map<String, CategoryBudget> categoryBudgets = {};
  final Map<String, RecurringExpense> recurringExpenses = {};
  final Map<String, SavingGoal> savingGoals = {};
  final Map<String, WalletAccount> wallets = {};
  final Map<String, Transfer> transfers = {};
  final Map<String, AiActionLog> aiActionLogs = {};
  UserSettings settings;

  final List<SyncChange> pendingChanges = [];
  final StreamController<List<SyncChange>> _pendingChangesController =
      StreamController<List<SyncChange>>.broadcast();

  final StreamController<List<Expense>> _expenseController =
      StreamController<List<Expense>>.broadcast();
  final StreamController<List<Category>> _categoryController =
      StreamController<List<Category>>.broadcast();
  final StreamController<List<CategoryAlias>> _aliasController =
      StreamController<List<CategoryAlias>>.broadcast();
  final StreamController<UserSettings> _settingsController =
      StreamController<UserSettings>.broadcast();
  final StreamController<List<Budget>> _budgetController =
      StreamController<List<Budget>>.broadcast();
  final StreamController<List<CategoryBudget>> _categoryBudgetController =
      StreamController<List<CategoryBudget>>.broadcast();
  final StreamController<List<RecurringExpense>> _recurringExpenseController =
      StreamController<List<RecurringExpense>>.broadcast();
  final StreamController<List<SavingGoal>> _savingGoalController =
      StreamController<List<SavingGoal>>.broadcast();
  final StreamController<List<WalletAccount>> _walletController =
      StreamController<List<WalletAccount>>.broadcast();
  final StreamController<List<Transfer>> _transferController =
      StreamController<List<Transfer>>.broadcast();

  LocalRepositoryStore({
    required this.userId,
    UserSettings? settings,
  }) : settings = settings ?? UserSettings.defaults(userId: userId);

  Stream<List<Expense>> watchExpenses() {
    scheduleMicrotask(emitExpenses);
    return _expenseController.stream;
  }

  Stream<List<Category>> watchCategories() {
    scheduleMicrotask(emitCategories);
    return _categoryController.stream;
  }

  Stream<List<CategoryAlias>> watchAliases() {
    scheduleMicrotask(emitAliases);
    return _aliasController.stream;
  }

  Stream<UserSettings> watchSettings() {
    scheduleMicrotask(emitSettings);
    return _settingsController.stream;
  }

  Stream<List<Budget>> watchBudgets() {
    scheduleMicrotask(emitBudgets);
    return _budgetController.stream;
  }

  Stream<List<CategoryBudget>> watchCategoryBudgets() {
    scheduleMicrotask(emitCategoryBudgets);
    return _categoryBudgetController.stream;
  }

  Stream<List<RecurringExpense>> watchRecurringExpenses() {
    scheduleMicrotask(emitRecurringExpenses);
    return _recurringExpenseController.stream;
  }

  Stream<List<SavingGoal>> watchSavingGoals() {
    scheduleMicrotask(emitSavingGoals);
    return _savingGoalController.stream;
  }

  Stream<List<WalletAccount>> watchWallets() {
    scheduleMicrotask(emitWallets);
    return _walletController.stream;
  }

  Stream<List<Transfer>> watchTransfers() {
    scheduleMicrotask(emitTransfers);
    return _transferController.stream;
  }

  void emitExpenses() {
    if (!_expenseController.isClosed) {
      _expenseController.add(orderedExpenses());
    }
  }

  void emitCategories() {
    if (!_categoryController.isClosed) {
      _categoryController.add(orderedCategories());
    }
  }

  void emitAliases() {
    if (!_aliasController.isClosed) {
      _aliasController.add(orderedAliases());
    }
  }

  void emitSettings() {
    if (!_settingsController.isClosed) {
      _settingsController.add(settings);
    }
  }

  void emitBudgets() {
    if (!_budgetController.isClosed) {
      _budgetController.add(orderedBudgets());
    }
  }

  void emitCategoryBudgets() {
    if (!_categoryBudgetController.isClosed) {
      _categoryBudgetController.add(orderedCategoryBudgets());
    }
  }

  void emitRecurringExpenses() {
    if (!_recurringExpenseController.isClosed) {
      _recurringExpenseController.add(orderedRecurringExpenses());
    }
  }

  void emitSavingGoals() {
    if (!_savingGoalController.isClosed) {
      _savingGoalController.add(orderedSavingGoals());
    }
  }

  void emitWallets() {
    if (!_walletController.isClosed) {
      _walletController.add(orderedWallets());
    }
  }

  void emitTransfers() {
    if (!_transferController.isClosed) {
      _transferController.add(orderedTransfers());
    }
  }

  List<Expense> orderedExpenses() {
    return expenses.values.toList(growable: false)
      ..sort((a, b) {
        final date = b.date.compareTo(a.date);
        if (date != 0) return date;
        return b.expenseId.compareTo(a.expenseId);
      });
  }

  List<Category> orderedCategories({bool includeArchived = false}) {
    final values = categories.values
        .where((category) => includeArchived || !category.isArchived)
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  List<CategoryAlias> orderedAliases() {
    return aliases.values.toList(growable: false)
      ..sort((a, b) => a.phrase.compareTo(b.phrase));
  }

  List<Budget> orderedBudgets() {
    return budgets.values.toList(growable: false)
      ..sort((a, b) {
        final year = b.year.compareTo(a.year);
        if (year != 0) return year;
        return b.month.compareTo(a.month);
      });
  }

  List<CategoryBudget> orderedCategoryBudgets({
    bool includeArchived = false,
  }) {
    return categoryBudgets.values
        .where((budget) => includeArchived || !budget.isArchived)
        .toList(growable: false)
      ..sort((a, b) {
        final month = b.month.compareTo(a.month);
        if (month != 0) return month;
        return a.categoryName.compareTo(b.categoryName);
      });
  }

  List<RecurringExpense> orderedRecurringExpenses({
    bool includeArchived = false,
  }) {
    return recurringExpenses.values
        .where((expense) => includeArchived || !expense.isArchived)
        .toList(growable: false)
      ..sort((a, b) {
        final date = a.nextRunDate.compareTo(b.nextRunDate);
        if (date != 0) return date;
        return a.description.compareTo(b.description);
      });
  }

  List<SavingGoal> orderedSavingGoals({bool includeArchived = false}) {
    return savingGoals.values
        .where((goal) => includeArchived || !goal.isArchived)
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<WalletAccount> orderedWallets({bool includeArchived = false}) {
    return wallets.values
        .where((wallet) => includeArchived || !wallet.isArchived)
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Transfer> orderedTransfers({bool includeArchived = false}) {
    return transfers.values
        .where((transfer) => includeArchived || !transfer.isArchived)
        .toList(growable: false)
      ..sort((a, b) {
        final date = b.date.compareTo(a.date);
        if (date != 0) return date;
        return b.transferId.compareTo(a.transferId);
      });
  }

  List<AiActionLog> orderedAiActionLogs({int limit = 50}) {
    return (aiActionLogs.values.toList(growable: false)
          ..sort((a, b) {
            final date = b.createdAt.compareTo(a.createdAt);
            if (date != 0) return date;
            return b.actionId.compareTo(a.actionId);
          }))
        .take(limit)
        .toList(growable: false);
  }

  void enqueue(SyncChange change) {
    pendingChanges.add(change);
    emitPendingChanges();
  }

  Stream<List<SyncChange>> watchPendingChanges() {
    scheduleMicrotask(emitPendingChanges);
    return _pendingChangesController.stream;
  }

  void markUploadedChanges(Iterable<SyncChange> changes) {
    var expenseChanged = false;
    for (final change in changes) {
      if (change.entityType == SyncEntityType.expense &&
          change.operation == SyncOperation.upsert) {
        final expense = expenses[change.entityId];
        if (expense != null) {
          expenses[change.entityId] = expense.withSyncStatus(SyncStatus.synced);
          expenseChanged = true;
        }
      }
    }
    if (expenseChanged) {
      emitExpenses();
    }
    emitPendingChanges();
  }

  void markSyncChangesUpdated(Iterable<SyncChange> changes) {
    var expenseChanged = false;
    for (final change in changes) {
      if (change.entityType != SyncEntityType.expense ||
          change.operation != SyncOperation.upsert) {
        continue;
      }
      final expense = expenses[change.entityId];
      if (expense == null) continue;
      expenses[change.entityId] = expense.withSyncStatus(
        change.status,
        reason: change.reason,
      );
      expenseChanged = true;
    }
    if (expenseChanged) {
      emitExpenses();
    }
    emitPendingChanges();
  }

  void emitPendingChanges() {
    if (!_pendingChangesController.isClosed) {
      _pendingChangesController.add(List.unmodifiable(pendingChanges));
    }
  }

  SyncChange change({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, Object?> data,
  }) {
    final now = DateTime.now();
    return SyncChange(
      id: '${entityType.name}-$entityId-${now.microsecondsSinceEpoch}',
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      clientUpdatedAt: now,
    );
  }

  void dispose() {
    _expenseController.close();
    _categoryController.close();
    _aliasController.close();
    _settingsController.close();
    _budgetController.close();
    _categoryBudgetController.close();
    _recurringExpenseController.close();
    _savingGoalController.close();
    _walletController.close();
    _transferController.close();
    _pendingChangesController.close();
  }
}
