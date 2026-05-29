import 'package:expense_repository/expense_repository.dart';
import 'package:uuid/uuid.dart';

import 'ai_category_resolution.dart';
import 'ai_expense_payload.dart';

class AiActionPreview {
  const AiActionPreview({
    required this.amount,
    required this.category,
    required this.categoryName,
    required this.date,
    required this.paymentMethod,
    required this.currency,
    required this.description,
    required this.confidence,
    this.merchant,
    this.tags = const [],
    this.categoryResolution,
    this.validationErrors = const [],
  });

  final double amount;
  final Category? category;
  final String categoryName;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String currency;
  final String description;
  final double confidence;
  final String? merchant;
  final List<String> tags;
  final AiCategoryResolution? categoryResolution;
  final List<String> validationErrors;

  factory AiActionPreview.fromPayload(
    AiExpensePayload payload, {
    required List<Category> categories,
    required String defaultCurrency,
    PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
    double confidence = 1,
  }) {
    final matchedCategory = _matchCategory(
      categories,
      payload.categoryId,
      payload.categoryName,
    );
    final categoryName = matchedCategory?.name ?? payload.categoryName ?? '';
    final preview = AiActionPreview(
      amount: payload.amount ?? 0,
      category: matchedCategory,
      categoryName: categoryName,
      date: payload.date ?? DateTime.now(),
      paymentMethod: payload.paymentMethod ?? defaultPaymentMethod,
      currency: (payload.currency?.trim().isNotEmpty ?? false)
          ? payload.currency!.trim().toUpperCase()
          : defaultCurrency,
      description: payload.description?.trim().isNotEmpty == true
          ? payload.description!.trim()
          : 'AI expense',
      confidence: confidence,
      merchant: payload.merchant,
      tags: payload.tags,
      categoryResolution: payload.categoryResolution,
    );
    return preview.copyWith(validationErrors: preview.validate());
  }

  AiActionPreview copyWith({
    num? amount,
    Category? category,
    bool clearCategory = false,
    String? categoryName,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? currency,
    String? description,
    double? confidence,
    String? merchant,
    bool clearMerchant = false,
    List<String>? tags,
    AiCategoryResolution? categoryResolution,
    bool clearCategoryResolution = false,
    List<String>? validationErrors,
  }) {
    return AiActionPreview(
      amount: amount?.toDouble() ?? this.amount,
      category: clearCategory ? null : category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      merchant: clearMerchant ? null : merchant ?? this.merchant,
      tags: tags ?? this.tags,
      categoryResolution: clearCategoryResolution
          ? null
          : categoryResolution ?? this.categoryResolution,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (amount <= 0) errors.add('Enter a valid amount.');
    if (category == null &&
        (categoryResolution?.suggestedCategory == null ||
            categoryName.trim().isEmpty)) {
      errors.add('Select a category.');
    }
    if (currency.trim().isEmpty) errors.add('Select a currency.');
    return errors;
  }

  Expense toExpense({required String userId}) {
    final selectedCategory = category ??
        Category(
          categoryId: '',
          userId: userId,
          name: categoryName.trim(),
          totalExpenses: 0,
          icon: '',
          color: 0,
        );
    final now = DateTime.now();
    return Expense(
      expenseId: const Uuid().v1(),
      userId: userId,
      category: selectedCategory,
      date: date,
      amount: amount,
      description: description.trim(),
      merchant: merchant?.trim() ?? '',
      tags: tags,
      paymentMethod: paymentMethod,
      currency: currency.trim().toUpperCase(),
      createdAt: now,
      updatedAt: now,
      source: ExpenseSource.ai,
    );
  }

  static Category? _matchCategory(
    List<Category> categories,
    String? categoryId,
    String? categoryName,
  ) {
    if (categoryId?.isNotEmpty == true) {
      for (final category in categories) {
        if (category.categoryId == categoryId) return category;
      }
    }
    final normalizedName = _normalizeCategoryName(categoryName);
    if (normalizedName.isEmpty) return null;
    for (final category in categories) {
      if (_normalizeCategoryName(category.name) == normalizedName) {
        return category;
      }
    }
    return null;
  }

  static String _normalizeCategoryName(String? value) {
    final text = value?.trim().toLowerCase() ?? '';
    switch (text) {
      case 'food':
      case 'اكل':
      case 'أكل':
      case 'طعام':
        return 'food';
      case 'transport':
      case 'transportation':
      case 'مواصلات':
      case 'المواصلات':
      case 'اوبر':
      case 'أوبر':
      case 'تاكسي':
        return 'transport';
      case 'shopping':
      case 'تسوق':
        return 'shopping';
      case 'bills':
      case 'فواتير':
        return 'bills';
      case 'entertainment':
      case 'ترفيه':
        return 'entertainment';
      default:
        return text;
    }
  }
}
