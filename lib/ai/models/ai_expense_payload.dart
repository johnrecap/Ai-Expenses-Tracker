import 'package:expense_repository/expense_repository.dart';

import 'ai_category_resolution.dart';

class AiExpensePayload {
  const AiExpensePayload({
    this.amount,
    this.categoryId,
    this.categoryName,
    this.date,
    this.paymentMethod,
    this.currency,
    this.description,
    this.categoryResolution,
  });

  final double? amount;
  final String? categoryId;
  final String? categoryName;
  final DateTime? date;
  final PaymentMethod? paymentMethod;
  final String? currency;
  final String? description;
  final AiCategoryResolution? categoryResolution;

  bool get hasRequiredAddExpenseFields {
    return amount != null &&
        amount! > 0 &&
        date != null &&
        (categoryId?.isNotEmpty == true || categoryName?.isNotEmpty == true);
  }

  AiExpensePayload copyWith({
    num? amount,
    String? categoryId,
    bool clearCategoryId = false,
    String? categoryName,
    bool clearCategoryName = false,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? currency,
    String? description,
    AiCategoryResolution? categoryResolution,
    bool clearCategoryResolution = false,
  }) {
    return AiExpensePayload(
      amount: amount?.toDouble() ?? this.amount,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      categoryName:
          clearCategoryName ? null : categoryName ?? this.categoryName,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      categoryResolution: clearCategoryResolution
          ? null
          : categoryResolution ?? this.categoryResolution,
    );
  }
}
