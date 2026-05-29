import 'package:expense_repository/expense_repository.dart';

class MoneySnapshotService {
  const MoneySnapshotService();

  MoneySnapshotResult snapshotForExpense({
    required Expense expense,
    required UserSettings settings,
    DateTime? capturedAt,
  }) {
    final sourceCurrency = _normalize(expense.currency);
    final targetCurrency = _normalize(settings.baseCurrency);
    if (sourceCurrency.isEmpty || targetCurrency.isEmpty) {
      return MoneySnapshotResult.missingRate(sourceCurrency: sourceCurrency);
    }

    final rate = sourceCurrency == targetCurrency
        ? 1.0
        : _validRate(settings.conversionRates[sourceCurrency]);
    if (rate == null) {
      return MoneySnapshotResult.missingRate(sourceCurrency: sourceCurrency);
    }

    return MoneySnapshotResult.created(
      MoneySnapshot(
        sourceAmount: expense.amount,
        sourceCurrency: sourceCurrency,
        targetCurrency: targetCurrency,
        conversionRate: rate,
        convertedAmount: expense.amount * rate,
        capturedAt: capturedAt ?? DateTime.now(),
        rateUpdatedAt: settings.exchangeRatesUpdatedAt,
        rateSource: sourceCurrency == targetCurrency
            ? 'identity'
            : MoneySnapshot.defaultRateSource,
        rateFreshness: settings.exchangeRatesUpdatedAt == null
            ? 'unknown'
            : MoneySnapshot.defaultRateFreshness,
      ),
    );
  }

  Expense preserveOrRefreshForEdit({
    required Expense previous,
    required Expense next,
    required UserSettings settings,
    DateTime? capturedAt,
  }) {
    if (!_moneyInputsChanged(previous, next)) {
      return next.withMoneySnapshot(previous.moneySnapshot);
    }

    final result = snapshotForExpense(
      expense: next,
      settings: settings,
      capturedAt: capturedAt,
    );
    return next.withMoneySnapshot(result.snapshot);
  }

  bool _moneyInputsChanged(Expense previous, Expense next) {
    return previous.amount != next.amount ||
        _normalize(previous.currency) != _normalize(next.currency) ||
        DateTime(previous.date.year, previous.date.month, previous.date.day) !=
            DateTime(next.date.year, next.date.month, next.date.day);
  }

  double? _validRate(num? rate) {
    if (rate == null) return null;
    final normalized = rate.toDouble();
    if (normalized <= 0 || !normalized.isFinite) return null;
    return normalized;
  }

  String _normalize(String value) => value.trim().toUpperCase();
}

class MoneySnapshotResult {
  const MoneySnapshotResult._({
    required this.snapshot,
    required this.missingCurrency,
  });

  factory MoneySnapshotResult.created(MoneySnapshot snapshot) {
    return MoneySnapshotResult._(
      snapshot: snapshot,
      missingCurrency: null,
    );
  }

  factory MoneySnapshotResult.missingRate({required String sourceCurrency}) {
    return MoneySnapshotResult._(
      snapshot: null,
      missingCurrency: sourceCurrency,
    );
  }

  final MoneySnapshot? snapshot;
  final String? missingCurrency;

  bool get hasSnapshot => snapshot != null;
}
