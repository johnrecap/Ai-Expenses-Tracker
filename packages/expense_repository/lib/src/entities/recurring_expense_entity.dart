import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/entities.dart';
import 'package:expense_repository/src/models/models.dart';

class RecurringExpenseEntity {
  final String recurringExpenseId;
  final String userId;
  final double amount;
  final Category category;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final String description;
  final PaymentMethod paymentMethod;
  final String currency;
  final DateTime startDate;
  final DateTime nextRunDate;
  final DateTime? endDate;
  final RecurringFrequency frequency;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurringExpenseEntity({
    required this.recurringExpenseId,
    required this.userId,
    required num amount,
    required this.category,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.description,
    required this.paymentMethod,
    required this.currency,
    required this.startDate,
    required this.nextRunDate,
    this.endDate,
    required this.frequency,
    required this.isActive,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  }) : amount = amount.toDouble();

  Map<String, Object?> toDocument() {
    return {
      'recurringExpenseId': recurringExpenseId,
      'userId': userId,
      'amount': amount,
      'category': category.toEntity().toDocument(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'description': description,
      'paymentMethod': paymentMethod.storageValue,
      'currency': currency,
      'startDate': startDate,
      'nextRunDate': nextRunDate,
      'endDate': endDate,
      'frequency': frequency.storageValue,
      'isActive': isActive,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static RecurringExpenseEntity fromDocument(Map<String, Object?> doc) {
    final legacyCategory = _categoryFromDocument(doc);
    final categoryId =
        (doc['categoryId'] as String?) ?? legacyCategory.categoryId;
    final categoryName =
        (doc['categoryName'] as String?) ?? legacyCategory.name;
    final categoryIcon =
        (doc['categoryIcon'] as String?) ?? legacyCategory.icon;
    final categoryColor =
        _intFromValue(doc['categoryColor']) ?? legacyCategory.color;
    final category = Category(
      categoryId: categoryId,
      userId: doc['userId'] as String? ?? '',
      name: categoryName,
      totalExpenses: legacyCategory.totalExpenses,
      icon: categoryIcon,
      color: categoryColor,
      isArchived: legacyCategory.isArchived,
      createdAt: legacyCategory.createdAt,
      updatedAt: legacyCategory.updatedAt,
    );
    final startDate = _dateFromValue(doc['startDate']) ?? DateTime.now();
    final nextRunDate = _dateFromValue(doc['nextRunDate']) ?? startDate;
    final createdAt = _dateFromValue(doc['createdAt']) ?? DateTime.now();

    return RecurringExpenseEntity(
      recurringExpenseId: doc['recurringExpenseId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      amount: _doubleFromValue(doc['amount']) ?? 0,
      category: category,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      description: doc['description'] as String? ?? '',
      paymentMethod:
          PaymentMethod.fromStorageValue(doc['paymentMethod'] as String?),
      currency: doc['currency'] as String? ?? 'EGP',
      startDate: startDate,
      nextRunDate: nextRunDate,
      endDate: _dateFromValue(doc['endDate']),
      frequency:
          RecurringFrequency.fromStorageValue(doc['frequency'] as String?),
      isActive: doc['isActive'] as bool? ?? true,
      isArchived: doc['isArchived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateFromValue(doc['updatedAt']) ?? createdAt,
    );
  }

  static Category _categoryFromDocument(Map<String, Object?> doc) {
    final categoryDoc = doc['category'];
    if (categoryDoc is Map<String, dynamic>) {
      return Category.fromEntity(CategoryEntity.fromDocument(categoryDoc));
    }
    if (categoryDoc is Map) {
      return Category.fromEntity(
        CategoryEntity.fromDocument(Map<String, dynamic>.from(categoryDoc)),
      );
    }
    return Category.empty;
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

  static double? _doubleFromValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }
}
