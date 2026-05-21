import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required int amount,
  required DateTime date,
  String currency = 'EGP',
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: categoryName.hashCode,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryName,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date,
    amount: amount,
    currency: currency,
  );
}

UserSettings _settings({Map<String, num>? conversionRates}) {
  return UserSettings.defaults(userId: 'user-1').copyWith(
    baseCurrency: 'EGP',
    supportedCurrencies: const ['EGP', 'USD'],
    conversionRates: conversionRates,
  );
}

void main() {
  const calculator = WeeklyDigestCalculator();

  test('calculates current week total and previous comparison', () {
    final digest = calculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 200,
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          id: '2',
          categoryId: 'bills',
          categoryName: 'Bills',
          amount: 100,
          date: DateTime(2026, 5, 5),
        ),
      ],
      settings: _settings(),
      now: DateTime(2026, 5, 17),
    );

    expect(digest.currentTotal, 200);
    expect(digest.previousTotal, 100);
    expect(digest.deltaPercent, 100);
  });

  test('identifies top category', () {
    final digest = calculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 200,
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          id: '2',
          categoryId: 'bills',
          categoryName: 'Bills',
          amount: 300,
          date: DateTime(2026, 5, 13),
        ),
      ],
      settings: _settings(),
      now: DateTime(2026, 5, 17),
    );

    expect(digest.topCategory?.categoryName, 'Bills');
  });

  test('returns empty state when no current or previous data exists', () {
    final digest = calculator.calculate(
      expenses: const [],
      settings: _settings(),
      now: DateTime(2026, 5, 17),
    );

    expect(digest.isEmpty, isTrue);
    expect(digest.insight, contains('Start'));
  });

  test('includes converted mixed-currency expenses in digest totals', () {
    final digest = calculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'transport',
          categoryName: 'Transport',
          amount: 100,
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          id: '2',
          categoryId: 'subscriptions',
          categoryName: 'Subscriptions',
          amount: 50,
          date: DateTime(2026, 5, 13),
          currency: 'USD',
        ),
      ],
      settings: _settings(conversionRates: const {'USD': 50}),
      now: DateTime(2026, 5, 17),
    );

    expect(digest.currentTotal, 2600);
    expect(digest.topCategory?.categoryName, 'Subscriptions');
    expect(digest.ignoredCurrencyCount, 0);
    expect(digest.convertedCurrencies, ['USD']);
    expect(digest.unconvertedCurrencies, isEmpty);
  });

  test('tracks missing-rate currencies in digest evidence metadata', () {
    final digest = calculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'transport',
          categoryName: 'Transport',
          amount: 100,
          date: DateTime(2026, 5, 12),
        ),
        _expense(
          id: '2',
          categoryId: 'subscriptions',
          categoryName: 'Subscriptions',
          amount: 50,
          date: DateTime(2026, 5, 13),
          currency: 'USD',
        ),
      ],
      settings: _settings(),
      now: DateTime(2026, 5, 17),
    );

    expect(digest.currentTotal, 100);
    expect(digest.ignoredCurrencyCount, 1);
    expect(digest.convertedCurrencies, isEmpty);
    expect(digest.unconvertedCurrencies, ['USD']);
  });
}
