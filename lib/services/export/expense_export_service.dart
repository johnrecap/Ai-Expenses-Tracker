import 'package:expense_repository/expense_repository.dart';

import 'csv_exporter.dart';
import 'excel_exporter.dart';
import 'export_service.dart';
import 'pdf_exporter.dart';

class ExpenseExportService implements ExportService {
  const ExpenseExportService({
    CsvExportService csvExporter = const CsvExportService(),
    ExcelExportService excelExporter = const ExcelExportService(),
    PdfExportService pdfExporter = const PdfExportService(),
  })  : _csvExporter = csvExporter,
        _excelExporter = excelExporter,
        _pdfExporter = pdfExporter;

  final CsvExportService _csvExporter;
  final ExcelExportService _excelExporter;
  final PdfExportService _pdfExporter;

  @override
  Future<ExportResult> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  }) {
    switch (request.format) {
      case ExportFormat.csv:
        return _csvExporter.exportExpenses(
            expenses: expenses, request: request);
      case ExportFormat.excel:
        return _excelExporter.exportExpenses(
            expenses: expenses, request: request);
      case ExportFormat.pdf:
        return _pdfExporter.exportExpenses(
            expenses: expenses, request: request);
    }
  }
}
