import 'package:expense_repository/expense_repository.dart';

class CategoryBudget {
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

  const CategoryBudget({
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

  static final empty = CategoryBudget(
    categoryBudgetId: '',
    userId: '',
    categoryId: '',
    categoryName: '',
    month: monthKeyFor(DateTime.now()),
    currency: 'EGP',
    limitAmount: 0,
    warningThresholdPercent: 80,
    isArchived: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  static String monthKeyFor(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  static String categoryBudgetIdFor({
    required String month,
    required String categoryId,
    required String currency,
  }) {
    return '${month}_${categoryId}_${currency.trim().toUpperCase()}';
  }

  bool get hasValidLimit => limitAmount > 0;

  CategoryBudget copyWith({
    String? categoryBudgetId,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? month,
    String? currency,
    double? limitAmount,
    int? warningThresholdPercent,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryBudget(
      categoryBudgetId: categoryBudgetId ?? this.categoryBudgetId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      month: month ?? this.month,
      currency: currency ?? this.currency,
      limitAmount: limitAmount ?? this.limitAmount,
      warningThresholdPercent:
          warningThresholdPercent ?? this.warningThresholdPercent,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CategoryBudgetEntity toEntity() {
    return CategoryBudgetEntity(
      categoryBudgetId: categoryBudgetId,
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      month: month,
      currency: currency,
      limitAmount: limitAmount,
      warningThresholdPercent: warningThresholdPercent,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CategoryBudget fromEntity(CategoryBudgetEntity entity) {
    return CategoryBudget(
      categoryBudgetId: entity.categoryBudgetId,
      userId: entity.userId,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      month: entity.month,
      currency: entity.currency,
      limitAmount: entity.limitAmount,
      warningThresholdPercent: entity.warningThresholdPercent,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
