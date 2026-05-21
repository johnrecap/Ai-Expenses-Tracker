import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseExpenseRepo({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(userId.isNotEmpty, 'FirebaseExpenseRepo requires a userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String expensesPathFor(String userId) => 'users/$userId/expenses';

  CollectionReference<Map<String, dynamic>> get expenseCollection =>
      _firestore.collection(expensesPathFor(userId));

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      expense.userId = userId;
      expense.updatedAt = DateTime.now();
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      expense.userId = userId;
      expense.updatedAt = DateTime.now();
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument(), SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await expenseCollection.doc(expenseId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    try {
      final snapshot = await expenseCollection.doc(expenseId).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return _expenseFromDocument(data, snapshot.metadata);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      return await expenseCollection
          .orderBy('date', descending: true)
          .get()
          .then((value) => value.docs
              .map((e) => _expenseFromDocument(e.data(), e.metadata))
              .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return expenseCollection
        .orderBy('date', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => snapshot.docs
            .map((doc) => _expenseFromDocument(doc.data(), doc.metadata))
            .toList());
  }

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    try {
      final snapshot = await _orderedExpenseQuery(
        filter: filter,
        startAfter: startAfter,
        limit: limit,
      ).get();
      return _pageFromSnapshot(snapshot, limit, filter);
    } catch (e) {
      log(e.toString());
      if (_isMissingIndexError(e)) {
        return _fallbackExpensePage(
          limit: limit,
          startAfter: startAfter,
          filter: filter,
        );
      }
      rethrow;
    }
  }

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) async* {
    try {
      await for (final snapshot in expenseCollection
          .orderBy('date', descending: true)
          .orderBy('expenseId', descending: true)
          .limit(_boundedLimit(limit) + 1)
          .snapshots(includeMetadataChanges: true)) {
        yield _pageFromSnapshot(
          snapshot,
          limit,
          ExpenseFilter.empty,
        );
      }
    } catch (e) {
      log(e.toString());
      if (!_isMissingIndexError(e)) rethrow;
      yield* _fallbackRecentExpensePageStream(limit: limit);
    }
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    try {
      Query<Map<String, dynamic>> query = expenseCollection;

      if (filter.startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: filter.startDate,
        );
      }

      if (filter.endDate != null) {
        final endDate = DateTime(
          filter.endDate!.year,
          filter.endDate!.month,
          filter.endDate!.day,
          23,
          59,
          59,
          999,
        );
        query = query.where(
          'date',
          isLessThanOrEqualTo: endDate,
        );
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      final normalizedQuery = filter.query.trim().toLowerCase();

      return snapshot.docs
          .map((doc) => _expenseFromDocument(doc.data(), doc.metadata))
          .where((expense) => _matchesFilter(expense, filter, normalizedQuery))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Query<Map<String, dynamic>> _orderedExpenseQuery({
    required ExpenseFilter filter,
    required ExpensePageCursor? startAfter,
    required int limit,
  }) {
    Query<Map<String, dynamic>> query = expenseCollection;

    if (filter.startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: filter.startDate,
      );
    }

    if (filter.endDate != null) {
      final endDate = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
        999,
      );
      query = query.where(
        'date',
        isLessThanOrEqualTo: endDate,
      );
    }

    query = query
        .orderBy('date', descending: true)
        .orderBy('expenseId', descending: true);

    if (startAfter != null) {
      query = query.startAfter([startAfter.date, startAfter.expenseId]);
    }

    return query.limit(_boundedLimit(limit) + 1);
  }

  Stream<ExpensePage> _fallbackRecentExpensePageStream({
    required int limit,
  }) {
    return expenseCollection
        .orderBy('date', descending: true)
        .limit(_boundedLimit(limit) + 1)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => _pageFromSnapshot(
              snapshot,
              limit,
              ExpenseFilter.empty,
            ));
  }

  Future<ExpensePage> _fallbackExpensePage({
    required int limit,
    required ExpensePageCursor? startAfter,
    required ExpenseFilter filter,
  }) async {
    Query<Map<String, dynamic>> query = expenseCollection;

    if (filter.startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: filter.startDate,
      );
    }

    if (filter.endDate != null) {
      final endDate = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
        999,
      );
      query = query.where(
        'date',
        isLessThanOrEqualTo: endDate,
      );
    }

    final snapshot = await query.orderBy('date', descending: true).get();
    final normalizedQuery = filter.query.trim().toLowerCase();
    final orderedExpenses = snapshot.docs
        .map((doc) => _expenseFromDocument(doc.data(), doc.metadata))
        .where((expense) => _matchesFilter(expense, filter, normalizedQuery))
        .toList(growable: false)
      ..sort(_compareNewestFirst);
    final startIndex = startAfter == null
        ? 0
        : orderedExpenses.indexWhere(
              (expense) =>
                  expense.date == startAfter.date &&
                  expense.expenseId == startAfter.expenseId,
            ) +
            1;
    return ExpensePage.fromOrderedExpenses(
      startIndex <= 0
          ? orderedExpenses
          : orderedExpenses.skip(startIndex).toList(growable: false),
      limit: limit,
    );
  }

  ExpensePage _pageFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int limit,
    ExpenseFilter filter,
  ) {
    final normalizedQuery = filter.query.trim().toLowerCase();
    final safeLimit = _boundedLimit(limit);
    final rawExpenses = snapshot.docs
        .map((doc) => _expenseFromDocument(doc.data(), doc.metadata))
        .toList(growable: false)
      ..sort(_compareNewestFirst);
    final scannedExpenses = rawExpenses.take(safeLimit).toList(growable: false);
    final visibleExpenses = scannedExpenses
        .where((expense) => _matchesFilter(expense, filter, normalizedQuery))
        .toList(growable: false);
    return ExpensePage(
      expenses: List<Expense>.unmodifiable(visibleExpenses),
      nextCursor: scannedExpenses.isEmpty
          ? null
          : ExpensePageCursor.fromExpense(scannedExpenses.last),
      hasMore: rawExpenses.length > safeLimit,
    );
  }

  int _boundedLimit(int limit) {
    if (limit <= 0) return defaultExpensePageSize;
    return limit;
  }

  int _compareNewestFirst(Expense first, Expense second) {
    final dateCompare = second.date.compareTo(first.date);
    if (dateCompare != 0) return dateCompare;
    return second.expenseId.compareTo(first.expenseId);
  }

  bool _isMissingIndexError(Object error) {
    if (error is! FirebaseException) return false;
    final message = (error.message ?? '').toLowerCase();
    return error.code == 'failed-precondition' &&
        (message.contains('index') ||
            message.contains('requires an index') ||
            message.contains('create it here'));
  }

  bool _matchesFilter(
    Expense expense,
    ExpenseFilter filter,
    String normalizedQuery,
  ) {
    final matchesQuery = normalizedQuery.isEmpty ||
        expense.description.toLowerCase().contains(normalizedQuery) ||
        expense.categoryName.toLowerCase().contains(normalizedQuery) ||
        expense.category.name.toLowerCase().contains(normalizedQuery) ||
        expense.paymentMethod.label.toLowerCase().contains(normalizedQuery) ||
        expense.paymentMethod.storageValue
            .toLowerCase()
            .contains(normalizedQuery) ||
        (expense.walletAccountName ?? '')
            .toLowerCase()
            .contains(normalizedQuery) ||
        (expense.walletAccountId ?? '').toLowerCase().contains(normalizedQuery);
    final matchesCategory = filter.categoryIds.isEmpty ||
        filter.categoryIds.contains(expense.categoryId) ||
        (expense.categoryId.isEmpty &&
            (filter.categoryIds.contains(expense.categoryName) ||
                filter.categoryIds.contains(expense.category.name)));
    final matchesMinAmount =
        filter.minAmount == null || expense.amount >= filter.minAmount!;
    final matchesMaxAmount =
        filter.maxAmount == null || expense.amount <= filter.maxAmount!;
    final matchesPayment = filter.paymentMethods.isEmpty ||
        filter.paymentMethods.contains(expense.paymentMethod);
    final matchesCurrency = filter.currency == null ||
        filter.currency!.trim().isEmpty ||
        expense.currency.toUpperCase() == filter.currency!.trim().toUpperCase();
    final matchesWallet = filter.walletAccountId == null ||
        filter.walletAccountId!.trim().isEmpty ||
        expense.walletAccountId == filter.walletAccountId!.trim();

    return matchesQuery &&
        matchesCategory &&
        matchesMinAmount &&
        matchesMaxAmount &&
        matchesPayment &&
        matchesCurrency &&
        matchesWallet;
  }

  Expense _expenseFromDocument(
    Map<String, dynamic> data,
    SnapshotMetadata metadata,
  ) {
    return Expense.fromEntity(ExpenseEntity.fromDocument(data)).withSyncStatus(
      SyncStatus.fromFirestoreMetadata(
        hasPendingWrites: metadata.hasPendingWrites,
      ),
    );
  }
}
