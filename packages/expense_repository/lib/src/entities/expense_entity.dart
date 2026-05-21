import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/entities.dart';

import '../models/models.dart';

class ExpenseEntity {
  String expenseId;
  String userId;
  Category category;
  String categoryId;
  String categoryName;
  String categoryIcon;
  int categoryColor;
  DateTime date;
  double amount;
  String description;
  String? merchant;
  List<String> tags;
  PaymentMethod paymentMethod;
  String currency;
  DateTime createdAt;
  DateTime updatedAt;
  ExpenseSource source;
  String? walletAccountId;
  String? walletAccountName;
  String? recurringExpenseId;
  String? aiActionId;

  ExpenseEntity({
    required this.expenseId,
    required this.userId,
    required this.category,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    required num amount,
    required this.description,
    String? merchant,
    List<String> tags = const [],
    required this.paymentMethod,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    this.walletAccountId,
    this.walletAccountName,
    this.recurringExpenseId,
    this.aiActionId,
  })  : amount = amount.toDouble(),
        merchant = _normalizeMerchant(merchant),
        tags = _normalizeTags(tags);

  Map<String, Object?> toDocument() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'category': category.toEntity().toDocument(),
      'date': date,
      'amount': amount,
      'description': description,
      'merchant': merchant,
      'tags': tags,
      'paymentMethod': paymentMethod.storageValue,
      'currency': currency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'source': source.value,
      'walletAccountId': walletAccountId,
      'walletAccountName': walletAccountName,
      'recurringExpenseId': recurringExpenseId,
      'aiActionId': aiActionId,
    };
  }

  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    final legacyCategory = _categoryFromDocument(doc);
    final date = _dateFromValue(doc['date']) ?? DateTime.now();
    final createdAt = _dateFromValue(doc['createdAt']) ?? date;
    final updatedAt = _dateFromValue(doc['updatedAt']) ?? createdAt;
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
      name: categoryName,
      totalExpenses: legacyCategory.totalExpenses,
      icon: categoryIcon,
      color: categoryColor,
    );

    return ExpenseEntity(
      expenseId: doc['expenseId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      category: category,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      date: date,
      amount: _doubleFromValue(doc['amount']) ?? 0,
      description: doc['description'] as String? ?? '',
      merchant: doc['merchant'] as String?,
      tags: _tagsFromValue(doc['tags']),
      paymentMethod:
          PaymentMethod.fromStorageValue(doc['paymentMethod'] as String?),
      currency: doc['currency'] as String? ?? 'EGP',
      createdAt: createdAt,
      updatedAt: updatedAt,
      source: expenseSourceFromString(doc['source'] as String?),
      walletAccountId: doc['walletAccountId'] as String?,
      walletAccountName: doc['walletAccountName'] as String?,
      recurringExpenseId: doc['recurringExpenseId'] as String?,
      aiActionId: doc['aiActionId'] as String?,
    );
  }

  static Category _categoryFromDocument(Map<String, dynamic> doc) {
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

  static String? _normalizeMerchant(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _normalizeTags(List<String> values) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final value in values) {
      final tag = value.trim();
      if (tag.isEmpty) continue;
      final key = tag.toLowerCase();
      if (seen.add(key)) normalized.add(tag);
    }
    return List.unmodifiable(normalized);
  }

  static List<String> _tagsFromValue(Object? value) {
    if (value is! List) return const [];
    return _normalizeTags(value.whereType<String>().toList());
  }
}
