import 'dart:async';
import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/security/security.dart';

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository([List<Expense>? expenses])
      : _expenses = List<Expense>.from(expenses ?? const []);

  final List<Expense> _expenses;
  final _controller = StreamController<List<Expense>>.broadcast();
  final List<Expense> updatedExpenses = [];
  final List<String> deletedExpenseIds = [];

  void emit([List<Expense>? expenses]) {
    if (expenses != null) {
      _expenses
        ..clear()
        ..addAll(expenses);
    }
    _controller.add(List<Expense>.unmodifiable(_expenses));
  }

  @override
  Future<void> createExpense(Expense expense) async {
    _expenses.add(expense);
    emit();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    deletedExpenseIds.add(expenseId);
    _expenses.removeWhere((expense) => expense.expenseId == expenseId);
    emit();
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    return _expenses
        .where((expense) => expense.expenseId == expenseId)
        .firstOrNull;
  }

  @override
  Future<List<Expense>> getExpenses() async => List.unmodifiable(_expenses);

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    return _expensePage(_expenses, limit: limit, startAfter: startAfter);
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return List.unmodifiable(_expenses);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    updatedExpenses.add(expense);
    final index =
        _expenses.indexWhere((item) => item.expenseId == expense.expenseId);
    if (index == -1) return;
    _expenses[index] = expense;
    emit();
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return _controller.stream;
  }

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) {
    return _controller.stream.map((expenses) {
      return _expensePage(expenses, limit: limit);
    });
  }

  Future<void> close() => _controller.close();
}

ExpensePage _expensePage(
  List<Expense> expenses, {
  required int limit,
  ExpensePageCursor? startAfter,
}) {
  final ordered = List<Expense>.from(expenses)
    ..sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return b.expenseId.compareTo(a.expenseId);
    });
  final startIndex = startAfter == null
      ? 0
      : ordered.indexWhere(
            (expense) =>
                expense.date == startAfter.date &&
                expense.expenseId == startAfter.expenseId,
          ) +
          1;
  return ExpensePage.fromOrderedExpenses(
    startIndex <= 0 ? ordered : ordered.skip(startIndex).toList(),
    limit: limit,
  );
}

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([List<Category>? categories])
      : _categories = List<Category>.from(categories ?? const []);

  final List<Category> _categories;

  @override
  Future<void> archiveCategory(Category category) async {
    final index = _categories
        .indexWhere((item) => item.categoryId == category.categoryId);
    if (index == -1) return;
    _categories[index] = category.copyWith(isArchived: true);
  }

  @override
  Future<void> createCategory(Category category) async {
    _categories.add(category);
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    return _visible(includeArchived);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final index = _categories
        .indexWhere((item) => item.categoryId == category.categoryId);
    if (index == -1) return;
    _categories[index] = category;
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return Stream.value(_visible(includeArchived));
  }

  List<Category> _visible(bool includeArchived) {
    return List.unmodifiable(
      includeArchived
          ? _categories
          : _categories.where((item) => !item.isArchived),
    );
  }
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.settings);

  UserSettings settings;
  bool fail = false;

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    if (fail) throw Exception('failed');
    return settings;
  }

  @override
  Future<UserSettings> getSettings() async {
    if (fail) throw Exception('failed');
    return settings;
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    if (fail) throw Exception('failed');
    this.settings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(baseCurrency: currencyCode.toUpperCase());
  }

  @override
  Future<void> updateConversionRates(Map<String, num> conversionRates) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(conversionRates: conversionRates);
  }

  @override
  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  }) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(
      conversionRates: conversionRates,
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
    );
  }

  @override
  Future<void> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Future<void> updateAppDisplayName(String? displayName) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(
      appDisplayName: displayName,
      clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
    );
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Stream<UserSettings> watchSettings() {
    if (fail) return Stream<UserSettings>.error(Exception('failed'));
    return Stream.value(settings);
  }
}

