import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/export/export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combined export service routes to each supported format', () async {
    const service = ExpenseExportService();
    final expenses = [_expense(id: '1')];

    for (final format in ExportFormat.values) {
      final result = await service.exportExpenses(
        expenses: expenses,
        request: ExportRequest(
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 31),
          format: format,
        ),
      );

      expect(result.fileName.endsWith(format.extension), isTrue);
      expect(result.mimeType, format.mimeType);
      expect(result.bytes, isNotEmpty);
    }
  });
}

Expense _expense({required String id}) {
  final category = Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'food',
    color: 0xFFFFFFFF,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    date: DateTime(2026, 5, 15),
    amount: 120,
    description: 'Lunch',
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
  );
}
