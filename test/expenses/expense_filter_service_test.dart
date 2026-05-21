import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/expense_filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required double amount,
  required DateTime date,
  required PaymentMethod paymentMethod,
  required String currency,
  String description = '',
  String? merchant,
  List<String> tags = const [],
  String? walletAccountId,
  String? walletAccountName,
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 1,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryName,
    date: date,
    amount: amount,
    description: description,
    merchant: merchant,
    tags: tags,
    paymentMethod: paymentMethod,
    currency: currency,
    walletAccountId: walletAccountId,
    walletAccountName: walletAccountName,
  );
}

void main() {
  final expenses = [
    _expense(
      id: '1',
      categoryId: 'food',
      categoryName: 'Food',
      amount: 250.50,
      date: DateTime(2026, 5, 15, 12),
      paymentMethod: PaymentMethod.cash,
      currency: 'EGP',
      description: 'lunch restaurant',
      walletAccountId: 'cash-wallet',
      walletAccountName: 'Cash wallet',
    ),
    _expense(
      id: '2',
      categoryId: 'transport',
      categoryName: 'مواصلات',
      amount: 180,
      date: DateTime(2026, 5, 16, 9),
      paymentMethod: PaymentMethod.wallet,
      currency: 'EGP',
      description: 'uber',
      merchant: 'Careem',
      tags: const ['commute'],
      walletAccountId: 'mobile-wallet',
      walletAccountName: 'Mobile wallet',
    ),
    _expense(
      id: '3',
      categoryId: 'bills',
      categoryName: 'Bills',
      amount: 40,
      date: DateTime(2026, 5, 16, 23, 59),
      paymentMethod: PaymentMethod.visa,
      currency: 'USD',
      description: 'internet',
      walletAccountId: 'card-wallet',
      walletAccountName: 'Visa card',
    ),
  ];

  test('combines query category date amount payment and currency filters', () {
    final result = ExpenseFilterService.apply(
      expenses,
      ExpenseFilter(
        query: 'restaurant',
        startDate: DateTime(2026, 5, 15),
        endDate: DateTime(2026, 5, 15),
        categoryIds: const ['food'],
        minAmount: 250.25,
        maxAmount: 250.75,
        paymentMethods: const [PaymentMethod.cash],
        currency: 'egp',
      ),
    );

    expect(result.map((expense) => expense.expenseId), ['1']);
  });

  test('matches decimal amount ranges without truncation', () {
    final result = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(
        minAmount: 40.25,
        maxAmount: 180.50,
      ),
    );

    expect(result.map((expense) => expense.expenseId), ['2']);
  });

  test('searches Arabic category names and payment method labels', () {
    final arabicResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'مواصلات'),
    );
    expect(arabicResult.map((expense) => expense.expenseId), ['2']);

    final paymentResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'visa'),
    );
    expect(paymentResult.map((expense) => expense.expenseId), ['3']);
  });

  test('searches merchant and tags', () {
    final merchantResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'careem'),
    );
    final tagResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'commute'),
    );

    expect(merchantResult.map((expense) => expense.expenseId), ['2']);
    expect(tagResult.map((expense) => expense.expenseId), ['2']);
  });

  test('filters and searches wallet snapshots', () {
    final walletResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(walletAccountId: 'mobile-wallet'),
    );
    final queryResult = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'visa card'),
    );

    expect(walletResult.map((expense) => expense.expenseId), ['2']);
    expect(queryResult.map((expense) => expense.expenseId), ['3']);
  });

  test('includes the full end date', () {
    final result = ExpenseFilterService.apply(
      expenses,
      ExpenseFilter(
        startDate: DateTime(2026, 5, 16),
        endDate: DateTime(2026, 5, 16),
      ),
    );

    expect(result.map((expense) => expense.expenseId), ['2', '3']);
  });

  test('returns empty list when no expenses match', () {
    final result = ExpenseFilterService.apply(
      expenses,
      const ExpenseFilter(query: 'groceries'),
    );

    expect(result, isEmpty);
  });

  test('applies search to the loaded expense scope only', () {
    final loadedRecentPage = [expenses.first];
    final result = ExpenseFilterService.apply(
      loadedRecentPage,
      const ExpenseFilter(query: 'internet'),
    );

    expect(result, isEmpty);
  });

  test('ExpenseFilter copyWith updates individual fields and supports equality',
      () {
    final filter = ExpenseFilter.empty.copyWith(
      query: 'food',
      categoryIds: const ['food'],
    );

    expect(
      filter,
      ExpenseFilter.empty.copyWith(
        query: 'food',
        categoryIds: const ['food'],
      ),
    );
    expect(filter.copyWith(query: 'bills').query, 'bills');
  });
}
