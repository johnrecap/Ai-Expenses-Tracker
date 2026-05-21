import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseWalletAccountRepository implements WalletAccountRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseWalletAccountRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
          userId.isNotEmpty,
          'FirebaseWalletAccountRepository requires userId',
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

  static String walletsPathFor(String userId) => 'users/$userId/wallets';

  CollectionReference<Map<String, dynamic>> get _walletCollection =>
      _firestore.collection(walletsPathFor(userId));

  @override
  Future<void> createWallet(WalletAccount wallet) async {
    final now = DateTime.now();
    final walletToSave = wallet.copyWith(
      userId: userId,
      name: wallet.name.trim(),
      currency: wallet.currency.trim().toUpperCase(),
      openingBalance: wallet.openingBalance < 0 ? 0 : wallet.openingBalance,
      isArchived: false,
      createdAt:
          wallet.createdAt.millisecondsSinceEpoch == 0 ? now : wallet.createdAt,
      updatedAt: now,
    );

    try {
      await _walletCollection
          .doc(walletToSave.walletId)
          .set(walletToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(WalletAccount wallet) async {
    final walletToSave = wallet.copyWith(
      userId: userId,
      name: wallet.name.trim(),
      currency: wallet.currency.trim().toUpperCase(),
      openingBalance: wallet.openingBalance < 0 ? 0 : wallet.openingBalance,
      updatedAt: DateTime.now(),
    );

    try {
      await _walletCollection
          .doc(walletToSave.walletId)
          .set(walletToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveWallet(String walletId) async {
    try {
      await _walletCollection.doc(walletId).set(
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
  Future<List<WalletAccount>> getWallets({
    bool includeArchived = false,
  }) async {
    try {
      final snapshot = await _walletCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map(_walletFromDocument)
          .where((wallet) => includeArchived || !wallet.isArchived)
          .toList();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<List<WalletAccount>> watchWallets({
    bool includeArchived = false,
  }) {
    return _walletCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(_walletFromDocument)
              .where((wallet) => includeArchived || !wallet.isArchived)
              .toList(),
        );
  }

  WalletAccount _walletFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return WalletAccount.fromEntity(
      WalletAccountEntity.fromDocument({
        ...doc.data(),
        'walletId': doc.data()['walletId'] ?? doc.id,
      }),
    );
  }
}
