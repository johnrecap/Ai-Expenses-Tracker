import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_repo.dart';
import 'entities/category_entity.dart';
import 'models/category.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseCategoryRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(userId.isNotEmpty, 'FirebaseCategoryRepository requires userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String categoriesPathFor(String userId) => 'users/$userId/categories';

  CollectionReference<Map<String, dynamic>> get _categoryCollection =>
      _firestore.collection(categoriesPathFor(userId));

  Query<Map<String, dynamic>> _query() {
    return _categoryCollection.orderBy('name');
  }

  @override
  Future<void> createCategory(Category category) async {
    final now = DateTime.now();
    final categoryToSave = category.copyWith(
      userId: userId,
      isArchived: false,
      createdAt: category.createdAt,
      updatedAt: now,
    );

    try {
      await _categoryCollection
          .doc(categoryToSave.categoryId)
          .set(categoryToSave.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    final categoryToSave = category.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
    );

    try {
      await _categoryCollection
          .doc(categoryToSave.categoryId)
          .set(categoryToSave.toEntity().toDocument(), SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> archiveCategory(Category category) async {
    try {
      await _categoryCollection.doc(category.categoryId).set(
        {
          'userId': userId,
          'isArchived': true,
          'updatedAt': DateTime.now(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    try {
      final snapshot = await _query().get();
      return snapshot.docs
          .map(
            (doc) => Category.fromEntity(
              CategoryEntity.fromDocument(doc.data()),
            ),
          )
          .where(
            (category) => includeArchived || !category.isArchived,
          )
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return _query().snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Category.fromEntity(
                  CategoryEntity.fromDocument(doc.data()),
                ),
              )
              .where(
                (category) => includeArchived || !category.isArchived,
              )
              .toList(),
        );
  }
}
