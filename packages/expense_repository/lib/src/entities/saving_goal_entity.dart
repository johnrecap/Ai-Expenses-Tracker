import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoalEntity {
  final String goalId;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoalEntity({
    required this.goalId,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.deadline,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'goalId': goalId,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'deadline': deadline,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static SavingGoalEntity fromDocument(Map<String, Object?> doc) {
    final now = DateTime.now();
    final createdAt = _dateFromValue(doc['createdAt']) ?? now;

    return SavingGoalEntity(
      goalId: doc['goalId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      name: doc['name'] as String? ?? '',
      targetAmount: _doubleFromValue(doc['targetAmount']) ?? 0,
      currentAmount: _doubleFromValue(doc['currentAmount']) ?? 0,
      currency: doc['currency'] as String? ?? 'EGP',
      deadline: _dateFromValue(doc['deadline']),
      isArchived: doc['isArchived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateFromValue(doc['updatedAt']) ?? createdAt,
    );
  }

  static double? _doubleFromValue(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
