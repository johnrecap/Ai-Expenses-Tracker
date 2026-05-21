import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseSavingGoalRepository implements SavingGoalRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseSavingGoalRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
          userId.isNotEmpty,
          'FirebaseSavingGoalRepository requires userId',
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

  static String savingGoalsPathFor(String userId) =>
      'users/$userId/saving_goals';

  CollectionReference<Map<String, dynamic>> get _goalCollection =>
      _firestore.collection(savingGoalsPathFor(userId));

  @override
  Future<void> createSavingGoal(SavingGoal goal) async {
    final now = DateTime.now();
    final goalToSave = goal.copyWith(
      userId: userId,
      name: goal.name.trim(),
      currency: goal.currency.trim().toUpperCase(),
      currentAmount: goal.currentAmount < 0 ? 0 : goal.currentAmount,
      isArchived: false,
      createdAt:
          goal.createdAt.millisecondsSinceEpoch == 0 ? now : goal.createdAt,
      updatedAt: now,
    );

    try {
      await _goalCollection
          .doc(goalToSave.goalId)
          .set(goalToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {
    final goalToSave = goal.copyWith(
      userId: userId,
      name: goal.name.trim(),
      currency: goal.currency.trim().toUpperCase(),
      currentAmount: goal.currentAmount < 0 ? 0 : goal.currentAmount,
      updatedAt: DateTime.now(),
    );

    try {
      await _goalCollection
          .doc(goalToSave.goalId)
          .set(goalToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveSavingGoal(String goalId) async {
    try {
      await _goalCollection.doc(goalId).set(
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
  Future<void> contributeToSavingGoal({
    required String goalId,
    required double amount,
  }) async {
    try {
      await _goalCollection.doc(goalId).set(
        {
          'userId': userId,
          'currentAmount': FieldValue.increment(amount),
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
  Stream<List<SavingGoal>> watchSavingGoals({bool includeArchived = false}) {
    return _goalCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SavingGoal.fromEntity(
                  SavingGoalEntity.fromDocument({
                    ...doc.data(),
                    'goalId': doc.data()['goalId'] ?? doc.id,
                  }),
                ),
              )
              .where((goal) => includeArchived || !goal.isArchived)
              .toList(),
        );
  }
}
