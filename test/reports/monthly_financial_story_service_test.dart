import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/models/monthly_financial_story.dart';
import 'package:expenses_tracker/screens/reports/services/monthly_financial_story_service.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required double amount,
  required DateTime date,
  String currency = 'EGP',
  String description = '',
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
    date: date,
    amount: amount,
    currency: currency,
    description: description,
  );
}

UserSettings _settings({Map<String, num>? conversionRates}) {
  return UserSettings.defaults(userId: 'user-1').copyWith(
    baseCurrency: 'EGP',
    supportedCurrencies: const ['EGP', 'USD'],
    conversionRates: conversionRates,
  );
}

MonthlyFinancialStory _story(
  List<Expense> expenses, {
  UserSettings? settings,
}) {
  final resolvedSettings = settings ?? _settings();
  final report = ReportCalculator.calculate(
    expenses: expenses,
    range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 20)),
    settings: resolvedSettings,
  );
  return const MonthlyFinancialStoryService().build(
    report: report,
    expenses: expenses,
    settings: resolvedSettings,
  );
}

void main() {
  test('identifies increased spending drivers and outliers', () {
    final story = _story([
      _expense(
        id: 'rent',
        categoryId: 'housing',
        categoryName: 'Housing',
        amount: 900,
        date: DateTime(2026, 5, 2),
        description: 'rent',
      ),
      _expense(
        id: 'food',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 100,
        date: DateTime(2026, 5, 3),
      ),
      _expense(
        id: 'previous',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 300,
        date: DateTime(2026, 4, 3),
      ),
    ]);

    expect(story.trend, MonthlyStoryTrend.increase);
    expect(story.drivers.first.category.categoryName, 'Housing');
    expect(story.drivers.first.sharePercent, 90);
    expect(story.outliers.first.expense.expenseId, 'rent');
  });

  test('identifies decreased spending without inventing drivers', () {
    final story = _story([
      _expense(
        id: 'current',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 100,
        date: DateTime(2026, 5, 3),
      ),
      _expense(
        id: 'previous',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 300,
        date: DateTime(2026, 4, 3),
      ),
    ]);

    expect(story.trend, MonthlyStoryTrend.decrease);
    expect(story.currentTotal, 100);
    expect(story.previousTotal, 300);
    expect(story.drivers.single.category.categoryName, 'Food');
  });

  test('reports empty and missing-rate caveat states', () {
    final empty = _story([]);

    expect(empty.trend, MonthlyStoryTrend.empty);
    expect(empty.drivers, isEmpty);
    expect(empty.outliers, isEmpty);

    final missingRate = _story([
      _expense(
        id: 'usd',
        categoryId: 'travel',
        categoryName: 'Travel',
        amount: 10,
        date: DateTime(2026, 5, 3),
        currency: 'USD',
      ),
    ]);

    expect(missingRate.hasMissingRateCaveat, isTrue);
    expect(missingRate.ignoredCurrencyCount, 1);
    expect(missingRate.unconvertedCurrencies, ['USD']);
  });
}
