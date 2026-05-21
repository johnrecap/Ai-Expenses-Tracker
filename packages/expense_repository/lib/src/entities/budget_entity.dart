import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetEntity {
  final String budgetId;
  final String userId;
  final int month;
  final int year;
  final double amount;
  final String currency;
  final int warningThresholdPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.budgetId,
    required this.userId,
    required this.month,
    required this.year,
    required this.amount,
    required this.currency,
    required this.warningThresholdPercent,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'budgetId': budgetId,
      'userId': userId,
      'month': _validMonth(month),
      'year': year,
      'amount': amount,
      'currency': currency,
      'warningThresholdPercent': warningThresholdPercent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static BudgetEntity fromDocument(Map<String, Object?> doc) {
    final month = _intFromValue(doc['month']) ?? 1;
    final year = _intFromValue(doc['year']) ?? DateTime.now().year;
    return BudgetEntity(
      budgetId: doc['budgetId'] as String? ??
          '$year-${_validMonth(month).toString().padLeft(2, '0')}',
      userId: doc['userId'] as String? ?? '',
      month: _validMonth(month),
      year: year,
      amount: _doubleFromValue(doc['amount']) ?? 0,
      currency: doc['currency'] as String? ?? 'EGP',
      warningThresholdPercent:
          _intFromValue(doc['warningThresholdPercent']) ?? 80,
      createdAt: _dateTimeFromValue(doc['createdAt']),
      updatedAt: _dateTimeFromValue(doc['updatedAt']),
    );
  }

  static int _validMonth(int month) {
    if (month < 1 || month > 12) return 1;
    return month;
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

  static DateTime _dateTimeFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
