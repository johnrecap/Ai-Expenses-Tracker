import 'package:expense_repository/expense_repository.dart';

class FinanceFixture {
  FinanceFixture._();

  static final now = DateTime(2026, 5, 20, 12);
  static final staleRateDate = DateTime(2026, 5, 19, 9);

  static const userId = 'finance-user';
  static const baseCurrency = 'EGP';

  static UserSettings settings({
    String baseCurrency = FinanceFixture.baseCurrency,
    Map<String, num>? conversionRates,
    DateTime? exchangeRatesUpdatedAt,
  }) {
    return UserSettings.defaults(userId: userId).copyWith(
      baseCurrency: baseCurrency,
      supportedCurrencies: const ['EGP', 'USD', 'EUR', 'SAR'],
      conversionRates: conversionRates ?? const {'USD': 50, 'SAR': 13.3},
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt ?? staleRateDate,
    );
  }

  static AppUser user() {
    return AppUser(
      userId: userId,
      email: 'finance@example.com',
      displayName: 'Finance User',
      photoUrl: null,
      createdAt: DateTime(2026, 5),
    );
  }

  static Budget monthlyBudget({
    double amount = 10000,
    String currency = baseCurrency,
  }) {
    return Budget(
      budgetId: '2026-05-$currency',
      userId: userId,
      month: 5,
      year: 2026,
      amount: amount,
      currency: currency,
      warningThresholdPercent: 80,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );
  }

  static CategoryBudget categoryBudget({
    String categoryId = 'subscriptions',
    String categoryName = 'Subscriptions',
    double limitAmount = 3000,
    String currency = baseCurrency,
  }) {
    return CategoryBudget(
      categoryBudgetId: '2026-05_${categoryId}_$currency',
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      month: '2026-05',
      currency: currency,
      limitAmount: limitAmount,
      warningThresholdPercent: 80,
      isArchived: false,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );
  }

  static List<Expense> mixedCurrencyExpenses() {
    return [
      expense(
        id: 'egp-food',
        amount: 100,
        currency: 'EGP',
        categoryId: 'food',
        categoryName: 'Food',
        date: DateTime(2026, 5, 18),
      ),
      expense(
        id: 'usd-subscription',
        amount: 50,
        currency: 'USD',
        categoryId: 'subscriptions',
        categoryName: 'Subscriptions',
        date: DateTime(2026, 5, 19),
      ),
      expense(
        id: 'sar-transport',
        amount: 10,
        currency: 'SAR',
        categoryId: 'transport',
        categoryName: 'Transport',
        date: DateTime(2026, 5, 20),
      ),
      expense(
        id: 'eur-missing-rate',
        amount: 20,
        currency: 'EUR',
        categoryId: 'bills',
        categoryName: 'Bills',
        date: DateTime(2026, 5, 20),
      ),
      expense(
        id: 'old-usd',
        amount: 5,
        currency: 'USD',
        categoryId: 'food',
        categoryName: 'Food',
        date: DateTime(2026, 4, 20),
      ),
    ];
  }

  static Expense expense({
    required String id,
    required num amount,
    required String currency,
    required String categoryId,
    required String categoryName,
    required DateTime date,
  }) {
    final category = categoryFor(categoryId, categoryName);
    return Expense(
      expenseId: id,
      userId: userId,
      category: category,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: category.icon,
      categoryColor: category.color,
      date: date,
      amount: amount,
      currency: currency,
      description: '$categoryName $currency expense',
    );
  }

  static Category categoryFor(String id, String name) {
    return Category(
      categoryId: id,
      name: name,
      totalExpenses: 0,
      icon: id,
      color: id.hashCode,
    );
  }

  static List<RecurringExpense> recurringRules() {
    return [
      recurringRule(
        id: 'monthly-usd',
        amount: 10,
        currency: 'USD',
        frequency: RecurringFrequency.monthly,
      ),
      recurringRule(
        id: 'weekly-egp',
        amount: 100,
        currency: 'EGP',
        frequency: RecurringFrequency.weekly,
      ),
    ];
  }

  static RecurringExpense recurringRule({
    required String id,
    required num amount,
    required String currency,
    required RecurringFrequency frequency,
  }) {
    final category = categoryFor('subscriptions', 'Subscriptions');
    return RecurringExpense(
      recurringExpenseId: id,
      userId: userId,
      amount: amount,
      category: category,
      categoryId: category.categoryId,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColor: category.color,
      currency: currency,
      startDate: DateTime(2026, 5, 1),
      nextRunDate: DateTime(2026, 5, 25),
      frequency: frequency,
      isActive: true,
      isArchived: false,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );
  }
}
