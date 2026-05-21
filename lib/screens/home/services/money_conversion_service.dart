import 'package:expense_repository/expense_repository.dart';

class MoneyConversionService {
  const MoneyConversionService();

  MoneyConversionResult convertExpense({
    required Expense expense,
    required UserSettings settings,
  }) {
    final baseCurrency = settings.baseCurrency.trim().toUpperCase();
    final sourceCurrency = expense.currency.trim().toUpperCase();
    if (sourceCurrency == baseCurrency) {
      return MoneyConversionResult.converted(
        amount: expense.amount,
        sourceCurrency: sourceCurrency,
        baseCurrency: baseCurrency,
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
  });

  factory MoneyConversionResult.converted({
    required double amount,
    required String sourceCurrency,
    required String baseCurrency,
  }) {
    return MoneyConversionResult._(
      convertedAmount: amount,
      sourceCurrency: sourceCurrency,
      baseCurrency: baseCurrency,
      wasConverted: sourceCurrency != baseCurrency,
      isConvertible: true,
    );
  }

  factory MoneyConversionResult.unconverted({
    required String sourceCurrency,
    required String baseCurrency,
  }) {
    return MoneyConversionResult._(
      convertedAmount: 0,
      sourceCurrency: sourceCurrency,
      baseCurrency: baseCurrency,
      wasConverted: false,
      isConvertible: false,
    );
  }

  final double convertedAmount;
  final String sourceCurrency;
  final String baseCurrency;
  final bool wasConverted;
  final bool isConvertible;
}
