import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseAiActionLogRepository implements AiActionLogRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseAiActionLogRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
            userId.isNotEmpty, 'FirebaseAiActionLogRepository requires userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String aiActionsPathFor(String userId) => 'users/$userId/ai_actions';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(aiActionsPathFor(userId));

  @override
  Future<void> createActionLog(AiActionLog logEntry) async {
    try {
      final normalized = logEntry.copyWith(
        userId: userId,
        createdAt: logEntry.createdAt,
      );
      await _collection
          .doc(normalized.actionId)
          .set(normalized.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<List<AiActionLog>> getRecentActionLogs({int limit = 50}) async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => AiActionLog.fromEntity(
                AiActionLogEntity.fromDocument(doc.data()),
              ))
          .toList();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateActionLogStatus({
    required String actionId,
    required AiActionLogStatus status,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
  }) async {
    try {
      await _collection.doc(actionId).set(
        {
          'status': status.value,
          'confirmedAt': confirmedAt,
          'targetExpenseId': targetExpenseId,
          'errorMessage': errorMessage,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
}
