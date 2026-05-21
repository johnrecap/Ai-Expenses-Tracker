import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/models/home_summary.dart';
import 'package:expenses_tracker/screens/home/services/home_summary_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required int amount,
  required DateTime date,
  String currency = 'EGP',
  String categoryName = 'Food',
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 0,
  );
  return Expense(
    expenseId: '$categoryName-$amount-${date.millisecondsSinceEpoch}',
    category: category,
    categoryName: categoryName,
    date: date,
    amount: amount,
    currency: currency,
    syncStatus: syncStatus,
  );
}

Budget _budget({
  double amount = 1000,
  String currency = 'EGP',
}) {
  return Budget(
    budgetId: '2026-05',
    userId: 'user-1',
    month: 5,
    year: 2026,
    amount: amount,
    currency: currency,
    warningThresholdPercent: 80,
    createdAt: DateTime(2026, 5),
    updatedAt: DateTime(2026, 5),
  );
}

UserSettings _settings({
  String baseCurrency = 'EGP',
  List<String>? supportedCurrencies,
  Map<String, num>? conversionRates,
}) {
  return UserSettings.defaults(userId: 'user-1').copyWith(
    baseCurrency: baseCurrency,
    supportedCurrencies: supportedCurrencies ?? [baseCurrency],
    conversionRates: conversionRates,
  );
}

AppUser _user({
  String? displayName = 'Saeed',
  String? email = 'saeed@example.com',
}) {
  return AppUser(
    userId: 'user-1',
    email: email,
    displayName: displayName,
    photoUrl: null,
    createdAt: DateTime(2026, 5),
  );
}

void main() {
  const calculator = HomeSummaryCalculator();

  test('monthly spending only counts current month in base currency', () {
    final summary = calculator.calculate(
      expenses: [
        _expense(amount: 250, date: DateTime(2026, 5, 10)),
        _expense(amount: 100, date: DateTime(2026, 4, 30)),
      ],
      settings: _settings(),
      user: _user(),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.spendingTotal, 250);
    expect(summary.currency, 'EGP');
    expect(summary.hasBudget, isFalse);
  });

  test('budget remaining equals budget minus same-currency spending', () {
    final summary = calculator.calculate(
      expenses: [_expense(amount: 250, date: DateTime(2026, 5, 10))],
      settings: _settings(),
      user: _user(),
      budget: _budget(),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.budgetAmount, 1000);
    expect(summary.budgetRemaining, 750);
    expect(summary.budgetStatus, HomeBudgetStatus.normal);
  });

  test('no budget returns no fake income or budget amount', () {
    final summary = calculator.calculate(
      expenses: [_expense(amount: 250, date: DateTime(2026, 5, 10))],
      settings: _settings(),
      user: _user(),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.hasBudget, isFalse);
    expect(summary.budgetAmount, isNull);
    expect(summary.budgetRemaining, isNull);
  });

  test('mixed currency without a known rate reports unconverted totals', () {
    final summary = calculator.calculate(
      expenses: [
        _expense(amount: 250, date: DateTime(2026, 5, 10)),
        _expense(amount: 50, date: DateTime(2026, 5, 11), currency: 'GBP'),
      ],
      settings: _settings(),
      user: _user(),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.spendingTotal, 250);
    expect(summary.hasMixedCurrencies, isTrue);
    expect(summary.ignoredCurrencyCount, 1);
    expect(summary.unconvertedCurrencies, ['GBP']);
    expect(summary.convertedCurrencies, isEmpty);
  });

  test('base USD converts EGP expenses into monthly spending total', () {
    final summary = calculator.calculate(
      expenses: [
        _expense(
          amount: 100,
          date: DateTime(2026, 5, 10),
          currency: 'EGP',
        ),
      ],
      settings: _settings(
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
        conversionRates: const {'EGP': 0.02},
      ),
      user: _user(),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.spendingTotal, 2);
    expect(summary.currency, 'USD');
    expect(summary.hasMixedCurrencies, isTrue);
    expect(summary.convertedCurrencies, ['EGP']);
    expect(summary.ignoredCurrencyCount, 0);
  });

  test('base EGP uses saved USD rate when available', () {
    final summary = calculator.calculate(
      expenses: [
        _expense(
          amount: 100,
          date: DateTime(2026, 5, 10),
          currency: 'USD',
        ),
      ],
      settings: _settings(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
      user: _user(),
      budget: _budget(amount: 10000, currency: 'EGP'),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.spendingTotal, 5000);
    expect(summary.budgetRemaining, 5000);
    expect(summary.convertedCurrencies, ['USD']);
    expect(summary.ignoredCurrencyCount, 0);
  });

  test('converted spending drives top category and budget remaining', () {
    final summary = calculator.calculate(
      expenses: [
        _expense(
          amount: 100,
          date: DateTime(2026, 5, 10),
          currency: 'EGP',
          categoryName: 'Food',
        ),
        _expense(
          amount: 3,
          date: DateTime(2026, 5, 11),
          currency: 'USD',
          categoryName: 'Transport',
        ),
      ],
      settings: _settings(
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
        conversionRates: const {'EGP': 0.05},
      ),
      user: _user(),
      budget: _budget(amount: 20, currency: 'USD'),
      now: DateTime(2026, 5, 17),
    );

    expect(summary.spendingTotal, 8);
    expect(summary.topCategoryName, 'Food');
    expect(summary.budgetRemaining, 12);
    expect(summary.budgetStatus, HomeBudgetStatus.normal);
  });

  test('display name falls back from display name to email to generic user',
      () {
    expect(
      calculator.calculate(
        expenses: const [],
        settings: _settings(),
        user: _user(displayName: 'Saeed'),
        now: DateTime(2026, 5, 17),
      ).displayName,
      'Saeed',
    );
    expect(
      calculator.calculate(
        expenses: const [],
        settings: _settings(),
        user: _user(displayName: null, email: 'person@example.com'),
        now: DateTime(2026, 5, 17),
      ).displayName,
      'person@example.com',
    );
    expect(
      calculator.calculate(
        expenses: const [],
        settings: _settings(),
        user: _user(displayName: null, email: null),
        now: DateTime(2026, 5, 17),
      ).displayName,
      'User',
    );
  });
}