class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository([this.budget]);

  Budget? budget;

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async {
    return budget;
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    this.budget = budget;
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    return Stream.value(budget);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._currentUser);

  AppUser? _currentUser;
  final _controller = StreamController<AppUser?>.broadcast();
  int signOutCalls = 0;
  int updateDisplayNameCalls = 0;
  int passwordResetCalls = 0;
  int emailUpdateCalls = 0;
  int reauthenticateCalls = 0;
  int googleReauthenticateCalls = 0;
  int deleteCurrentUserCalls = 0;
  bool failDisplayNameUpdate = false;
  AuthActionResult passwordResetResult = const AuthActionResult.success();
  AuthActionResult emailUpdateResult = const AuthActionResult.success();
  AuthActionResult reauthenticateResult = const AuthActionResult.success();
  AuthActionResult googleReauthenticateResult =
      const AuthActionResult.success();
  AuthActionResult deleteCurrentUserResult = const AuthActionResult.success();
  String? lastPasswordResetEmail;
  String? lastUpdatedEmail;
  String? lastReauthenticationEmail;
  String? lastReauthenticationPassword;

  void emitCurrentUser() => _controller.add(_currentUser);

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<String?> getIdToken() async => 'test-token';

  @override
  Future<void> resetPassword(String email) async {
    final result = await requestPasswordReset(email);
    if (!result.isSuccess) {
      throw AuthRepositoryException(
        result.code ?? 'password-reset-failed',
        result.message ?? 'Password reset failed.',
      );
    }
  }

  @override
  Future<AuthActionResult> requestPasswordReset(String email) async {
    passwordResetCalls += 1;
    lastPasswordResetEmail = email.trim();
    return passwordResetResult;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    return _currentUser ?? AppUser.empty;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _currentUser ?? AppUser.empty;
  }

  @override
  Future<AppUser?> signInWithGoogle() async => _currentUser;

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    updateDisplayNameCalls += 1;
    if (failDisplayNameUpdate) {
      throw const AuthRepositoryException(
        'profile-update-failed',
        'Profile update failed.',
      );
    }
    final user = _currentUser;
    if (user == null || user.isEmpty) {
      throw const AuthRepositoryException(
        'missing-user',
        'No signed-in user is available.',
      );
    }
    final updatedUser = user.copyWith(displayName: displayName.trim());
    _currentUser = updatedUser;
    _controller.add(updatedUser);
    return updatedUser;
  }

  @override
  Future<AuthActionResult> updateEmail(String newEmail) async {
    emailUpdateCalls += 1;
    lastUpdatedEmail = newEmail.trim();
    if (emailUpdateResult.isSuccess) {
      final user = _currentUser;
      if (user != null && user.isNotEmpty) {
        final updatedUser = user.copyWith(email: newEmail.trim());
        _currentUser = updatedUser;
        _controller.add(updatedUser);
      }
    }
    return emailUpdateResult;
  }

  @override
  Future<AuthActionResult> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    reauthenticateCalls += 1;
    lastReauthenticationEmail = email.trim();
    lastReauthenticationPassword = password;
    return reauthenticateResult;
  }

  @override
  Future<AuthActionResult> reauthenticateWithGoogle() async {
    googleReauthenticateCalls += 1;
    return googleReauthenticateResult;
  }

  @override
  Future<AuthActionResult> deleteCurrentUser() async {
    deleteCurrentUserCalls += 1;
    if (deleteCurrentUserResult.isSuccess) {
      _currentUser = null;
      _controller.add(null);
    }
    return deleteCurrentUserResult;
  }

  @override
  Stream<AppUser?> get user => _controller.stream;

  Future<void> close() => _controller.close();
}

class FakeCategoryBudgetRepository implements CategoryBudgetRepository {
  @override
  Future<void> archiveCategoryBudget(String categoryBudgetId) async {}

  @override
  Future<List<CategoryBudget>> getCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) async {
    return const [];
  }

  @override
  Future<void> saveCategoryBudget(CategoryBudget categoryBudget) async {}

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) {
    return const Stream.empty();
  }
}

class FakeRecurringExpenseRepository implements RecurringExpenseRepository {
  @override
  Future<void> archiveRecurringExpense(String recurringExpenseId) async {}

  @override
  Future<void> createRecurringExpense(
      RecurringExpense recurringExpense) async {}

  @override
  Future<List<RecurringExpense>> getDueRecurringExpenses(DateTime now) async {
    return const [];
  }

  @override
  Future<void> updateRecurringExpense(
      RecurringExpense recurringExpense) async {}

  @override
  Stream<List<RecurringExpense>> watchRecurringExpenses({
    bool includeArchived = false,
  }) {
    return const Stream.empty();
  }
}

class FakeSavingGoalRepository implements SavingGoalRepository {
  @override
  Future<void> archiveSavingGoal(String goalId) async {}

  @override
  Future<void> contributeToSavingGoal({
    required String goalId,
    required double amount,
  }) async {}

  @override
  Future<void> createSavingGoal(SavingGoal goal) async {}

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {}

  @override
  Stream<List<SavingGoal>> watchSavingGoals({bool includeArchived = false}) {
    return const Stream.empty();
  }
}

class FakeCategoryAliasRepository implements CategoryAliasRepository {
  @override
  Future<void> deleteAlias(String aliasId) async {}

  @override
  Future<List<CategoryAlias>> getAliases() async => const [];

  @override
  Future<void> upsertAlias(CategoryAlias alias) async {}

  @override
  Stream<List<CategoryAlias>> watchAliases() => const Stream.empty();
}

class FakeAiActionLogRepository implements AiActionLogRepository {
  @override
  Future<void> createActionLog(AiActionLog log) async {}

  @override
  Future<List<AiActionLog>> getRecentActionLogs({int limit = 50}) async {
    return const [];
  }

  @override
  Future<void> updateActionLogStatus({
    required String actionId,
    required AiActionLogStatus status,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
  }) async {}
}

class MemoryAppLockStorage implements AppLockStorage {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

class FakeBiometricAuthenticator implements BiometricAuthenticator {
  const FakeBiometricAuthenticator({this.supported = false});

  final bool supported;

  @override
  Future<bool> authenticate() async => false;

  @override
  Future<bool> isSupported() async => supported;
}

AppLockService fakeAppLockService() {
  final storage = MemoryAppLockStorage();
  return AppLockService(
    storage: storage,
    pinService: PinService(
      storage: storage,
      random: Random(7),
    ),
    biometricService: const FakeBiometricAuthenticator(),
  );
}
