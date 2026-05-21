import 'package:expense_repository/expense_repository.dart';

final historyFoodCategory = Category(
  categoryId: 'food',
  name: 'Food',
  totalExpenses: 0,
  icon: 'restaurant',
  color: 0xFFE57373,
);

final historyTransportCategory = Category(
  categoryId: 'transport',
  name: 'Transport',
  totalExpenses: 0,
  icon: 'directions_car',
  color: 0xFF64B5F6,
);

final historyShoppingCategory = Category(
  categoryId: 'shopping',
  name: 'Shopping',
  totalExpenses: 0,
  icon: 'shopping_bag',
  color: 0xFFFFB74D,
);

List<Category> historyCategories() => [
      historyFoodCategory,
      historyTransportCategory,
      historyShoppingCategory,
    ];

List<Expense> historyExpenses() => [
      historyExpense(
        id: 'food-current-1',
        category: historyFoodCategory,
        amount: 250,
        date: DateTime(2026, 5, 4),
        description: 'Lunch',
      ),
      historyExpense(
        id: 'food-current-2',
        category: historyFoodCategory,
        amount: 400,
        date: DateTime(2026, 5, 12),
        description: 'Groceries',
      ),
      historyExpense(
        id: 'transport-current',
        category: historyTransportCategory,
        amount: 120,
        date: DateTime(2026, 5, 14),
        description: 'Uber ride',
        paymentMethod: PaymentMethod.visa,
      ),
      historyExpense(
        id: 'shopping-current',
        category: historyShoppingCategory,
        amount: 800,
        date: DateTime(2026, 5, 15),
        description: 'Shoes',
      ),
      historyExpense(
        id: 'food-previous',
        category: historyFoodCategory,
        amount: 100,
        date: DateTime(2026, 4, 9),
        description: 'April lunch',
      ),
      historyExpense(
        id: 'transport-previous',
        category: historyTransportCategory,
        amount: 90,
        date: DateTime(2026, 4, 11),
        description: 'April taxi',
      ),
    ];

Expense historyExpense({
  required String id,
  required Category category,
  required num amount,
  required DateTime date,
  String description = '',
  PaymentMethod paymentMethod = PaymentMethod.cash,
  String currency = 'EGP',
}) {
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date,
    amount: amount,
    description: description,
    paymentMethod: paymentMethod,
    currency: currency,
  );
}

UserSettings historySettings() {
  return UserSettings.defaults(
    userId: 'user-1',
    updatedAt: DateTime(2026, 5, 1),
  ).copyWith(
    baseCurrency: 'EGP',
    supportedCurrencies: const ['EGP', 'USD'],
    conversionRates: const {'USD': 50},
  );
}
