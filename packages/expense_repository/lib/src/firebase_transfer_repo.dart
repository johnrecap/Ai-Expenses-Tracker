import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseTransferRepository implements TransferRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseTransferRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(userId.isNotEmpty, 'FirebaseTransferRepository requires userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String transfersPathFor(String userId) => 'users/$userId/transfers';

  CollectionReference<Map<String, dynamic>> get _transferCollection =>
      _firestore.collection(transfersPathFor(userId));

  @override
  Future<void> createTransfer(Transfer transfer) async {
    final now = DateTime.now();
    final transferToSave = _normalizedTransfer(
      transfer,
      isArchived: false,
      createdAt: transfer.createdAt.millisecondsSinceEpoch == 0
          ? now
          : transfer.createdAt,
      updatedAt: now,
    );

    try {
      await _transferCollection
          .doc(transferToSave.transferId)
          .set(transferToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateTransfer(Transfer transfer) async {
    final transferToSave = _normalizedTransfer(
      transfer,
      updatedAt: DateTime.now(),
    );

    try {
      await _transferCollection
          .doc(transferToSave.transferId)
          .set(transferToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveTransfer(String transferId) async {
    try {
      await _transferCollection.doc(transferId).set(
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
  Future<List<Transfer>> getTransfers({
    bool includeArchived = false,
  }) async {
    try {
      final snapshot =
          await _transferCollection.orderBy('date', descending: true).get();
      return snapshot.docs
          .map(_transferFromDocument)
          .where((transfer) => includeArchived || !transfer.isArchived)
          .toList();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<List<Transfer>> watchTransfers({
    bool includeArchived = false,
  }) {
    return _transferCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(_transferFromDocument)
              .where((transfer) => includeArchived || !transfer.isArchived)
              .toList(),
        );
  }

  Transfer _normalizedTransfer(
    Transfer transfer, {
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final feeWalletId = transfer.feeWalletId?.trim();
    return transfer.copyWith(
      userId: userId,
      sourceWalletId: transfer.sourceWalletId.trim(),
      destinationWalletId: transfer.destinationWalletId.trim(),
      amount: transfer.amount < 0 ? 0 : transfer.amount,
      currency: transfer.currency.trim().toUpperCase(),
      feeAmount: transfer.feeAmount < 0 ? 0 : transfer.feeAmount,
      feeWalletId: feeWalletId == null || feeWalletId.isEmpty
          ? null
          : feeWalletId,
      clearFeeWalletId: feeWalletId == null || feeWalletId.isEmpty,
      note: transfer.note.trim(),
      isArchived: isArchived ?? transfer.isArchived,
      createdAt: createdAt ?? transfer.createdAt,
      updatedAt: updatedAt ?? transfer.updatedAt,
    );
  }

  Transfer _transferFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Transfer.fromEntity(
      TransferEntity.fromDocument({
        ...doc.data(),
        'transferId': doc.data()['transferId'] ?? doc.id,
      }),
    );
  }
}
