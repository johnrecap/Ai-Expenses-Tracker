import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBudgetRepository implements BudgetRepository {
  Budget? budget;
  bool fail = false;

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async {
    if (fail) throw Exception('failed');
    return budget;
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    if (fail) throw Exception('failed');
    this.budget = budget;
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    if (fail) return Stream<Budget?>.error(Exception('failed'));
    return Stream.value(budget);
  }
}

Budget _budget() {
  return Budget(
    budgetId: '2026-05',
    userId: 'user-1',
    month: 5,
    year: 2026,
    amount: 1000,
    currency: 'EGP',
    warningThresholdPercent: 80,
    createdAt: DateTime(2026, 5),
    updatedAt: DateTime(2026, 5),
  );
}

void main() {
  test('loads current month budget successfully', () async {
    final repository = FakeBudgetRepository()..budget = _budget();
    final bloc = BudgetBloc(repository);
    final loaded = expectLater(
      bloc.stream,
      emitsThrough(isA<BudgetLoaded>()),
    );

    bloc.add(const BudgetLoadRequested(month: 5, year: 2026));

    await loaded;
    await bloc.close();
  });

  test('saves budget successfully', () async {
    final repository = FakeBudgetRepository();
    final bloc = BudgetBloc(repository);
    final saved = expectLater(
      bloc.stream,
      emitsThrough(isA<BudgetSaved>()),
    );

    bloc.add(BudgetSaveRequested(_budget()));

    await saved;
    expect(repository.budget?.amount, 1000);

    await bloc.close();
  });

  test('emits failure when repository throws', () async {
    final repository = FakeBudgetRepository()..fail = true;
    final bloc = BudgetBloc(repository);
    final failure = expectLater(
      bloc.stream,
      emitsThrough(isA<BudgetFailure>()),
    );

    bloc.add(const BudgetLoadRequested(month: 5, year: 2026));

    await failure;
    await bloc.close();
  });
}
