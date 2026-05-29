import 'dart:convert';

import 'package:expenses_tracker/utils/amount_parser.dart';

import '../models/ai_response.dart';
import 'ai_response_parser.dart';
import 'ai_service.dart';

class MockAiService implements AiService {
  const MockAiService();

  @override
  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    final text = input.trim();
    if (text.isEmpty) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'unknown',
          'confidence': 0.2,
          'needsConfirmation': true,
          'clarifyingQuestion': 'Please describe the expense.',
        }),
        now: context.now,
      );
    }

    final commandResponse = _tryParseCommand(text, context);
    if (commandResponse != null) return commandResponse;

    final amount = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(text)?.group(0);
    final category = _detectCategory(text);
    final paymentMethod =
        _detectPaymentMethod(text) ?? context.defaultPaymentMethod.label;
    final currency = _detectCurrency(text, context.defaultCurrency);
    final date = _detectDate(text, context.now);
    final merchant = _detectMerchant(text);
    final tags = _detectTags(text, category);
    final confidence = amount != null && category != null ? 0.92 : 0.55;
    final missing = [
      if (amount == null) 'amount',
      if (category == null) 'category',
    ];

    return AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': amount == null ? null : _parseAmount(amount),
        'category': category,
        'date': _formatDate(date),
        'paymentMethod': paymentMethod,
        'currency': currency,
        'description': category == null ? text : 'AI $category expense',
        'merchant': merchant,
        'tags': tags,
        'missingFields': missing,
        'confidence': confidence,
        'needsConfirmation': true,
        if (confidence < 0.75)
          'clarifyingQuestion': _clarifyingQuestion(missing),
      }),
      now: context.now,
    );
  }

  AiResponse? _tryParseCommand(String text, AiContext context) {
    final lower = text.toLowerCase();
    final amount = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(text)?.group(0);
    final category = _detectCategory(text);
    final paymentMethod = _detectPaymentMethod(text);
    final currency = _detectCurrency(text, context.defaultCurrency);
    final date = _detectDate(text, context.now);
    final periodText = _detectPeriodText(text);

    if (_containsAny(lower, ['show', 'search', 'find', 'وريني', 'اعرض'])) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'search_expenses',
          'query': text,
          'categoryNames': category == null ? <String>[] : [category],
          'paymentMethods':
              paymentMethod == null ? <String>[] : [paymentMethod],
          'currency': currency,
          'periodText': periodText,
          'confidence': 0.9,
          'needsConfirmation': false,
        }),
        now: context.now,
      );
    }

    if (_containsAny(lower, ['summary', 'summarize', 'لخص', 'ملخص'])) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'summarize_expenses',
          'period': periodText == 'this week' ? 'weekly' : 'monthly',
          'currency': currency,
          'periodText': periodText,
          'confidence': 0.9,
          'needsConfirmation': false,
        }),
        now: context.now,
      );
    }

    if (_containsAny(lower, ['advice', 'نصيحة', 'انصحني'])) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'financial_advice',
          'period': periodText == 'this week' ? 'weekly' : 'monthly',
          'currency': currency,
          'focusCategory': category,
          'confidence': 0.88,
          'needsConfirmation': false,
        }),
        now: context.now,
      );
    }

    if (_containsAny(lower, ['delete', 'remove', 'احذف', 'امسح'])) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'delete_expense',
          'query': text,
          'description': _targetText(text),
          'amount': amount == null ? null : _parseAmount(amount),
          'category': category,
          'date': _mentionsLast(text) ? null : _formatDate(date),
          'paymentMethod': paymentMethod,
          'currency': currency,
          'confidence': 0.86,
          'needsConfirmation': true,
        }),
        now: context.now,
      );
    }

    if (_containsAny(lower, ['update', 'change', 'غير', 'عدل'])) {
      return AiResponseParser.parse(
        jsonEncode({
          'intent': 'update_expense',
          'query': text,
          'description': _targetText(text),
          'amount': amount == null ? null : _parseAmount(amount),
          'category': category,
          'date': null,
          'paymentMethod': paymentMethod,
          'currency': currency,
          'confidence': 0.86,
          'needsConfirmation': true,
        }),
        now: context.now,
      );
    }

    return null;
  }

  String? _detectCategory(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['food', 'اكل', 'أكل', 'مطعم', 'مطاعم'])) {
      return 'Food';
    }
    if (_containsAny(lower, ['transport', 'uber', 'اوبر', 'أوبر', 'مواصلات'])) {
      return 'Transport';
    }
    if (_containsAny(lower, ['shopping', 'تسوق', 'شراء'])) {
      return 'Shopping';
    }
    if (_containsAny(lower, ['bills', 'bill', 'فاتورة', 'فواتير'])) {
      return 'Bills';
    }
    if (_containsAny(lower, ['entertainment', 'ترفيه', 'سينما'])) {
      return 'Entertainment';
    }
    return null;
  }

  String? _detectPaymentMethod(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['cash', 'كاش', 'نقدي'])) return 'Cash';
    if (_containsAny(lower, ['visa', 'card', 'فيزا'])) return 'Visa';
    if (_containsAny(lower, ['wallet', 'محفظة'])) return 'Wallet';
    if (_containsAny(lower, ['bank transfer', 'تحويل بنكي'])) {
      return 'Bank Transfer';
    }
    return null;
  }

  String? _detectMerchant(String text) {
    final match = RegExp(
      r'(?:at|from|@|عند)\s+([^,.;،؛!?؟#]{2,40})',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  List<String> _detectTags(String text, String? category) {
    final tags = <String>[
      if (category != null) category.toLowerCase(),
    ];
    final hashtagMatches = RegExp(r'#([^\s#,.;،؛!?؟]+)')
        .allMatches(text)
        .map((match) => match.group(1)?.trim())
        .whereType<String>();
    for (final tag in hashtagMatches) {
      if (!tags.contains(tag.toLowerCase())) tags.add(tag);
    }
    return tags;
  }

  String _detectCurrency(String text, String fallback) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['egp', 'جنيه'])) return 'EGP';
    if (_containsAny(lower, ['usd', 'dollar', 'dollars', 'دولار'])) {
      return 'USD';
    }
    return fallback;
  }

  DateTime _detectDate(String text, DateTime now) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['yesterday', 'last night', 'امبارح', 'أمس'])) {
      return DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
    }
    return DateTime(now.year, now.month, now.day);
  }

  String? _detectPeriodText(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['week', 'اسبوع', 'أسبوع'])) return 'this week';
    if (_containsAny(lower, ['month', 'شهر'])) return 'this month';
    return null;
  }

  bool _mentionsLast(String text) {
    final lower = text.toLowerCase();
    return _containsAny(lower, ['last', 'اخر', 'آخر']);
  }

  String _targetText(String text) {
    return text.replaceAll(RegExp(r'\d+(?:[.,]\d+)?'), '').trim();
  }

  double? _parseAmount(String amount) {
    return parseAmountInput(amount);
  }

  bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }

  String _clarifyingQuestion(List<String> missing) {
    if (missing.length == 1) {
      return 'I need the ${missing.single} before preparing the preview.';
    }
    return 'I need the ${missing.join(' and ')} before preparing the preview.';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
