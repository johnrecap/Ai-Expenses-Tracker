import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseRecurringExpenseRepository implements RecurringExpenseRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseRecurringExpenseRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
          userId.isNotEmpty,
          'FirebaseRecurringExpenseRepository requires userId',
        );

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String recurringExpensesPathFor(String userId) =>
      'users/$userId/recurring_expenses';

  CollectionReference<Map<String, dynamic>> get _recurringCollection =>
      _firestore.collection(recurringExpensesPathFor(userId));

  @override
  Future<void> createRecurringExpense(
    RecurringExpense recurringExpense,
  ) async {
    final now = DateTime.now();
    final ruleToSave = recurringExpense.copyWith(
      userId: userId,
      currency: recurringExpense.currency.trim().toUpperCase(),
      createdAt: recurringExpense.createdAt.millisecondsSinceEpoch == 0
          ? now
          : recurringExpense.createdAt,
      updatedAt: now,
    );

    try {
      await _recurringCollection
          .doc(ruleToSave.recurringExpenseId)
          .set(ruleToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateRecurringExpense(
    RecurringExpense recurringExpense,
  ) async {
    final ruleToSave = recurringExpense.copyWith(
      userId: userId,
      currency: recurringExpense.currency.trim().toUpperCase(),
      updatedAt: DateTime.now(),
    );

    try {
      await _recurringCollection
          .doc(ruleToSave.recurringExpenseId)
          .set(ruleToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveRecurringExpense(String recurringExpenseId) async {
    try {
      await _recurringCollection.doc(recurringExpenseId).set(
        {
          'userId': userId,
          'isActive': false,
          'isArchived': true,
          'updatedAt': DateTime.now(),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<List<RecurringExpense>> getDueRecurringExpenses(DateTime now) async {
    try {
      final snapshot = await _recurringCollection
          .where('isActive', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .where('nextRunDate', isLessThanOrEqualTo: now)
          .orderBy('nextRunDate')
          .get();

      return snapshot.docs
          .map(
            (doc) => RecurringExpense.fromEntity(
              RecurringExpenseEntity.fromDocument(doc.data()),
            ),
          )
          .toList();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<List<RecurringExpense>> watchRecurringExpenses({
    bool includeArchived = false,
  }) {
    return _recurringCollection
        .orderBy('nextRunDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => RecurringExpense.fromEntity(
                RecurringExpenseEntity.fromDocument(doc.data()),
              ),
            )
            .where(
              (rule) => includeArchived || !rule.isArchived,
            )
            .toList());
  }
}
