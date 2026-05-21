import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/engagement/widgets/weekly_digest_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

void main() {
  testWidgets('renders weekly digest copy in English', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: WeeklyDigestScreen(
          digest: _digest(),
          healthScore: _healthScore(),
        ),
      ),
    );

    expect(find.text('Weekly digest'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Local insight'), findsOneWidget);
    expect(find.textContaining('saved rate'), findsOneWidget);
  });

  testWidgets('renders weekly digest copy in Arabic without English labels',
      (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale('ar'),
        home: WeeklyDigestScreen(
          digest: _digest(),
          healthScore: _healthScore(),
        ),
      ),
    );

    expect(find.text('Weekly digest'), findsNothing);
    expect(find.text('This week'), findsNothing);
    expect(find.text('Local insight'), findsNothing);
    expect(find.text('ملخص أسبوعي'), findsOneWidget);
  });
}

WeeklyDigest _digest() {
  const topCategory = CategoryReportTotal(
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'food',
    categoryColor: 0xFF000000,
    total: 250,
  );
  return WeeklyDigest(
    insight: 'Food is your largest category this week.',
    report: ExpenseReport(
      range: ReportRange.weekly(anchorDate: DateTime(2026, 5, 20)),
      currency: 'EGP',
      total: 400,
      buckets: const [],
      categoryTotals: const [topCategory],
      topCategory: topCategory,
      previousTotal: 300,
      deltaPercent: 33,
      ignoredCurrencyCount: 1,
      unconvertedCurrencies: const ['USD'],
    ),
  );
}

SpendingHealthScore _healthScore() {
  return const SpendingHealthScore(
    score: 72,
    status: SpendingHealthStatus.watch,
    label: 'Worth watching',
    reasons: ['Monthly budget is near its limit.'],
  );
}
