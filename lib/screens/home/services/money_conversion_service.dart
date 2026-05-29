import 'package:expense_repository/expense_repository.dart';

class MoneyConversionService {
  const MoneyConversionService();

  MoneyConversionResult convertExpense({
    required Expense expense,
    required UserSettings settings,
  }) {
    final baseCurrency = settings.baseCurrency.trim().toUpperCase();
    final sourceCurrency = expense.currency.trim().toUpperCase();
    final snapshot = expense.moneySnapshot;
    if (snapshot != null) {
      final snapshotSource = snapshot.sourceCurrency.trim().toUpperCase();
      final snapshotTarget = snapshot.targetCurrency.trim().toUpperCase();
      if (snapshot.isValid &&
          snapshot.matchesSource(
            amount: expense.amount,
            currency: sourceCurrency,
          ) &&
          snapshotTarget == baseCurrency) {
        return MoneyConversionResult.converted(
          amount: snapshot.convertedAmount,
          sourceCurrency: snapshotSource,
          baseCurrency: snapshotTarget,
          rate: snapshot.conversionRate,
          rateUpdatedAt: snapshot.rateUpdatedAt,
          usedSnapshot: true,
        );
      }
      if (snapshotTarget != baseCurrency) {
        return MoneyConversionResult.unconverted(
          sourceCurrency: snapshotSource,
          baseCurrency: baseCurrency,
          usedSnapshot: true,
        );
      }
      return MoneyConversionResult.unconverted(
        sourceCurrency: snapshotSource.isEmpty ? sourceCurrency : snapshotSource,
        baseCurrency: baseCurrency,
        usedSnapshot: true,
      );
    }

    if (sourceCurrency == baseCurrency) {
      return MoneyConversionResult.converted(
        amount: expense.amount,
        sourceCurrency: sourceCurrency,
        baseCurrency: baseCurrency,
        rate: 1,
        rateUpdatedAt: settings.exchangeRatesUpdatedAt,
      );
    }

    final rate = settings.conversionRates[sourceCurrency];
    if (rate == null || rate <= 0) {
      return MoneyConversionResult.unconverted(
        sourceCurrency: sourceCurrency,
        baseCurrency: baseCurrency,
      );
    }

    return MoneyConversionResult.converted(
      amount: expense.amount * rate,
      sourceCurrency: sourceCurrency,
      baseCurrency: baseCurrency,
      rate: rate.toDouble(),
      rateUpdatedAt: settings.exchangeRatesUpdatedAt,
    );
  }
}

class MoneyConversionResult {
  const MoneyConversionResult._({
    required this.convertedAmount,
    required this.sourceCurrency,
    required this.baseCurrency,
    required this.wasConverted,
    required this.isConvertible,
    required this.rate,
    required this.rateUpdatedAt,
    required this.usedSnapshot,
  });

  factory MoneyConversionResult.converted({
    required double amount,
    required String sourceCurrency,
    required String baseCurrency,
    double? rate,
    DateTime? rateUpdatedAt,
    bool usedSnapshot = false,
  }) {
    return MoneyConversionResult._(
      convertedAmount: amount,
      sourceCurrency: sourceCurrency,
      baseCurrency: baseCurrency,
      wasConverted: sourceCurrency != baseCurrency,
      isConvertible: true,
      rate: rate,
      rateUpdatedAt: rateUpdatedAt,
      usedSnapshot: usedSnapshot,
    );
  }

  factory MoneyConversionResult.unconverted({
    required String sourceCurrency,
    required String baseCurrency,
    bool usedSnapshot = false,
  }) {
    return MoneyConversionResult._(
      convertedAmount: 0,
      sourceCurrency: sourceCurrency,
      baseCurrency: baseCurrency,
      wasConverted: false,
      isConvertible: false,
      rate: null,
      rateUpdatedAt: null,
      usedSnapshot: usedSnapshot,
    );
  }

  final double convertedAmount;
  final String sourceCurrency;
  final String baseCurrency;
  final bool wasConverted;
  final bool isConvertible;
  final double? rate;
  final DateTime? rateUpdatedAt;
  final bool usedSnapshot;
}
