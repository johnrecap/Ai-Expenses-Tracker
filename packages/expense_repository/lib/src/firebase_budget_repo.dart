import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseBudgetRepository implements BudgetRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseBudgetRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(userId.isNotEmpty, 'FirebaseBudgetRepository requires userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String budgetPathFor(String userId) => 'users/$userId/budgets';

  CollectionReference<Map<String, dynamic>> get _budgetCollection =>
      _firestore.collection(budgetPathFor(userId));

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async {
    try {
      final snapshot = await _budgetCollection
          .doc(Budget.budgetIdFor(month: month, year: year))
          .get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return Budget.fromEntity(BudgetEntity.fromDocument(data));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final now = DateTime.now();
    final budgetToSave = budget.copyWith(
      budgetId: Budget.budgetIdFor(month: budget.month, year: budget.year),
      userId: userId,
      currency: budget.currency.trim().toUpperCase(),
      updatedAt: now,
      createdAt:
          budget.createdAt.millisecondsSinceEpoch == 0 ? now : budget.createdAt,
    );

    try {
      await _budgetCollection
          .doc(budgetToSave.budgetId)
          .set(budgetToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    return _budgetCollection
        .doc(Budget.budgetIdFor(month: month, year: year))
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return Budget.fromEntity(BudgetEntity.fromDocument(data));
    });
  }
}
