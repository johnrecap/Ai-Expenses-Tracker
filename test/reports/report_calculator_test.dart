import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required double amount,
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

UserSettings _settings({
  String baseCurrency = 'EGP',
  Map<String, num>? conversionRates,
}) {
  return UserSettings.defaults(userId: 'user-1').copyWith(
    baseCurrency: baseCurrency,
    supportedCurrencies: [baseCurrency, 'USD'],
    conversionRates: conversionRates,
  );
}

void main() {
  test('weekly report creates seven day buckets with matching totals', () {
    final report = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 100.25,
          date: DateTime(2026, 5, 11),
        ),
        _expense(
          id: '2',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 200.50,
          date: DateTime(2026, 5, 13),
        ),
      ],
      range: ReportRange.weekly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(),
    );

    expect(report.buckets.length, 7);
    expect(report.total, 300.75);
    expect(report.buckets[0].total, 100.25);
    expect(report.buckets[2].total, 200.50);
  });

  test('weekly report converts supported mixed currencies into base total', () {
    final report = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'transport',
          categoryName: 'Transport',
          amount: 100,
          date: DateTime(2026, 5, 19),
        ),
        _expense(
          id: '2',
          categoryId: 'subscriptions',
          categoryName: 'Subscriptions',
          amount: 50,
          date: DateTime(2026, 5, 20),
          currency: 'USD',
        ),
      ],
      range: ReportRange.weekly(anchorDate: DateTime(2026, 5, 20)),
      settings: _settings(conversionRates: const {'USD': 53.232}),
    );

    expect(report.currency, 'EGP');
    expect(report.total, closeTo(2761.6, 0.001));
    expect(report.buckets[1].total, 100);
    expect(report.buckets[2].total, closeTo(2661.6, 0.001));
    expect(report.topCategory?.categoryName, 'Subscriptions');
    expect(report.convertedCurrencies, ['USD']);
    expect(report.unconvertedCurrencies, isEmpty);
    expect(report.ignoredCurrencyCount, 0);
  });

  test(
      'monthly report groups by week buckets and ignores missing-rate currency',
      () {
    final report = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 100,
          date: DateTime(2026, 5, 1),
        ),
        _expense(
          id: '2',
          categoryId: 'bills',
          categoryName: 'Bills',
          amount: 50,
          date: DateTime(2026, 5, 20),
          currency: 'USD',
        ),
      ],
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(),
    );

    expect(report.buckets.length, 5);
    expect(report.total, 100);
    expect(report.unconvertedCurrencies, ['USD']);
    expect(report.ignoredCurrencyCount, 1);
  });

  test('top category is deterministic on ties', () {
    final report = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'b',
          categoryName: 'Bills',
          amount: 100,
          date: DateTime(2026, 5, 15),
        ),
        _expense(
          id: '2',
          categoryId: 'a',
          categoryName: 'Food',
          amount: 100,
          date: DateTime(2026, 5, 15),
        ),
      ],
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(),
    );

    expect(report.topCategory?.categoryName, 'Bills');
  });

  test('delta handles previous zero and non-zero totals', () {
    final zeroPrevious = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 100,
          date: DateTime(2026, 5, 15),
        ),
      ],
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(),
    );

    expect(zeroPrevious.previousTotal, 0);
    expect(zeroPrevious.deltaPercent, 100);

    final nonZeroPrevious = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 200,
          date: DateTime(2026, 5, 15),
        ),
        _expense(
          id: '2',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 100,
          date: DateTime(2026, 4, 15),
        ),
      ],
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(),
    );

    expect(nonZeroPrevious.previousTotal, 100);
    expect(nonZeroPrevious.deltaPercent, 100);
  });

  test('delta compares converted current and previous period totals', () {
    final report = ReportCalculator.calculate(
      expenses: [
        _expense(
          id: 'current-egp',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 100,
          date: DateTime(2026, 5, 15),
        ),
        _expense(
          id: 'current-usd',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 2,
          date: DateTime(2026, 5, 16),
          currency: 'USD',
        ),
        _expense(
          id: 'previous-usd',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 1,
          date: DateTime(2026, 4, 15),
          currency: 'USD',
        ),
      ],
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 15)),
      settings: _settings(conversionRates: const {'USD': 50}),
    );

    expect(report.total, 200);
    expect(report.previousTotal, 50);
    expect(report.deltaPercent, 300);
  });
}
