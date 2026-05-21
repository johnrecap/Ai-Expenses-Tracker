import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = BudgetRecommendationService();
  final settings = UserSettings.defaults(userId: 'user-1').copyWith(
    baseCurrency: 'EGP',
    supportedCurrencies: const ['EGP', 'USD', 'EUR'],
    conversionRates: const {'USD': 50},
  );
  final now = DateTime(2026, 5, 20);

  test('recommends steady monthly budget from recent complete months', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 1000, date: DateTime(2026, 2, 10)),
          _expense(amount: 1000, date: DateTime(2026, 3, 10)),
          _expense(amount: 1000, date: DateTime(2026, 4, 10)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 1000);
    expect(recommendation.warningThresholdPercent, 80);
    expect(recommendation.confidence, BudgetRecommendationConfidence.high);
    expect(recommendation.caveats, isEmpty);
  });

  test('raises growing histories and lowers warning confidence for two months', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 1000, date: DateTime(2026, 3, 10)),
          _expense(amount: 1600, date: DateTime(2026, 4, 10)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 1500);
    expect(recommendation.warningThresholdPercent, 75);
    expect(recommendation.confidence, BudgetRecommendationConfidence.medium);
  });

  test('softens shrinking histories without dropping to the latest month only', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 1600, date: DateTime(2026, 2, 10)),
          _expense(amount: 1200, date: DateTime(2026, 3, 10)),
          _expense(amount: 1000, date: DateTime(2026, 4, 10)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 1300);
    expect(recommendation.confidence, BudgetRecommendationConfidence.high);
  });

  test('flags sparse history with low confidence', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 500, date: DateTime(2026, 4, 10)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 500);
    expect(recommendation.warningThresholdPercent, 70);
    expect(recommendation.confidence, BudgetRecommendationConfidence.low);
    expect(
      recommendation.caveats,
      contains(BudgetRecommendationCaveat.sparseHistory),
    );
  });

  test('reduces an outlier month and discloses the caveat', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 1000, date: DateTime(2026, 2, 10)),
          _expense(amount: 1100, date: DateTime(2026, 3, 10)),
          _expense(amount: 4000, date: DateTime(2026, 4, 10)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 1100);
    expect(recommendation.confidence, BudgetRecommendationConfidence.medium);
    expect(
      recommendation.caveats,
      contains(BudgetRecommendationCaveat.outlierMonth),
    );
  });

  test('excludes missing-rate expenses and discloses the caveat', () {
    final recommendation = service.recommendMonthlyBudget(
      BudgetRecommendationInput(
        expenses: [
          _expense(amount: 1000, date: DateTime(2026, 3, 10)),
          _expense(amount: 1000, date: DateTime(2026, 4, 10)),
          _expense(amount: 20, currency: 'EUR', date: DateTime(2026, 4, 11)),
        ],
        settings: settings,
        now: now,
      ),
    );

    expect(recommendation.suggestedAmount, 1000);
    expect(recommendation.confidence, BudgetRecommendationConfidence.low);
    expect(
      recommendation.caveats,
      contains(BudgetRecommendationCaveat.missingRates),
    );
  });

  test('suggests high or growing category budgets without saving them', () {
    final recommendations = service.recommendCategoryBudgets(
      BudgetRecommendationInput(
        expenses: [
          _expense(
            amount: 500,
            date: DateTime(2026, 2, 10),
            categoryId: 'transport',
            categoryName: 'Transport',
          ),
          _expense(
            amount: 700,
            date: DateTime(2026, 3, 10),
            categoryId: 'transport',
            categoryName: 'Transport',
          ),
          _expense(
            amount: 1200,
            date: DateTime(2026, 4, 10),
            categoryId: 'transport',
            categoryName: 'Transport',
          ),
          _expense(
            amount: 400,
            date: DateTime(2026, 4, 12),
            categoryId: 'food',
            categoryName: 'Food',
          ),
        ],
        settings: settings,
        categories: [
          _category('transport', 'Transport'),
          _category('food', 'Food'),
        ],
        now: now,
      ),
    );

    expect(recommendations.first.categoryId, 'transport');
    expect(recommendations.first.suggestedAmount, 700);
    expect(
      recommendations.first.caveats,
      contains(BudgetRecommendationCaveat.outlierMonth),
    );
    expect(
      recommendations.first.scope,
      BudgetRecommendationScope.category,
    );
  });
}

Expense _expense({
  required num amount,
  required DateTime date,
  String currency = 'EGP',
  String categoryId = 'general',
  String categoryName = 'General',
}) {
  final category = _category(categoryId, categoryName);
  return Expense(
    expenseId: '$categoryId-${date.millisecondsSinceEpoch}-$amount',
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date,
    amount: amount,
    currency: currency,
  );
}

Category _category(String id, String name) {
  return Category(
    categoryId: id,
    name: name,
    totalExpenses: 0,
    icon: 'other',
    color: 0xff222222,
  );
}
