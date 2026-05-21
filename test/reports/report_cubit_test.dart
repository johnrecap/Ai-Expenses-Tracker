import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/cubit/report_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads weekly and monthly reports', () async {
    final expense = Expense(
      expenseId: 'expense-1',
      category: Category(
        categoryId: 'food',
        name: 'Food',
        totalExpenses: 0,
        icon: 'food',
        color: 1,
      ),
      categoryId: 'food',
      categoryName: 'Food',
      date: DateTime.now(),
      amount: 100,
      currency: 'EGP',
    );
    final cubit = ReportCubit(
      expenses: [expense],
      settings: UserSettings.defaults(userId: 'user-1'),
    );

    cubit.loadWeekly();
    expect(cubit.state, isA<ReportLoaded>());

    cubit.loadMonthly();
    expect(cubit.state, isA<ReportLoaded>());

    await cubit.close();
  });

  test('loads reports with converted mixed-currency totals', () async {
    final usdExpense = Expense(
      expenseId: 'expense-usd',
      category: Category(
        categoryId: 'subscriptions',
        name: 'Subscriptions',
        totalExpenses: 0,
        icon: 'subscriptions',
        color: 1,
      ),
      categoryId: 'subscriptions',
      categoryName: 'Subscriptions',
      date: DateTime.now(),
      amount: 50,
      currency: 'USD',
    );
    final cubit = ReportCubit(
      expenses: [usdExpense],
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
    );

    cubit.loadWeekly();
    final state = cubit.state;

    expect(state, isA<ReportLoaded>());
    expect((state as ReportLoaded).report.total, 2500);
    expect(state.report.convertedCurrencies, ['USD']);
    expect(state.report.ignoredCurrencyCount, 0);

    await cubit.close();
  });
}
