import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_intent.dart';
import 'package:expenses_tracker/ai/services/ai_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiResponseParser', () {
    test('parses valid structured JSON into an add expense response', () {
      final response = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 250,
          "category": "Food",
          "date": "2026-05-14",
          "paymentMethod": "Cash",
          "currency": "EGP",
          "description": "مصروف أكل",
          "confidence": 0.92,
          "needsConfirmation": true
        }
        ''',
      );

      expect(response.intent, AiIntent.addExpense);
      expect(response.expensePayload?.amount, 250);
      expect(response.expensePayload?.categoryName, 'Food');
      expect(response.expensePayload?.date, DateTime(2026, 5, 14));
      expect(response.expensePayload?.paymentMethod, PaymentMethod.cash);
      expect(response.expensePayload?.currency, 'EGP');
      expect(response.confidence, 0.92);
      expect(response.needsConfirmation, isTrue);
    });

    test('rejects unstructured text output', () {
      expect(
        () => AiResponseParser.parse('I think this is a food expense.'),
        throwsA(isA<AiResponseParserException>()),
      );
    });

    test('keeps low confidence add expense response draftable', () {
      final response = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 250,
          "category": "Food",
          "date": "2026-05-14",
          "paymentMethod": "Cash",
          "confidence": 0.5,
          "needsConfirmation": true
        }
        ''',
      );

      expect(response.requiresClarification, isFalse);
    });

    test('accepts missing amount for editable add expense draft', () {
      final response = AiResponseParser.parse(
        '''
          {
            "intent": "add_expense",
            "category": "Food",
            "date": "2026-05-14",
            "paymentMethod": "Cash",
            "confidence": 0.9,
            "needsConfirmation": true
          }
        ''',
      );

      expect(response.expensePayload?.amount, isNull);
      expect(response.expensePayload?.categoryName, 'Food');
      expect(response.requiresClarification, isFalse);
    });

    test('preserves decimal amount values', () {
      final response = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 12.50,
          "category": "Food",
          "date": "2026-05-14",
          "paymentMethod": "Cash",
          "confidence": 0.92,
          "needsConfirmation": true
        }
        ''',
      );

      expect(response.expensePayload?.amount, 12.5);
    });

    test('maps Arabic cash payment method', () {
      final response = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 180,
          "category": "مواصلات",
          "date": "2026-05-15",
          "paymentMethod": "كاش",
          "confidence": 0.9,
          "needsConfirmation": true
        }
        ''',
      );

      expect(response.expensePayload?.paymentMethod, PaymentMethod.cash);
    });

    test(
        'allows omitted date and payment method for defaultable preview fields',
        () {
      final response = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 100,
          "category": "Food",
          "currency": "USD",
          "confidence": 0.9,
          "needsConfirmation": true
        }
        ''',
      );

      expect(response.expensePayload?.amount, 100);
      expect(response.expensePayload?.date, isNull);
      expect(response.expensePayload?.paymentMethod, isNull);
      expect(response.requiresClarification, isFalse);
    });

    test('parses last night and tonight relative dates', () {
      final lastNight = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 100,
          "category": "Food",
          "date": "last night",
          "confidence": 0.9,
          "needsConfirmation": true
        }
        ''',
        now: DateTime(2026, 5, 19, 12),
      );
      final tonight = AiResponseParser.parse(
        '''
        {
          "intent": "add_expense",
          "amount": 100,
          "category": "Food",
          "date": "tonight",
          "confidence": 0.9,
          "needsConfirmation": true
        }
        ''',
        now: DateTime(2026, 5, 19, 12),
      );

      expect(lastNight.expensePayload?.date, DateTime(2026, 5, 18));
      expect(tonight.expensePayload?.date, DateTime(2026, 5, 19));
    });
  });
}
