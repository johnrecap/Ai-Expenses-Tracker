import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/export/export_service.dart';
import 'package:expenses_tracker/services/export/pdf_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Arabic PDF export loads the bundled font and writes bytes', () async {
    const service = PdfExportService();
    final request = ExportRequest(
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 31),
      format: ExportFormat.pdf,
    );

    final result = await service.exportExpenses(
      expenses: [_arabicExpense()],
      request: request,
    );

    expect(result.mimeType, ExportFormat.pdf.mimeType);
    expect(result.fileName, 'expenses_2026-05-01_2026-05-31.pdf');
    expect(result.bytes.length, greaterThan(1000));
  });

  test('Arabic PDF export reports a friendly font setup failure', () async {
    final service = PdfExportService(
      fontLoader: (_) => throw Exception('missing font asset'),
    );
    final request = ExportRequest(
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 31),
      format: ExportFormat.pdf,
    );

    expect(
      () => service.exportExpenses(
        expenses: [_arabicExpense()],
        request: request,
      ),
      throwsA(
        isA<ExportFailureException>().having(
          (error) => error.message,
          'message',
          contains('Arabic font'),
        ),
      ),
    );
  });
}

Expense _arabicExpense() {
  return Expense(
    expenseId: 'expense-1',
    userId: 'user-1',
    category: Category(
      categoryId: 'transport',
      userId: 'user-1',
      name: '\u0645\u0648\u0627\u0635\u0644\u0627\u062a',
      totalExpenses: 0,
      icon: 'directions_bus',
      color: 0xff2563eb,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    ),
    date: DateTime(2026, 5, 18),
    amount: 100,
    description:
        '\u0645\u0635\u0631\u0648\u0641 \u0645\u0648\u0627\u0635\u0644\u0627\u062a',
  );
}
