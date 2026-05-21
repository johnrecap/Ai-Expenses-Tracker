import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'export_service.dart';

typedef PdfFontLoader = Future<ByteData> Function(String assetPath);

class PdfExportService implements ExportService {
  const PdfExportService({
    this.fontAssetPath = 'assets/fonts/NotoSansArabic-Regular.ttf',
    PdfFontLoader? fontLoader,
  }) : _fontLoader = fontLoader;

  final String fontAssetPath;
  final PdfFontLoader? _fontLoader;

  @override
  Future<ExportResult> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  }) async {
    final errors = request.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }

    final filteredExpenses =
        ExpenseExportRows.filteredExpenses(expenses, request);
    final needsArabicFont = _containsArabic(filteredExpenses);
    final exportFont = await _loadExportFont(
      required: needsArabicFont,
      missingFontMessage: request.labels.arabicFontMissing,
    );
    final document = pw.Document();
    final totalByCurrency = <String, double>{};
    for (final expense in filteredExpenses) {
      totalByCurrency.update(
        expense.currency,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final conversionSummary = ExpenseExportRows.conversionSummary(
      expenses: filteredExpenses,
      request: request,
    );
    final totalLabel = totalByCurrency.entries
        .map((entry) => '${formatAmountInput(entry.value)} ${entry.key}')
        .join(', ');
    final documentDirection =
        needsArabicFont ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: exportFont == null
            ? null
            : pw.ThemeData.withFont(
                fontFallback: [exportFont],
              ),
        textDirection:
            needsArabicFont ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          pw.Text(
            request.labels.pdfTitle,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            textDirection: documentDirection,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            request.labels.period(request.startDate, request.endDate),
            textDirection: documentDirection,
          ),
          pw.Text(
            request.labels.total(totalLabel),
            textDirection: documentDirection,
          ),
          if (conversionSummary.hasMetadata) ...[
            pw.Text(
              request.labels.convertedTotal(
                '${formatAmountInput(conversionSummary.total)} '
                '${conversionSummary.baseCurrency}',
              ),
              textDirection: documentDirection,
            ),
            if (conversionSummary.hasUnconvertedCurrencies)
              pw.Text(
                request.labels.missingRates(
                  count: conversionSummary.ignoredCurrencyCount,
                  currencies:
                      conversionSummary.unconvertedCurrencies.join(', '),
                ),
                textDirection: documentDirection,
              ),
          ],
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            headers: ExpenseExportRows.headers(request),
            data: filteredExpenses
                .map(
                  (expense) => ExpenseExportRows.rowFor(
                    expense,
                    request: request,
                  )
                      .map((value) => _shorten(value?.toString() ?? ''))
                      .toList(),
                )
                .toList(),
          ),
        ],
      ),
    );

    return ExportResult(
      fileName: ExpenseExportRows.fileNameFor(request),
      mimeType: request.format.mimeType,
      bytes: Uint8List.fromList(await document.save()),
    );
  }

  String _shorten(String value) {
    if (value.length <= 120) return value;
    return '${value.substring(0, 117)}...';
  }

  bool _containsArabic(List<Expense> expenses) {
    final arabicPattern = RegExp('[\u0600-\u06FF]');
    return expenses.any((expense) {
      final values = ExpenseExportRows.rowFor(expense);
      return values.any((value) => arabicPattern.hasMatch('$value'));
    });
  }

  Future<pw.Font?> _loadExportFont({
    required bool required,
    required String missingFontMessage,
  }) async {
    try {
      final loader = _fontLoader ?? rootBundle.load;
      final bytes = await loader(fontAssetPath);
      return pw.Font.ttf(bytes);
    } catch (_) {
      if (!required) return null;
      throw ExportFailureException(missingFontMessage);
    }
  }
}
