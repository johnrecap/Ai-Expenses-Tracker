import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';

import '../models/ai_category_resolution.dart';
import '../models/ai_expense_payload.dart';
import '../models/ai_intent.dart';
import '../models/ai_response.dart';
import '../models/ai_advice_payload.dart';
import '../models/ai_search_payload.dart';
import '../models/ai_summary_payload.dart';

class AiResponseParserException implements Exception {
  const AiResponseParserException(this.message);

  final String message;

  @override
  String toString() => 'AiResponseParserException: $message';
}

class AiResponseParser {
  static AiResponse parse(
    String output, {
    DateTime? now,
    double confidenceThreshold = 0.75,
  }) {
    final decoded = _decodeObject(output);
    final intent = AiIntent.fromJsonValue(decoded['intent'] as String?);
    final confidence = _readConfidence(decoded['confidence']);
    final needsConfirmation = decoded['needsConfirmation'] != false;
    final payload = intent == AiIntent.addExpense
        ? _parseExpensePayload(decoded, now: now ?? DateTime.now())
        : intent == AiIntent.updateExpense || intent == AiIntent.deleteExpense
            ? _parseCommandExpensePayload(decoded, now: now ?? DateTime.now())
            : null;
    final searchPayload = intent == AiIntent.searchExpenses
        ? AiSearchPayload.fromJson(decoded)
        : null;
    final summaryPayload = intent == AiIntent.summarizeExpenses
        ? _parseSummaryPayload(decoded)
        : null;
    final advicePayload = intent == AiIntent.financialAdvice
        ? _parseAdvicePayload(decoded)
        : null;

    return AiResponse(
      intent: intent,
      expensePayload: payload,
      searchPayload: searchPayload,
      summaryPayload: summaryPayload,
      advicePayload: advicePayload,
      confidence: confidence,
      needsConfirmation: needsConfirmation,
      clarifyingQuestion: decoded['clarifyingQuestion'] as String?,
      rawJson: output,
    );
  }

  static Map<String, dynamic> _decodeObject(String output) {
    dynamic decoded;
    try {
      decoded = jsonDecode(output);
    } catch (_) {
      throw const AiResponseParserException(
        'AI output must be a valid JSON object.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AiResponseParserException(
        'AI output must be a JSON object.',
      );
    }
    return decoded;
  }

  static double _readConfidence(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    throw const AiResponseParserException('Confidence is required.');
  }

  static AiExpensePayload _parseExpensePayload(
    Map<String, dynamic> json, {
    required DateTime now,
  }) {
    final amount = _parseAmount(json['amount']);

    return AiExpensePayload(
      amount: amount,
      categoryId: _readString(json['categoryId']),
      categoryName: _readString(json['category']),
      date: _parseDate(_readString(json['date']), now: now),
      paymentMethod: _parsePaymentMethod(_readString(json['paymentMethod'])),
      currency: _parseCurrency(_readString(json['currency'])),
      description: _readString(json['description']),
      merchant: _readString(json['merchant']),
      tags: _parseTags(json['tags']),
      missingFields: _parseStringList(json['missingFields']),
      categoryResolution: _parseCategoryResolution(json),
    );
  }

  static AiExpensePayload _parseCommandExpensePayload(
    Map<String, dynamic> json, {
    required DateTime now,
  }) {
    return AiExpensePayload(
      amount: _parseAmount(json['amount']),
      categoryId: _readString(json['categoryId']),
      categoryName: _readString(json['category']),
      date: _parseDate(_readString(json['date']), now: now),
      paymentMethod: _parsePaymentMethod(_readString(json['paymentMethod'])),
      currency: _parseCurrency(_readString(json['currency'])),
      description:
          _readString(json['description']) ?? _readString(json['query']),
      merchant: _readString(json['merchant']),
      tags: _parseTags(json['tags']),
      missingFields: _parseStringList(json['missingFields']),
      categoryResolution: _parseCategoryResolution(json),
    );
  }

  static AiCategoryResolution? _parseCategoryResolution(
    Map<String, dynamic> json,
  ) {
    final categoryConfidence = _parseDouble(json['categoryConfidence']);
    final categoryReason = _readString(json['categoryReason']);
    final suggestedName = _readString(json['suggestedCategoryName']);
    final suggestedIcon = _readString(json['suggestedCategoryIcon']);
    final suggestedColor = _parseColor(json['suggestedCategoryColor']);
    final categoryId = _readString(json['categoryId']);
    final categoryName = _readString(json['category']);

    if (categoryConfidence == null &&
        categoryReason == null &&
        suggestedName == null) {
      return null;
    }

    final suggestion = suggestedName == null
        ? null
        : AiCategorySuggestion(
            name: suggestedName,
            icon: suggestedIcon ?? 'category',
            color: suggestedColor ?? 0xFF607D8B,
            reason: categoryReason ?? 'Suggested by AI response.',
          );

    return AiCategoryResolution(
      categoryId: categoryId,
      categoryName: categoryName ?? suggestedName ?? '',
      confidence: categoryConfidence ?? 0.5,
      reason: categoryReason ?? 'Category hint returned by AI.',
      source: categoryId == null
          ? AiCategoryResolutionSource.aiSuggested
          : AiCategoryResolutionSource.exactId,
      suggestedCategory: suggestion,
    );
  }

