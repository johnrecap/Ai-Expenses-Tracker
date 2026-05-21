import 'package:expense_repository/expense_repository.dart';

enum RecurringFrequency {
  daily,
  weekly,
  monthly;

  String get storageValue {
    switch (this) {
      case RecurringFrequency.daily:
        return 'daily';
      case RecurringFrequency.weekly:
        return 'weekly';
      case RecurringFrequency.monthly:
        return 'monthly';
    }
  }

  String get label {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
    }
  }

  static RecurringFrequency fromStorageValue(String? value) {
    switch (value) {
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'monthly':
        return RecurringFrequency.monthly;
      case 'daily':
      default:
        return RecurringFrequency.daily;
    }
  }
}

class RecurringExpense {
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

  RecurringExpense({
    required this.recurringExpenseId,
    String? userId,
    required num amount,
    required this.category,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? description,
    PaymentMethod? paymentMethod,
    String? currency,
    required this.startDate,
    DateTime? nextRunDate,
    this.endDate,
    required this.frequency,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : userId = userId ?? '',
        amount = amount.toDouble(),
        categoryId = categoryId ?? category.categoryId,
        categoryName = categoryName ?? category.name,
        categoryIcon = categoryIcon ?? category.icon,
        categoryColor = categoryColor ?? category.color,
        description = description ?? '',
        paymentMethod = paymentMethod ?? PaymentMethod.cash,
        currency = currency ?? 'EGP',
        nextRunDate = nextRunDate ?? startDate,
        isActive = isActive ?? true,
        isArchived = isArchived ?? false,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  static final empty = RecurringExpense(
    recurringExpenseId: '',
    userId: '',
    amount: 0,
    category: Category.empty,
    description: '',
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    nextRunDate: DateTime.fromMillisecondsSinceEpoch(0),
    frequency: RecurringFrequency.monthly,
    isActive: true,
    isArchived: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  RecurringExpense copyWith({
    String? recurringExpenseId,
    String? userId,
    num? amount,
    Category? category,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? description,
    PaymentMethod? paymentMethod,
    String? currency,
    DateTime? startDate,
    DateTime? nextRunDate,
    DateTime? endDate,
    bool clearEndDate = false,
    RecurringFrequency? frequency,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextCategory = category ?? this.category;
    return RecurringExpense(
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: nextCategory,
      categoryId: categoryId ?? nextCategory.categoryId,
      categoryName: categoryName ?? nextCategory.name,
      categoryIcon: categoryIcon ?? nextCategory.icon,
      categoryColor: categoryColor ?? nextCategory.color,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  RecurringExpenseEntity toEntity() {
    return RecurringExpenseEntity(
      recurringExpenseId: recurringExpenseId,
      userId: userId,
      amount: amount,
      category: category,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      description: description,
      paymentMethod: paymentMethod,
      currency: currency,
      startDate: startDate,
      nextRunDate: nextRunDate,
      endDate: endDate,
      frequency: frequency,
      isActive: isActive,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static RecurringExpense fromEntity(RecurringExpenseEntity entity) {
    return RecurringExpense(
      recurringExpenseId: entity.recurringExpenseId,
      userId: entity.userId,
      amount: entity.amount,
      category: entity.category,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      description: entity.description,
      paymentMethod: entity.paymentMethod,
      currency: entity.currency,
      startDate: entity.startDate,
      nextRunDate: entity.nextRunDate,
      endDate: entity.endDate,
      frequency: entity.frequency,
      isActive: entity.isActive,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
