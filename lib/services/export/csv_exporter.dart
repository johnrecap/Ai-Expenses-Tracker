import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:expense_repository/expense_repository.dart';

import 'export_service.dart';

class CsvExportService implements ExportService {
  const CsvExportService();

  @override
  Future<ExportResult> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  }) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }

    final rows = [
      ExpenseExportRows.headers(request),
      ...ExpenseExportRows.filteredExpenses(expenses, request)
          .map((expense) => ExpenseExportRows.rowFor(
                expense,
                request: request,
              )),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(utf8.encode(csv));
    return ExportResult(
      fileName: ExpenseExportRows.fileNameFor(request),
      mimeType: request.format.mimeType,
      bytes: bytes,
    );
  }
}
