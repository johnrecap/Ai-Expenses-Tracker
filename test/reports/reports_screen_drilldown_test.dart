import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/views/reports_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required DateTime date,
  required String description,
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: categoryName.hashCode,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryName,
    date: date,
    amount: 10,
    description: description,
  );
}

void main() {
  testWidgets('category drilldown opens expenses with report filter',
      (tester) async {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final food = _expense(
      id: 'food',
      categoryId: 'food',
      categoryName: 'Food',
      date: weekStart,
      description: 'weekly lunch',
    );
    final bills = _expense(
      id: 'bills',
      categoryId: 'bills',
      categoryName: 'Bills',
      date: weekStart,
      description: 'weekly bill',
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: ReportsScreen(
          expenses: [food, bills],
          settings: UserSettings.defaults(userId: 'user-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Food').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    expect(find.text('Report drilldown filter active'), findsOneWidget);
    expect(find.text('weekly lunch'), findsOneWidget);
    expect(find.text('weekly bill'), findsNothing);
  });
}
