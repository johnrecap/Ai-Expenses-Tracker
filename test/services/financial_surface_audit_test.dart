import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_advice_payload.dart';
import 'package:expenses_tracker/ai/services/ai_advice_service.dart';
import 'package:expenses_tracker/engagement/services/weekly_digest_calculator.dart';
import 'package:expenses_tracker/screens/category_budgets/services/category_budget_calculator.dart';
import 'package:expenses_tracker/screens/home/services/home_summary_calculator.dart';
import 'package:expenses_tracker/screens/subscriptions/services/subscription_summary_service.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:expenses_tracker/services/export/export.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/finance_fixtures.dart';

void main() {
  test('Home Reports Budget AI and weekly digest share converted totals', () {
    final expenses = FinanceFixture.mixedCurrencyExpenses();
    final settings = FinanceFixture.settings();
    final range = ReportRange.monthly(anchorDate: FinanceFixture.now);

    final home = const HomeSummaryCalculator().calculate(
      expenses: expenses,
      settings: settings,
      user: FinanceFixture.user(),
      budget: FinanceFixture.monthlyBudget(),
      now: FinanceFixture.now,
    );
    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: range,
      settings: settings,
    );
    final budget = BudgetCalculator.calculate(
      budget: FinanceFixture.monthlyBudget(),
      expenses: expenses,
      settings: settings,
    );
    final advice = const AiAdviceService().generate(
      expenses: expenses,
      payload: const AiAdvicePayload(
        period: ReportRangeType.monthly,
        currency: FinanceFixture.baseCurrency,
      ),
      settings: settings,
      budget: FinanceFixture.monthlyBudget(),
      now: FinanceFixture.now,
    );
    final digest = const WeeklyDigestCalculator().calculate(
      expenses: expenses,
      settings: settings,
      now: FinanceFixture.now,
    );

    expect(home.spendingTotal, closeTo(report.total, 0.001));
    expect(budget.spent, closeTo(report.total, 0.001));
    expect(advice.report.total, closeTo(report.total, 0.001));
    expect(digest.report.total, closeTo(report.total, 0.001));
    expect(report.convertedCurrencies, ['SAR', 'USD']);
    expect(report.unconvertedCurrencies, ['EUR']);
  });

  test('Category Budgets can convert when settings target budget currency', () {
    final progress = const CategoryBudgetCalculator().calculate(
      budget: FinanceFixture.categoryBudget(),
      expenses: FinanceFixture.mixedCurrencyExpenses(),
      selectedMonth: '2026-05',
      settings: FinanceFixture.settings(),
    );

    expect(progress.spent, 2500);
    expect(progress.ignoredCurrencyCount, 0);
    expect(progress.status, CategoryBudgetProgressStatus.nearLimit);
  });

  test('Subscription Center remains grouped by original currency', () {
    const service = SubscriptionSummaryService();
    final summaries = service.summarize(
      rules: FinanceFixture.recurringRules(),
      now: FinanceFixture.now,
    );
    final totals = service.monthlyImpactByCurrency(summaries);

    expect(totals.keys.toList()..sort(), ['EGP', 'USD']);
    expect(totals['USD'], 10);
    expect(totals['EGP'], closeTo(433.333, 0.001));
  });

  test('CSV export preserves original rows and currencies', () async {
    final result = await const CsvExportService().exportExpenses(
      expenses: FinanceFixture.mixedCurrencyExpenses(),
      request: ExportRequest(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        format: ExportFormat.csv,
      ),
    );

    final csv = utf8.decode(result.bytes);
    expect(csv, contains('50,USD'));
    expect(csv, contains('20,EUR'));
  });
}
