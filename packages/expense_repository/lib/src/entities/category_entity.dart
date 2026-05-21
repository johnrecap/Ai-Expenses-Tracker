import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryEntity {
  String categoryId;
  String userId;
  String name;
  int totalExpenses;
  String icon;
  int color;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;

  CategoryEntity({
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryId': categoryId,
      'userId': userId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    final createdAt = _dateFromValue(doc['createdAt']) ?? DateTime.now();
    return CategoryEntity(
      categoryId: doc['categoryId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      name: doc['name'] as String? ?? '',
      totalExpenses: _intFromValue(doc['totalExpenses']) ?? 0,
      icon: doc['icon'] as String? ?? '',
      color: _intFromValue(doc['color']) ?? 0,
      isArchived: doc['isArchived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateFromValue(doc['updatedAt']) ?? createdAt,
    );
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int? _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
