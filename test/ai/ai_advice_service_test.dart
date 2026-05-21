import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_advice_payload.dart';
import 'package:expenses_tracker/ai/services/ai_advice_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates advice from actual aggregates without inventing totals', () {
    const service = AiAdviceService();
    final advice = service.generate(
      expenses: [
        _expense(
          amount: 300,
          categoryName: 'Restaurants',
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          amount: 100,
          categoryName: 'Transport',
          date: DateTime(2026, 5, 13),
        ),
      ],
      payload: const AiAdvicePayload(
        period: ReportRangeType.weekly,
        currency: 'EGP',
      ),
      settings: UserSettings.defaults(userId: 'user-1'),
      now: DateTime(2026, 5, 15),
    );

    expect(advice.report.total, 400);
    expect(advice.report.topCategory?.categoryName, 'Restaurants');
    expect(advice.evidence, contains('Total: 400 EGP'));
    expect(advice.message, contains('Restaurants'));
  });

  test('generates advice from converted mixed-currency aggregates', () {
    const service = AiAdviceService();
    final advice = service.generate(
      expenses: [
        _expense(
          amount: 100,
          categoryName: 'Transport',
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          amount: 50,
          categoryName: 'Subscriptions',
          date: DateTime(2026, 5, 13),
          currency: 'USD',
        ),
      ],
      payload: const AiAdvicePayload(
        period: ReportRangeType.weekly,
        currency: 'EGP',
      ),
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
      now: DateTime(2026, 5, 15),
    );

    expect(advice.report.total, 2600);
    expect(advice.report.topCategory?.categoryName, 'Subscriptions');
    expect(advice.report.convertedCurrencies, ['USD']);
    expect(advice.evidence, contains('Total: 2600 EGP'));
    expect(advice.evidence, contains('Converted currencies: USD'));
    expect(
      advice.evidence,
      isNot(contains('Ignored 1 expenses in other currencies')),
    );
  });

  test('explains missing-rate expenses without generic ignored wording', () {
    const service = AiAdviceService();
    final advice = service.generate(
      expenses: [
        _expense(
          amount: 100,
          categoryName: 'Transport',
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          amount: 50,
          categoryName: 'Subscriptions',
          date: DateTime(2026, 5, 13),
          currency: 'USD',
        ),
      ],
      payload: const AiAdvicePayload(
        period: ReportRangeType.weekly,
        currency: 'EGP',
      ),
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
      ),
      now: DateTime(2026, 5, 15),
    );

    expect(advice.report.total, 100);
    expect(
      advice.evidence,
      contains('Missing rates for USD; 1 expense was not included'),
    );
  });

  test('generates Arabic local advice when locale is Arabic', () {
    const service = AiAdviceService();
    final advice = service.generate(
      expenses: [
        _expense(
          amount: 300,
          categoryName: 'Restaurants',
          date: DateTime(2026, 5, 12),
        ),
      ],
      payload: const AiAdvicePayload(
        period: ReportRangeType.weekly,
        currency: 'EGP',
      ),
      settings: UserSettings.defaults(userId: 'user-1'),
      now: DateTime(2026, 5, 15),
      locale: 'ar',
    );

    expect(advice.evidence.first, startsWith('الإجمالي'));
    expect(advice.message, isNot(contains('Your highest spending')));
    expect(advice.message, contains('Restaurants'));
  });
}

Expense _expense({
  required int amount,
  required String categoryName,
  required DateTime date,
  String currency = 'EGP',
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 0xFF000000,
  );
  return Expense(
    expenseId: '$categoryName-$amount',
    userId: 'user-1',
    category: category,
    date: date,
    amount: amount,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    currency: currency,
  );
}
