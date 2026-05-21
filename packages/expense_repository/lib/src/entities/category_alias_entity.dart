import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryAliasEntity {
  const CategoryAliasEntity({
    required this.aliasId,
    required this.userId,
    required this.categoryId,
    required this.phrase,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsedAt,
    required this.useCount,
  });

  final String aliasId;
  final String userId;
  final String categoryId;
  final String phrase;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastUsedAt;
  final int useCount;

  Map<String, Object?> toDocument() {
    return {
      'aliasId': aliasId,
      'userId': userId,
      'categoryId': categoryId,
      'phrase': phrase,
      'locale': locale,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastUsedAt': lastUsedAt,
      'useCount': useCount,
    };
  }

  static CategoryAliasEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryAliasEntity(
      aliasId: doc['aliasId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      categoryId: doc['categoryId'] as String? ?? '',
      phrase: doc['phrase'] as String? ?? '',
      locale: doc['locale'] as String? ?? '',
      createdAt: _dateTimeFromValue(doc['createdAt']),
      updatedAt: _dateTimeFromValue(doc['updatedAt']),
      lastUsedAt: _dateTimeFromValue(doc['lastUsedAt']),
      useCount: _intFromValue(doc['useCount']) ?? 0,
    );
  }

  static DateTime _dateTimeFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static int? _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
