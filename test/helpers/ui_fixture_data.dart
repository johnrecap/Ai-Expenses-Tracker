import 'package:expense_repository/expense_repository.dart';

class UiFixtureData {
  static const userId = 'ui-hardening-user';

  static final user = AppUser(
    userId: userId,
    email: 'ui-hardening@example.com',
    displayName: 'A very long bilingual display name for layout QA',
    photoUrl: null,
    createdAt: DateTime(2026, 5, 1),
  );

  static final longCategory = Category(
    categoryId: 'long-groceries',
    userId: userId,
    name: 'Groceries and household essentials with a very long label',
    totalExpenses: 0,
    icon: 'food',
    color: 0xFF2E7D32,
  );

  static final arabicCategory = Category(
    categoryId: 'arabic-family',
    userId: userId,
    name: 'مصاريف الأسرة والمنزل الشهرية الطويلة',
    totalExpenses: 0,
    icon: 'home',
    color: 0xFF1565C0,
  );

  static List<Category> categories() => [longCategory, arabicCategory];

  static List<Expense> expenses() => [
        Expense(
          expenseId: 'stress-1',
          userId: userId,
          category: longCategory,
          categoryId: longCategory.categoryId,
          categoryName: longCategory.name,
          categoryIcon: longCategory.icon,
          categoryColor: longCategory.color,
          date: DateTime(2026, 5, 19),
          amount: 987654321.45,
          description:
              'Bulk household restock with a long English description',
          merchant: 'Very Long Merchant Name For Receipt Layout',
          tags: const ['monthly', 'household', 'bulk-purchase'],
          paymentMethod: PaymentMethod.visa,
          currency: 'EGP',
          createdAt: DateTime(2026, 5, 19),
          updatedAt: DateTime(2026, 5, 19),
        ),
        Expense(
          expenseId: 'stress-2',
          userId: userId,
          category: arabicCategory,
          categoryId: arabicCategory.categoryId,
          categoryName: arabicCategory.name,
          categoryIcon: arabicCategory.icon,
          categoryColor: arabicCategory.color,
          date: DateTime(2026, 5, 18),
          amount: 12345.67,
          description: 'وصف عربي طويل لاختبار عدم تداخل النص مع المبلغ',
          merchant: 'متجر طويل الاسم',
          tags: const ['منزل', 'أسرة'],
          paymentMethod: PaymentMethod.cash,
          currency: 'USD',
          createdAt: DateTime(2026, 5, 18),
          updatedAt: DateTime(2026, 5, 18),
        ),
      ];

  static UserSettings settings() {
    return UserSettings.defaults(
      userId: userId,
      updatedAt: DateTime(2026, 5, 1),
    ).copyWith(
      appDisplayName: user.displayName,
      baseCurrency: 'EGP',
      supportedCurrencies: const ['EGP', 'USD', 'EUR'],
      conversionRates: const {'USD': 50.0, 'EUR': 54.0},
      defaultPaymentMethod: PaymentMethod.cash,
    );
  }

  static Budget budget() {
    return Budget(
      budgetId: Budget.budgetIdFor(month: 5, year: 2026),
      userId: userId,
      month: 5,
      year: 2026,
      amount: 1000000,
      currency: 'EGP',
      warningThresholdPercent: 80,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 1),
    );
  }
}
