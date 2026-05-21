import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseCategoryBudgetRepository implements CategoryBudgetRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseCategoryBudgetRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
          userId.isNotEmpty,
          'FirebaseCategoryBudgetRepository requires userId',
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

  static String categoryBudgetsPathFor(String userId) =>
      'users/$userId/category_budgets';

  CollectionReference<Map<String, dynamic>> get _categoryBudgetCollection =>
      _firestore.collection(categoryBudgetsPathFor(userId));

  @override
  Future<void> saveCategoryBudget(CategoryBudget categoryBudget) async {
    final now = DateTime.now();
    final currency = categoryBudget.currency.trim().toUpperCase();
    final budgetToSave = categoryBudget.copyWith(
      categoryBudgetId: CategoryBudget.categoryBudgetIdFor(
        month: categoryBudget.month,
        categoryId: categoryBudget.categoryId,
        currency: currency,
      ),
      userId: userId,
      currency: currency,
      isArchived: false,
      updatedAt: now,
      createdAt: categoryBudget.createdAt.millisecondsSinceEpoch == 0
          ? now
          : categoryBudget.createdAt,
    );

    try {
      await _categoryBudgetCollection
          .doc(budgetToSave.categoryBudgetId)
          .set(budgetToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveCategoryBudget(String categoryBudgetId) async {
    try {
      await _categoryBudgetCollection.doc(categoryBudgetId).set(
        {
          'userId': userId,
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
  Future<List<CategoryBudget>> getCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) async {
    try {
      final snapshot = await _categoryBudgetCollection
          .where('month', isEqualTo: month)
          .get();
      return snapshot.docs
          .map(
            (doc) => CategoryBudget.fromEntity(
              CategoryBudgetEntity.fromDocument(doc.data()),
            ),
          )
          .where((budget) => includeArchived || !budget.isArchived)
          .toList()
        ..sort((a, b) => a.categoryName.compareTo(b.categoryName));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) {
    return _categoryBudgetCollection
        .where('month', isEqualTo: month)
        .snapshots()
        .map((snapshot) {
      final budgets = snapshot.docs
          .map(
            (doc) => CategoryBudget.fromEntity(
              CategoryBudgetEntity.fromDocument(doc.data()),
            ),
          )
          .where((budget) => includeArchived || !budget.isArchived)
          .toList()
        ..sort((a, b) => a.categoryName.compareTo(b.categoryName));
      return budgets;
    });
  }
}
