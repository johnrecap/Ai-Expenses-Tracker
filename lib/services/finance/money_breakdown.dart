import 'package:expense_repository/expense_repository.dart';

class ConvertedMoneyRow {
  const ConvertedMoneyRow({
    required this.expense,
    required this.sourceAmount,
    required this.sourceCurrency,
    required this.baseCurrency,
    required this.convertedAmount,
    required this.rate,
    required this.rateUpdatedAt,
  });

  final Expense expense;
  final double sourceAmount;
  final String sourceCurrency;
  final String baseCurrency;
  final double convertedAmount;
  final double rate;
  final DateTime? rateUpdatedAt;

  bool get wasConverted => sourceCurrency != baseCurrency;
}

class MoneyBreakdown {
  const MoneyBreakdown({
    required this.total,
    required this.baseCurrency,
    required this.convertedRows,
    required this.unconvertedExpenses,
    required this.convertedCurrencies,
    required this.unconvertedCurrencies,
    required this.rateUpdatedAt,
  });

  final double total;
  final String baseCurrency;
  final List<ConvertedMoneyRow> convertedRows;
  final List<Expense> unconvertedExpenses;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;
  final DateTime? rateUpdatedAt;

  int get ignoredCurrencyCount => unconvertedExpenses.length;
  bool get hasConvertedCurrencies => convertedCurrencies.isNotEmpty;
  bool get hasUnconvertedCurrencies => unconvertedCurrencies.isNotEmpty;
  bool get hasMixedCurrencies =>
      convertedCurrencies.isNotEmpty || unconvertedCurrencies.isNotEmpty;

  List<Expense> get convertibleExpenses =>
      convertedRows.map((row) => row.expense).toList(growable: false);
}
