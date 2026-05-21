import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:expense_repository/expense_repository.dart';

import 'export_service.dart';

class ExcelExportService implements ExportService {
  const ExcelExportService();

  @override
  Future<ExportResult> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  }) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }

    final workbook = Excel.createExcel();
    const sheetName = 'Expenses';
    final sheet = workbook[sheetName];
    final defaultSheet = workbook.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.delete(defaultSheet);
    }

    _appendRow(sheet, ExpenseExportRows.headers(request));
    for (final expense
        in ExpenseExportRows.filteredExpenses(expenses, request)) {
      _appendRow(
        sheet,
        ExpenseExportRows.rowFor(
          expense,
          request: request,
        ),
      );
    }

    final bytes = workbook.save();
    if (bytes == null) {
      throw StateError('Could not generate Excel file.');
    }
    return ExportResult(
      fileName: ExpenseExportRows.fileNameFor(request),
      mimeType: request.format.mimeType,
      bytes: Uint8List.fromList(bytes),
    );
  }

  void _appendRow(Sheet sheet, List<Object?> values) {
    sheet.appendRow(
      values.map((value) {
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        return TextCellValue(value?.toString() ?? '');
      }).toList(),
    );
  }
}