  static double? _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return parseAmountInput(value.replaceAll(RegExp(r'[^0-9.,-]'), ''));
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseColor(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final normalized = value.trim().replaceFirst('#', '');
      return int.tryParse(
        normalized.length == 6 ? 'FF$normalized' : normalized,
        radix: 16,
      );
    }
    return null;
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> _parseTags(dynamic value) {
    final rawTags = _parseStringList(value);
    final seen = <String>{};
    final tags = <String>[];
    for (final rawTag in rawTags) {
      for (final part in rawTag.split(',')) {
        final tag = part.trim();
        if (tag.isEmpty) continue;
        if (seen.add(tag.toLowerCase())) tags.add(tag);
      }
    }
    return tags;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map(_readString)
          .whereType<String>()
          .where((text) => text.trim().isNotEmpty)
          .toList(growable: false);
    }
    final text = _readString(value);
    return text == null ? const [] : [text];
  }

  static DateTime? _parseDate(String? value, {required DateTime now}) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized == 'today' ||
        normalized == 'tonight' ||
        normalized == 'النهاردة' ||
        normalized == 'النهارده' ||
        normalized == 'اليوم') {
      return DateTime(now.year, now.month, now.day);
    }
    if (normalized == 'yesterday' ||
        normalized == 'last night' ||
        normalized == 'امبارح' ||
        normalized == 'امس' ||
        normalized == 'أمس') {
      final date = now.subtract(const Duration(days: 1));
      return DateTime(date.year, date.month, date.day);
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static PaymentMethod? _parsePaymentMethod(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll('-', ' ');
    switch (normalized) {
      case 'cash':
      case 'كاش':
      case 'نقدي':
      case 'نقدا':
      case 'نقداً':
        return PaymentMethod.cash;
      case 'visa':
      case 'card':
      case 'credit card':
      case 'فيزا':
        return PaymentMethod.visa;
      case 'wallet':
      case 'محفظة':
      case 'wallets':
        return PaymentMethod.wallet;
      case 'bank transfer':
      case 'bank_transfer':
      case 'transfer':
      case 'تحويل بنكي':
        return PaymentMethod.bankTransfer;
      default:
        return null;
    }
  }

  static String? _parseCurrency(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'جنيه':
      case 'جنيه مصري':
      case 'egp':
      case 'egyptian pound':
        return 'EGP';
      case 'دولار':
      case 'dollar':
      case 'dollars':
      case 'us dollar':
      case 'us dollars':
      case 'usd':
        return 'USD';
      default:
        final currencyCode = value.trim().toUpperCase();
        return RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)
            ? currencyCode
            : null;
    }
  }

  static AiSummaryPayload _parseSummaryPayload(Map<String, dynamic> json) {
    final period = _parseReportRangeType(_readString(json['period']));
    final startDate = _parseNullableIsoDate(_readString(json['startDate']));
    final endDate = _parseNullableIsoDate(_readString(json['endDate']));
    if (period == ReportRangeType.custom &&
        startDate != null &&
        endDate != null) {
      return AiSummaryPayload.custom(
        startDate: startDate,
        endDate: endDate,
        currency: _parseCurrency(_readString(json['currency'])) ?? 'EGP',
        periodText: _readString(json['periodText']),
      );
    }
    return AiSummaryPayload(
      period: period,
      startDate: startDate,
      endDate: endDate,
      currency: _parseCurrency(_readString(json['currency'])) ?? 'EGP',
      periodText: _readString(json['periodText']),
    );
  }

  static AiAdvicePayload _parseAdvicePayload(Map<String, dynamic> json) {
    return AiAdvicePayload(
      period: _parseReportRangeType(_readString(json['period'])),
      startDate: _parseNullableIsoDate(_readString(json['startDate'])),
      endDate: _parseNullableIsoDate(_readString(json['endDate'])),
      currency: _parseCurrency(_readString(json['currency'])) ?? 'EGP',
      focusCategory: _readString(json['focusCategory']),
      tone: _readString(json['tone']),
    );
  }

  static ReportRangeType _parseReportRangeType(String? value) {
    final normalized = value?.trim().toLowerCase();
    switch (normalized) {
      case 'weekly':
      case 'week':
      case 'this_week':
        return ReportRangeType.weekly;
      case 'custom':
        return ReportRangeType.custom;
      case 'monthly':
      case 'month':
      case 'this_month':
      default:
        return ReportRangeType.monthly;
    }
  }

  static DateTime? _parseNullableIsoDate(String? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
