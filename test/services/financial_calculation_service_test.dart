import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/finance_fixtures.dart';

void main() {
  const service = FinancialCalculationService();

  test('converts supported currencies and exposes rate metadata', () {
    final breakdown = service.calculateExpenses(
      expenses: FinanceFixture.mixedCurrencyExpenses(),
      settings: FinanceFixture.settings(),
      where: (expense) => expense.date.month == 5,
    );

    expect(breakdown.baseCurrency, 'EGP');
    expect(breakdown.total, closeTo(2733, 0.001));
    expect(breakdown.convertedCurrencies, ['SAR', 'USD']);
    expect(breakdown.unconvertedCurrencies, ['EUR']);
    expect(breakdown.ignoredCurrencyCount, 1);
    expect(breakdown.rateUpdatedAt, FinanceFixture.staleRateDate);

    final usdRow = breakdown.convertedRows.firstWhere(
      (row) => row.sourceCurrency == 'USD',
    );
    expect(usdRow.sourceAmount, 50);
    expect(usdRow.convertedAmount, 2500);
    expect(usdRow.rate, 50);
    expect(usdRow.rateUpdatedAt, FinanceFixture.staleRateDate);
  });

  test('base currency changes use the matching saved rate direction', () {
    final breakdown = service.calculateExpenses(
      expenses: [
        FinanceFixture.expense(
          id: 'egp-to-usd',
          amount: 100,
          currency: 'EGP',
          categoryId: 'food',
          categoryName: 'Food',
          date: FinanceFixture.now,
        ),
      ],
      settings: FinanceFixture.settings(
        baseCurrency: 'USD',
        conversionRates: const {'EGP': 0.02},
      ),
    );

    expect(breakdown.baseCurrency, 'USD');
    expect(breakdown.total, 2);
    expect(breakdown.convertedCurrencies, ['EGP']);
    expect(breakdown.unconvertedCurrencies, isEmpty);
  });

  test('missing and invalid rates are excluded and surfaced', () {
    final breakdown = service.calculateExpenses(
      expenses: [
        FinanceFixture.expense(
          id: 'missing-gbp',
          amount: 10,
          currency: 'GBP',
          categoryId: 'travel',
          categoryName: 'Travel',
          date: FinanceFixture.now,
        ),
      ],
      settings: FinanceFixture.settings(
        conversionRates: const {'GBP': -1},
      ),
    );

    expect(breakdown.total, 0);
    expect(breakdown.convertedRows, isEmpty);
    expect(breakdown.unconvertedCurrencies, ['GBP']);
    expect(breakdown.ignoredCurrencyCount, 1);
  });

  test('stale offline rates remain usable but keep their timestamp', () {
    final staleTimestamp = DateTime(2026, 5, 10, 8);
    final breakdown = service.calculateExpenses(
      expenses: [
        FinanceFixture.expense(
          id: 'stale-usd',
          amount: 1,
          currency: 'USD',
          categoryId: 'food',
          categoryName: 'Food',
          date: FinanceFixture.now,
        ),
      ],
      settings: FinanceFixture.settings(
        conversionRates: const {'USD': 49},
        exchangeRatesUpdatedAt: staleTimestamp,
      ),
    );

    expect(breakdown.total, 49);
    expect(breakdown.rateUpdatedAt, staleTimestamp);
    expect(breakdown.convertedRows.single.rateUpdatedAt, staleTimestamp);
  });
}
