import 'dart:io';
import 'dart:typed_data';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/expense_filter_service.dart';
import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportFormat {
  csv,
  excel,
  pdf;

  String get label {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

class ExportRequest {
  const ExportRequest({
    required this.startDate,
    required this.endDate,
    required this.format,
    this.categoryIds = const [],
    this.paymentMethods = const [],
    this.currency,
    this.labels = const ExportLabels(),
    this.settings,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ExportFormat format;
  final List<String> categoryIds;
  final List<PaymentMethod> paymentMethods;
  final String? currency;
  final ExportLabels labels;
  final UserSettings? settings;

  ExpenseFilter toFilter() {
    return ExpenseFilter(
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      categoryIds: categoryIds,
      paymentMethods: paymentMethods,
      currency: currency,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (endDate
        .isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
      errors.add('End date must be on or after start date.');
    }
    if (currency != null && currency!.trim().isEmpty) {
      errors.add('Currency filter must not be empty.');
    }
    return errors;
  }
}

class ExportLabels {
  const ExportLabels({
    this.pdfTitle = 'Expense Export',
    this.pdfPeriod = 'Period: {startDate} - {endDate}',
    this.pdfTotal = 'Total: {total}',
    this.dateHeader = 'date',
    this.amountHeader = 'amount',
    this.currencyHeader = 'currency',
    this.categoryHeader = 'category',
    this.paymentMethodHeader = 'paymentMethod',
    this.descriptionHeader = 'description',
    this.merchantHeader = 'merchant',
    this.tagsHeader = 'tags',
    this.convertedAmountHeader = 'convertedAmount',
    this.convertedCurrencyHeader = 'convertedCurrency',
    this.conversionRateHeader = 'conversionRate',
    this.conversionRateDateHeader = 'conversionRateDate',
    this.conversionStatusHeader = 'conversionStatus',
    this.conversionStatusOriginal = 'original',
    this.conversionStatusConverted = 'converted',
    this.conversionStatusMissingRate = 'missingRate',
    this.pdfConvertedTotal = 'Converted total: {total}',
    this.pdfMissingRates =
        'Missing rates for {currencies}; {count} row(s) not included.',
    this.pdfMissingRatesBuilder,
    this.arabicFontMissing =
        'PDF export needs the bundled Arabic font asset before it can run. '
            'Add assets/fonts/NotoSansArabic-Regular.ttf and regenerate assets.',
  });

  final String pdfTitle;
  final String pdfPeriod;
  final String pdfTotal;
  final String dateHeader;
  final String amountHeader;
  final String currencyHeader;
  final String categoryHeader;
  final String paymentMethodHeader;
  final String descriptionHeader;
  final String merchantHeader;
  final String tagsHeader;
  final String convertedAmountHeader;
  final String convertedCurrencyHeader;
  final String conversionRateHeader;
  final String conversionRateDateHeader;
  final String conversionStatusHeader;
  final String conversionStatusOriginal;
  final String conversionStatusConverted;
  final String conversionStatusMissingRate;
  final String pdfConvertedTotal;
  final String pdfMissingRates;
  final String Function({required int count, required String currencies})?
      pdfMissingRatesBuilder;
  final String arabicFontMissing;

  List<String> get headers => [
        dateHeader,
        amountHeader,
        currencyHeader,
        categoryHeader,
        paymentMethodHeader,
        descriptionHeader,
        merchantHeader,
        tagsHeader,
      ];

  List<String> get conversionHeaders => [
        convertedAmountHeader,
        convertedCurrencyHeader,
        conversionRateHeader,
        conversionRateDateHeader,
        conversionStatusHeader,
      ];

  String period(DateTime startDate, DateTime endDate) {
    return pdfPeriod
        .replaceAll('{startDate}', _exportDateKey(startDate))
        .replaceAll('{endDate}', _exportDateKey(endDate));
  }

  String total(String total) => pdfTotal.replaceAll('{total}', total);

  String convertedTotal(String total) =>
      pdfConvertedTotal.replaceAll('{total}', total);

  String missingRates({
    required int count,
    required String currencies,
  }) {
    final builder = pdfMissingRatesBuilder;
    if (builder != null) {
      return builder(count: count, currencies: currencies);
    }
    return pdfMissingRates
        .replaceAll('{count}', count.toString())
        .replaceAll('{currencies}', currencies);
  }
}

String _exportDateKey(DateTime date) {
  return [
    date.year.toString().padLeft(4, '0'),
    date.month.toString().padLeft(2, '0'),
    date.day.toString().padLeft(2, '0'),
  ].join('-');
}

class ExportResult {
  const ExportResult({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    this.path,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final String? path;
}

abstract class ExportService {
  Future<ExportResult> exportExpenses({
    required List<Expense> expenses,
    required ExportRequest request,
  });
}

class ExportFailureException implements Exception {
  const ExportFailureException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class ExportFileSharer {
  Future<String> save(ExportResult result);

  Future<void> share(ExportResult result);
}

class LocalExportFileSharer implements ExportFileSharer {
  const LocalExportFileSharer();

  @override
  Future<String> save(ExportResult result) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}${Platform.pathSeparator}${result.fileName}';
    final file = File(path);
    await file.writeAsBytes(result.bytes, flush: true);
    return path;
  }

  @override
  Future<void> share(ExportResult result) async {
    final path = result.path ?? await save(result);
    await Share.shareXFiles(
      [XFile(path, mimeType: result.mimeType, name: result.fileName)],
      subject: result.fileName,
    );
  }
}

abstract class ExpenseExportRows {
  static List<String> headers(ExportRequest request) => [
        ...request.labels.headers,
        if (request.settings != null) ...request.labels.conversionHeaders,
      ];

  static List<Expense> filteredExpenses(
    List<Expense> expenses,
    ExportRequest request,
  ) {
    return ExpenseFilterService.apply(expenses, request.toFilter())
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<Object?> rowFor(
    Expense expense, {
    ExportRequest? request,
  }) {
    return [
      _dateKey(expense.date),
      formatAmountInput(expense.amount),
      expense.currency,
      expense.categoryName.isNotEmpty
          ? expense.categoryName
          : expense.category.name,
      expense.paymentMethod.label,
      expense.description,
      expense.merchant ?? '',
      expense.tags.join('; '),
      if (request?.settings != null)
        ..._conversionColumns(
          expense: expense,
          settings: request!.settings!,
          labels: request.labels,
        ),
    ];
  }

  static ExportConversionSummary conversionSummary({
    required List<Expense> expenses,
    required ExportRequest request,
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) {
    final settings = request.settings;
    if (settings == null) return ExportConversionSummary.empty;
    final breakdown = calculationService.calculateExpenses(
      expenses: expenses,
      settings: settings,
    );
    return ExportConversionSummary(
      total: breakdown.total,
      baseCurrency: breakdown.baseCurrency,
      convertedCurrencies: breakdown.convertedCurrencies,
      unconvertedCurrencies: breakdown.unconvertedCurrencies,
      ignoredCurrencyCount: breakdown.ignoredCurrencyCount,
      rateUpdatedAt: breakdown.rateUpdatedAt,
    );
  }

  static String fileNameFor(ExportRequest request) {
    return 'expenses_${_dateKey(request.startDate)}_${_dateKey(request.endDate)}.${request.format.extension}';
  }

  static String _dateKey(DateTime date) {
    return [
      date.year.toString().padLeft(4, '0'),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
    ].join('-');
  }

  static List<Object?> _conversionColumns({
    required Expense expense,
    required UserSettings settings,
    required ExportLabels labels,
  }) {
    final baseCurrency = settings.baseCurrency.trim().toUpperCase();
    final sourceCurrency = expense.currency.trim().toUpperCase();
    if (sourceCurrency == baseCurrency) {
      return [
        formatAmountInput(expense.amount),
        baseCurrency,
        formatAmountInput(1),
        _nullableDateKey(settings.exchangeRatesUpdatedAt),
        labels.conversionStatusOriginal,
      ];
    }

    final rate = settings.conversionRates[sourceCurrency];
    if (rate == null || rate <= 0 || !rate.isFinite) {
      return [
        '',
        baseCurrency,
        '',
        _nullableDateKey(settings.exchangeRatesUpdatedAt),
        labels.conversionStatusMissingRate,
      ];
    }

    return [
      formatAmountInput(expense.amount * rate),
      baseCurrency,
      formatAmountInput(rate),
      _nullableDateKey(settings.exchangeRatesUpdatedAt),
      labels.conversionStatusConverted,
    ];
  }

  static String _nullableDateKey(DateTime? date) {
    if (date == null) return '';
    return _dateKey(date);
  }
}

class ExportConversionSummary {
  const ExportConversionSummary({
    required this.total,
    required this.baseCurrency,
    required this.convertedCurrencies,
    required this.unconvertedCurrencies,
    required this.ignoredCurrencyCount,
    required this.rateUpdatedAt,
  });

  static const empty = ExportConversionSummary(
    total: 0,
    baseCurrency: '',
    convertedCurrencies: [],
    unconvertedCurrencies: [],
    ignoredCurrencyCount: 0,
    rateUpdatedAt: null,
  );

  final double total;
  final String baseCurrency;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;
  final int ignoredCurrencyCount;
  final DateTime? rateUpdatedAt;

  bool get hasMetadata => baseCurrency.isNotEmpty;
  bool get hasUnconvertedCurrencies => ignoredCurrencyCount > 0;
}
