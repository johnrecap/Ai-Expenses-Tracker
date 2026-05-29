import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/l10n/app_localizations_en.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required DateTime date,
  int amount = 50,
  String categoryName = 'Food',
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 0,
  );
  return Expense(
    expenseId: '$categoryName-${date.millisecondsSinceEpoch}',
    category: category,
    categoryName: categoryName,
    date: date,
    amount: amount,
    currency: 'EGP',
  );
}

BudgetProgress _budgetProgress(BudgetProgressStatus status) {
  return BudgetProgress(
    budget: status == BudgetProgressStatus.none
        ? null
        : Budget(
            budgetId: '2026-05',
            userId: 'user-1',
            month: 5,
            year: 2026,
            amount: 1000,
            currency: 'EGP',
            warningThresholdPercent: 80,
            createdAt: DateTime(2026, 5),
            updatedAt: DateTime(2026, 5),
          ),
    spent: status == BudgetProgressStatus.exceeded ? 1100 : 850,
    remaining: status == BudgetProgressStatus.exceeded ? -100 : 150,
    percentUsed: status == BudgetProgressStatus.exceeded ? 1.1 : 0.85,
    ignoredCurrencyCount: 0,
    status: status,
  );
}

WeeklyDigest _digest({bool empty = false}) {
  return WeeklyDigest(
    report: ExpenseReport(
      range: ReportRange.weekly(anchorDate: DateTime(2026, 5, 17)),
      currency: 'EGP',
      total: empty ? 0 : 200,
      buckets: const [],
      previousTotal: 150,
      deltaPercent: 33.3,
      categoryTotals: empty
          ? const []
          : const [
              CategoryReportTotal(
                categoryId: 'food',
                categoryName: 'Food',
                categoryIcon: 'food',
                categoryColor: 0,
                total: 200,
              ),
            ],
      topCategory: empty
          ? null
          : const CategoryReportTotal(
              categoryId: 'food',
              categoryName: 'Food',
              categoryIcon: 'food',
              categoryColor: 0,
              total: 200,
            ),
      ignoredCurrencyCount: 0,
    ),
    insight: empty ? '' : 'Food led spending this week.',
  );
}

void main() {
  const service = RetentionPromptService();
  final l10n = AppLocalizationsEn();

  test('returns first-run setup prompt when no expenses exist', () {
    final prompts = service.buildPrompts(
      expenses: const [],
      budgetProgress: BudgetProgress.empty,
      streak: TrackingStreak(
        currentStreakDays: 0,
        hasTrackedToday: false,
        referenceDate: DateTime(2026, 5, 17),
      ),
      digest: _digest(empty: true),
      l10n: l10n,
    );

    expect(prompts, hasLength(1));
    expect(prompts.single.kind, RetentionPromptKind.onboarding);
  });

  test('uses local streak and weekly summary data without AI text', () {
    final prompts = service.buildPrompts(
      expenses: [_expense(date: DateTime(2026, 5, 16))],
      budgetProgress: _budgetProgress(BudgetProgressStatus.normal),
      streak: TrackingStreak(
        currentStreakDays: 3,
        hasTrackedToday: false,
        referenceDate: DateTime(2026, 5, 17),
        lastTrackedDate: DateTime(2026, 5, 16),
      ),
      digest: _digest(),
      l10n: l10n,
    );

    expect(
      prompts.map((prompt) => prompt.kind),
      contains(RetentionPromptKind.streak),
    );
    expect(
      prompts.map((prompt) => prompt.kind),
      contains(RetentionPromptKind.weeklySummary),
    );
    final promptText = prompts
        .map((prompt) => '${prompt.title} ${prompt.message}')
        .join(' ')
        .toLowerCase();
    expect(promptText, isNot(contains('ai')));
  });

  test('adds budget nudge when spending is near the monthly limit', () {
    final prompts = service.buildPrompts(
      expenses: [_expense(date: DateTime(2026, 5, 16))],
      budgetProgress: _budgetProgress(BudgetProgressStatus.nearLimit),
      streak: TrackingStreak(
        currentStreakDays: 1,
        hasTrackedToday: true,
        referenceDate: DateTime(2026, 5, 17),
      ),
      digest: _digest(empty: true),
      l10n: l10n,
    );

    expect(prompts.single.kind, RetentionPromptKind.budgetNudge);
  });
}
