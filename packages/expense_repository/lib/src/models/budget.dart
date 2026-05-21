import 'package:expense_repository/expense_repository.dart';

class Budget {
  final String budgetId;
  final String userId;
  final int month;
  final int year;
  final double amount;
  final String currency;
  final int warningThresholdPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
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

  static final empty = Budget(
    budgetId: '',
    userId: '',
    month: DateTime.now().month,
    year: DateTime.now().year,
    amount: 0,
    currency: 'EGP',
    warningThresholdPercent: 80,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  static String budgetIdFor({
    required int month,
    required int year,
  }) {
    final normalizedMonth = month.clamp(1, 12).toString().padLeft(2, '0');
    return '$year-$normalizedMonth';
  }

  Budget copyWith({
    String? budgetId,
    String? userId,
    int? month,
    int? year,
    double? amount,
    String? currency,
    int? warningThresholdPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      warningThresholdPercent:
          warningThresholdPercent ?? this.warningThresholdPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  BudgetEntity toEntity() {
    return BudgetEntity(
      budgetId: budgetId,
      userId: userId,
      month: month,
      year: year,
      amount: amount,
      currency: currency,
      warningThresholdPercent: warningThresholdPercent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Budget fromEntity(BudgetEntity entity) {
    return Budget(
      budgetId: entity.budgetId,
      userId: entity.userId,
      month: entity.month,
      year: entity.year,
      amount: entity.amount,
      currency: entity.currency,
      warningThresholdPercent: entity.warningThresholdPercent,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
