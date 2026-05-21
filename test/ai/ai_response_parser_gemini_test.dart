import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Gemini-style Arabic add expense JSON', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 250,
        'category': 'Food',
        'categoryId': 'food',
        'date': '2026-05-15',
        'paymentMethod': 'Cash',
        'currency': 'EGP',
        'description': 'Food expense',
        'confidence': 0.92,
        'needsConfirmation': true,
      }),
      now: DateTime(2026, 5, 16),
    );

    expect(response.intent, AiIntent.addExpense);
    expect(response.expensePayload?.amount, 250);
    expect(response.expensePayload?.categoryName, 'Food');
    expect(response.expensePayload?.categoryId, 'food');
    expect(response.expensePayload?.date, DateTime(2026, 5, 15));
    expect(response.expensePayload?.paymentMethod, PaymentMethod.cash);
    expect(response.expensePayload?.currency, 'EGP');
    expect(response.needsConfirmation, isTrue);
  });

  test('rejects prose or markdown instead of JSON object', () {
    expect(
      () => AiResponseParser.parse('```json\n{"intent":"add_expense"}\n```'),
      throwsA(isA<AiResponseParserException>()),
    );
  });

  test('low-confidence incomplete add expense remains draftable', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 120,
        'confidence': 0.4,
        'needsConfirmation': true,
        'clarifyingQuestion': 'Which category should I use?',
      }),
      now: DateTime(2026, 5, 16),
    );

    expect(response.requiresClarification, isFalse);
    expect(response.clarifyingQuestion, 'Which category should I use?');
  });

  test('high-confidence add expense may omit category for resolver', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 100,
        'date': '2026-05-16',
        'paymentMethod': 'Cash',
        'currency': 'EGP',
        'description': 'Transport expense',
        'confidence': 0.9,
        'needsConfirmation': true,
      }),
      now: DateTime(2026, 5, 17),
    );

    expect(response.intent, AiIntent.addExpense);
    expect(response.expensePayload?.categoryId, isNull);
    expect(response.expensePayload?.categoryName, isNull);
    expect(response.requiresClarification, isFalse);
  });

  test('parses category resolution metadata', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 200,
        'category': 'Subscriptions',
        'date': '2026-05-16',
        'paymentMethod': 'Cash',
        'currency': 'EGP',
        'confidence': 0.9,
        'needsConfirmation': true,
        'categoryConfidence': 0.66,
        'categoryReason': 'Netflix looks like a subscription.',
        'suggestedCategoryName': 'Subscriptions',
        'suggestedCategoryIcon': 'subscriptions',
        'suggestedCategoryColor': '#5C6BC0',
      }),
      now: DateTime(2026, 5, 17),
    );

    final resolution = response.expensePayload?.categoryResolution;
    expect(resolution?.suggestedCategory?.name, 'Subscriptions');
    expect(resolution?.suggestedCategory?.color, 0xFF5C6BC0);
    expect(resolution?.reason, contains('Netflix'));
  });

  test('parses Arabic date payment and currency aliases', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': '100 جنيه',
        'category': 'Transport',
        'date': 'امبارح',
        'paymentMethod': 'كاش',
        'currency': 'جنيه',
        'confidence': 0.9,
        'needsConfirmation': true,
      }),
      now: DateTime(2026, 5, 17),
    );

    expect(response.expensePayload?.amount, 100);
    expect(response.expensePayload?.date, DateTime(2026, 5, 16));
    expect(response.expensePayload?.paymentMethod, PaymentMethod.cash);
    expect(response.expensePayload?.currency, 'EGP');
  });

  test('maps explicit English dollar currency to USD', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 20,
        'category': 'Food',
        'date': '2026-05-16',
        'paymentMethod': 'Cash',
        'currency': 'dollars',
        'confidence': 0.9,
        'needsConfirmation': true,
      }),
      now: DateTime(2026, 5, 17),
    );

    expect(response.expensePayload?.currency, 'USD');
  });

  test('rejects unsafe explicit currency text', () {
    final response = AiResponseParser.parse(
      jsonEncode({
        'intent': 'add_expense',
        'amount': 20,
        'category': 'Food',
        'date': '2026-05-16',
        'paymentMethod': 'Cash',
        'currency': 'not a currency',
        'confidence': 0.9,
        'needsConfirmation': true,
      }),
      now: DateTime(2026, 5, 17),
    );

    expect(response.expensePayload?.currency, isNull);
  });
}
