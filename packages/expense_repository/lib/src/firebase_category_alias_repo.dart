import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_alias_repo.dart';
import 'entities/category_alias_entity.dart';
import 'models/category_alias.dart';

class FirebaseCategoryAliasRepository implements CategoryAliasRepository {
  FirebaseCategoryAliasRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(
          userId.isNotEmpty,
          'FirebaseCategoryAliasRepository requires userId',
        );

  final String userId;
  final FirebaseFirestore _firestore;

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String aliasesPathFor(String userId) =>
      'users/$userId/category_aliases';

  CollectionReference<Map<String, dynamic>> get _aliasCollection =>
      _firestore.collection(aliasesPathFor(userId));

  Query<Map<String, dynamic>> _query() {
    return _aliasCollection.orderBy('lastUsedAt', descending: true);
  }

  @override
  Future<List<CategoryAlias>> getAliases() async {
    try {
      final snapshot = await _query().get();
      return snapshot.docs
          .map(
            (doc) => CategoryAlias.fromEntity(
              CategoryAliasEntity.fromDocument(doc.data()),
            ),
          )
          .toList();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<List<CategoryAlias>> watchAliases() {
    return _query().snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CategoryAlias.fromEntity(
                  CategoryAliasEntity.fromDocument(doc.data()),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> upsertAlias(CategoryAlias alias) async {
    if (alias.phrase.trim().isEmpty) {
      throw ArgumentError.value(
          alias.phrase, 'phrase', 'phrase cannot be empty');
    }
    if (alias.categoryId.trim().isEmpty) {
      throw ArgumentError.value(
        alias.categoryId,
        'categoryId',
        'categoryId cannot be empty',
      );
    }
    final now = DateTime.now();
    final aliasToSave = alias.copyWith(
      userId: userId,
      updatedAt: now,
      lastUsedAt: now,
    );
    try {
      await _aliasCollection
          .doc(aliasToSave.aliasId)
          .set(aliasToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteAlias(String aliasId) async {
    if (aliasId.trim().isEmpty) return;
    try {
      await _aliasCollection.doc(aliasId).delete();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
}
