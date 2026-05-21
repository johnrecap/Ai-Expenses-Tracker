import 'package:expense_repository/expense_repository.dart';

class ExpenseFilterService {
  const ExpenseFilterService._();

  static List<Expense> apply(
    List<Expense> expenses,
    ExpenseFilter filter,
  ) {
    final normalizedQuery = filter.query.trim().toLowerCase();
    final normalizedCurrency = filter.currency?.trim().toUpperCase();
    final normalizedWalletId = filter.walletAccountId?.trim();
    final endDate = filter.endDate == null
        ? null
        : DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
            23,
            59,
            59,
            999,
          );
    final startDate = filter.startDate == null
        ? null
        : DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          );

    return expenses.where((expense) {
      return _matchesQuery(expense, normalizedQuery) &&
          _matchesDate(expense, startDate, endDate) &&
          _matchesCategory(expense, filter.categoryIds) &&
          _matchesAmount(expense, filter.minAmount, filter.maxAmount) &&
          _matchesPayment(expense, filter.paymentMethods) &&
          _matchesCurrency(expense, normalizedCurrency) &&
          _matchesWallet(expense, normalizedWalletId);
    }).toList();
  }

  static bool _matchesQuery(Expense expense, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;

    final values = [
      expense.description,
      expense.merchant ?? '',
      ...expense.tags,
      expense.categoryName,
      expense.category.name,
      expense.paymentMethod.label,
      expense.paymentMethod.storageValue,
      expense.currency,
      expense.walletAccountName ?? '',
      expense.walletAccountId ?? '',
    ];

    return values.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  static bool _matchesDate(
    Expense expense,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && expense.date.isBefore(startDate)) return false;
    if (endDate != null && expense.date.isAfter(endDate)) return false;
    return true;
  }

  static bool _matchesCategory(Expense expense, List<String> categoryIds) {
    if (categoryIds.isEmpty) return true;
    if (expense.categoryId.isNotEmpty) {
      return categoryIds.contains(expense.categoryId);
    }
    return categoryIds.contains(expense.categoryName) ||
        categoryIds.contains(expense.category.name);
  }

  static bool _matchesAmount(
    Expense expense,
    num? minAmount,
    num? maxAmount,
  ) {
    if (minAmount != null && expense.amount < minAmount) return false;
    if (maxAmount != null && expense.amount > maxAmount) return false;
    return true;
  }

  static bool _matchesPayment(
    Expense expense,
    List<PaymentMethod> paymentMethods,
  ) {
    return paymentMethods.isEmpty ||
        paymentMethods.contains(expense.paymentMethod);
  }

  static bool _matchesCurrency(Expense expense, String? normalizedCurrency) {
    if (normalizedCurrency == null || normalizedCurrency.isEmpty) return true;
    return expense.currency.toUpperCase() == normalizedCurrency;
  }

  static bool _matchesWallet(Expense expense, String? walletAccountId) {
    if (walletAccountId == null || walletAccountId.isEmpty) return true;
    return expense.walletAccountId == walletAccountId;
  }
}
