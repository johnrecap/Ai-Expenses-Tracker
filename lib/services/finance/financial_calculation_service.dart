import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/services/money_conversion_service.dart';

import 'money_breakdown.dart';

class FinancialCalculationService {
  const FinancialCalculationService({
    MoneyConversionService conversionService = const MoneyConversionService(),
  }) : _conversionService = conversionService;

  final MoneyConversionService _conversionService;

  MoneyBreakdown calculateExpenses({
    required Iterable<Expense> expenses,
    required UserSettings settings,
    bool Function(Expense expense)? where,
  }) {
    final baseCurrency = settings.baseCurrency.trim().toUpperCase();
    final convertedRows = <ConvertedMoneyRow>[];
    final unconvertedExpenses = <Expense>[];
    final convertedCurrencies = <String>{};
    final unconvertedCurrencies = <String>{};

    for (final expense in expenses) {
      if (where != null && !where(expense)) continue;

      final conversion = _conversionService.convertExpense(
        expense: expense,
        settings: settings,
      );
      if (!conversion.isConvertible) {
        unconvertedExpenses.add(expense);
        unconvertedCurrencies.add(conversion.sourceCurrency);
        continue;
      }

      final sourceCurrency = conversion.sourceCurrency;
      final rate = sourceCurrency == baseCurrency
          ? 1.0
          : _validRate(settings.conversionRates[sourceCurrency]);
      if (rate == null) {
        unconvertedExpenses.add(expense);
        unconvertedCurrencies.add(sourceCurrency);
        continue;
      }

      if (conversion.wasConverted) {
        convertedCurrencies.add(sourceCurrency);
      }
      convertedRows.add(
        ConvertedMoneyRow(
          expense: expense,
          sourceAmount: expense.amount,
          sourceCurrency: sourceCurrency,
          baseCurrency: baseCurrency,
          convertedAmount: conversion.convertedAmount,
          rate: rate,
          rateUpdatedAt: settings.exchangeRatesUpdatedAt,
        ),
      );
    }

    return MoneyBreakdown(
      total: convertedRows.fold<double>(
        0,
        (sum, row) => sum + row.convertedAmount,
      ),
      baseCurrency: baseCurrency,
      convertedRows: List.unmodifiable(convertedRows),
      unconvertedExpenses: List.unmodifiable(unconvertedExpenses),
      convertedCurrencies: _sorted(convertedCurrencies),
      unconvertedCurrencies: _sorted(unconvertedCurrencies),
      rateUpdatedAt: settings.exchangeRatesUpdatedAt,
    );
  }

  double? _validRate(num? rate) {
    if (rate == null) return null;
    final normalized = rate.toDouble();
    if (normalized <= 0 || !normalized.isFinite) return null;
    return normalized;
  }

  List<String> _sorted(Set<String> currencies) {
    return List.unmodifiable(currencies.toList()..sort());
  }
}
