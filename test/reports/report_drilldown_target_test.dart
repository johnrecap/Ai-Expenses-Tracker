import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/models/report_drilldown_target.dart';
import 'package:expenses_tracker/services/expense_filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required DateTime date,
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryId,
    totalExpenses: 0,
    icon: 'food',
    color: 1,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryId,
    date: date,
    amount: 10,
  );
}

void main() {
  test('bucket target filters expenses inside bucket dates', () {
    final target = ReportDrilldownTarget.bucket(
      range: ReportRange.weekly(anchorDate: DateTime(2026, 5, 13)),
      bucket: ReportBucket(
        label: 'Wed',
        startDate: DateTime(2026, 5, 13),
        endDate: DateTime(2026, 5, 13, 23, 59, 59, 999),
        total: 10,
      ),
    );

    final result = ExpenseFilterService.apply(
      [
        _expense(id: 'before', categoryId: 'food', date: DateTime(2026, 5, 12)),
        _expense(id: 'match', categoryId: 'food', date: DateTime(2026, 5, 13)),
        _expense(
          id: 'after',
          categoryId: 'food',
          date: DateTime(2026, 5, 14),
        ),
      ],
      target.filter,
    );

    expect(target.kind, ReportDrilldownKind.bucket);
    expect(result.map((expense) => expense.expenseId), ['match']);
  });

  test('category target filters report period and category', () {
    final target = ReportDrilldownTarget.category(
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 20)),
      category: const CategoryReportTotal(
        categoryId: 'food',
        categoryName: 'Food',
        categoryIcon: 'food',
        categoryColor: 1,
        total: 20,
      ),
    );

    final result = ExpenseFilterService.apply(
      [
        _expense(id: 'match', categoryId: 'food', date: DateTime(2026, 5, 13)),
        _expense(id: 'other', categoryId: 'bills', date: DateTime(2026, 5, 13)),
        _expense(id: 'old', categoryId: 'food', date: DateTime(2026, 4, 30)),
      ],
      target.filter,
    );

    expect(target.kind, ReportDrilldownKind.category);
    expect(target.filter.categoryIds, ['food']);
    expect(result.map((expense) => expense.expenseId), ['match']);
  });
}
