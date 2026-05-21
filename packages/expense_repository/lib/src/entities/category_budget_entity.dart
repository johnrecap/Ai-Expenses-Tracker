import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBudgetEntity {
  final String categoryBudgetId;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String month;
  final String currency;
  final double limitAmount;
  final int warningThresholdPercent;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryBudgetEntity({
    required this.categoryBudgetId,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.month,
    required this.currency,
    required this.limitAmount,
    required this.warningThresholdPercent,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryBudgetId': categoryBudgetId,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'month': month,
      'currency': currency,
      'limitAmount': limitAmount,
      'warningThresholdPercent': warningThresholdPercent,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static CategoryBudgetEntity fromDocument(Map<String, Object?> doc) {
    final month = _validMonth(doc['month'] as String?);
    final categoryId = doc['categoryId'] as String? ?? '';
    final currency = (doc['currency'] as String? ?? 'EGP').toUpperCase();
    final createdAt = _dateTimeFromValue(doc['createdAt']);

    return CategoryBudgetEntity(
      categoryBudgetId: doc['categoryBudgetId'] as String? ??
          '${month}_${categoryId}_$currency',
      userId: doc['userId'] as String? ?? '',
      categoryId: categoryId,
      categoryName: doc['categoryName'] as String? ?? '',
      month: month,
      currency: currency,
      limitAmount: _doubleFromValue(doc['limitAmount']) ??
          _doubleFromValue(doc['amount']) ??
          0,
      warningThresholdPercent:
          _intFromValue(doc['warningThresholdPercent']) ?? 80,
      isArchived: doc['isArchived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateTimeFromValue(doc['updatedAt'], fallback: createdAt),
    );
  }

  static String _validMonth(String? value) {
    final now = DateTime.now();
    final fallback = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (value == null) return fallback;
    final match = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value);
    return match ? value : fallback;
  }

  static int? _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _doubleFromValue(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime _dateTimeFromValue(Object? value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }
}
