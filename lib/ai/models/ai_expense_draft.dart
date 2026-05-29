import 'package:expense_repository/expense_repository.dart';

import 'ai_action_preview.dart';
import 'ai_category_resolution.dart';
import 'ai_expense_payload.dart';

class AiExpenseDraft {
  const AiExpenseDraft({
    this.amount,
    this.categoryId,
    this.categoryName,
    this.date,
    this.paymentMethod,
    this.currency,
    this.description,
    this.merchant,
    this.tags = const [],
    this.confidence = 0,
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
  final double confidence;
  final List<String> missingFields;
  final AiCategoryResolution? categoryResolution;

  AiCategorySuggestion? get suggestedCategory =>
      categoryResolution?.suggestedCategory;

  bool get needsReview => missingFields.isNotEmpty ||
      amount == null ||
      date == null ||
      paymentMethod == null ||
      currency == null ||
      ((categoryId?.trim().isEmpty ?? true) &&
          (categoryName?.trim().isEmpty ?? true));

  factory AiExpenseDraft.fromPayload(
    AiExpensePayload payload, {
    required double confidence,
  }) {
    return AiExpenseDraft(
      amount: payload.amount,
      categoryId: payload.categoryId,
      categoryName: payload.categoryName,
      date: payload.date,
      paymentMethod: payload.paymentMethod,
      currency: payload.currency,
      description: payload.description,
      merchant: payload.merchant,
      tags: payload.tags,
      confidence: confidence,
      missingFields: payload.missingFields.isEmpty
          ? _inferMissingFields(payload)
          : payload.missingFields,
      categoryResolution: payload.categoryResolution,
    );
  }

  factory AiExpenseDraft.fromPreview(AiActionPreview preview) {
    return AiExpenseDraft(
      amount: preview.amount > 0 ? preview.amount : null,
      categoryId: preview.category?.categoryId,
      categoryName: preview.category?.name ?? preview.categoryName,
      date: preview.date,
      paymentMethod: preview.paymentMethod,
      currency: preview.currency,
      description: preview.description,
      merchant: preview.merchant,
      tags: preview.tags,
      confidence: preview.confidence,
      missingFields: preview.validationErrors,
      categoryResolution: preview.categoryResolution,
    );
  }

  static List<String> _inferMissingFields(AiExpensePayload payload) {
    return [
      if (payload.amount == null || payload.amount! <= 0) 'amount',
      if ((payload.categoryId?.trim().isEmpty ?? true) &&
          (payload.categoryName?.trim().isEmpty ?? true))
        'category',
      if (payload.date == null) 'date',
      if (payload.paymentMethod == null) 'payment method',
      if (payload.currency?.trim().isEmpty ?? true) 'currency',
    ];
  }
}
