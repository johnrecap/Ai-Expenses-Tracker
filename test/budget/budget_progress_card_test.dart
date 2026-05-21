import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/budget/widgets/budget_progress_card.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('renders budget progress copy in English', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: BudgetProgressCard(
            progress: _progress(BudgetProgressStatus.nearLimit),
            onManage: () {},
          ),
        ),
      ),
    );

    expect(find.text('Monthly Budget'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('You are close to your budget limit.'), findsOneWidget);
    expect(find.textContaining('saved rate'), findsOneWidget);
  });

  testWidgets('renders budget progress copy in Arabic without English labels',
      (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale('ar'),
        home: Scaffold(
          body: BudgetProgressCard(
            progress: _progress(BudgetProgressStatus.exceeded),
            onManage: () {},
          ),
        ),
      ),
    );

    expect(find.text('Monthly Budget'), findsNothing);
    expect(find.text('Spent'), findsNothing);
    expect(find.text('Remaining'), findsNothing);
    expect(find.text('الميزانية الشهرية'), findsOneWidget);
    expect(find.text('تم تجاوز الميزانية.'), findsOneWidget);
  });
}

BudgetProgress _progress(BudgetProgressStatus status) {
  final now = DateTime(2026, 5, 20);
  return BudgetProgress(
    budget: Budget(
      budgetId: '2026-05',
      userId: 'user-1',
      month: 5,
      year: 2026,
      amount: 1000,
      currency: 'EGP',
      warningThresholdPercent: 80,
      createdAt: now,
      updatedAt: now,
    ),
    spent: status == BudgetProgressStatus.exceeded ? 1100 : 850,
    remaining: status == BudgetProgressStatus.exceeded ? -100 : 150,
    percentUsed: status == BudgetProgressStatus.exceeded ? 1.1 : 0.85,
    ignoredCurrencyCount: 1,
    status: status,
  );
}
