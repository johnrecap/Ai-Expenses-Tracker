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
    this.merchant,
    this.tags = const [],
    this.missingFields = const [],
    this.categoryResolution,
  });

  final double? amount;
  final String? categoryId;
  final String? categoryName;
  final DateTime? date;
  final PaymentMethod? paymentMethod;
  final String? currency;
  final String? description;
  final String? merchant;
  final List<String> tags;
  final List<String> missingFields;
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
    String? merchant,
    bool clearMerchant = false,
    List<String>? tags,
    List<String>? missingFields,
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
      merchant: clearMerchant ? null : merchant ?? this.merchant,
      tags: tags ?? this.tags,
      missingFields: missingFields ?? this.missingFields,
      categoryResolution: clearCategoryResolution
          ? null
          : categoryResolution ?? this.categoryResolution,
    );
  }
}
