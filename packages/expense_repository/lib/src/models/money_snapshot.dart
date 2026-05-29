class MoneySnapshot {
  const MoneySnapshot({
    required this.sourceAmount,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.conversionRate,
    required this.convertedAmount,
    required this.capturedAt,
    this.rateUpdatedAt,
    this.rateSource = defaultRateSource,
    this.rateFreshness = defaultRateFreshness,
  });

  static const defaultRateSource = 'settings';
  static const defaultRateFreshness = 'saved';

  final double sourceAmount;
  final String sourceCurrency;
  final String targetCurrency;
  final double conversionRate;
  final double convertedAmount;
  final DateTime capturedAt;
  final DateTime? rateUpdatedAt;
  final String rateSource;
  final String rateFreshness;

  bool get isValid =>
      sourceAmount.isFinite &&
      convertedAmount.isFinite &&
      conversionRate.isFinite &&
      sourceAmount >= 0 &&
      convertedAmount >= 0 &&
      conversionRate > 0 &&
      sourceCurrency.trim().isNotEmpty &&
      targetCurrency.trim().isNotEmpty;

  bool matchesSource({
    required num amount,
    required String currency,
  }) {
    return sourceAmount == amount.toDouble() &&
        sourceCurrency.trim().toUpperCase() == currency.trim().toUpperCase();
  }

  bool targets(String currency) {
    return targetCurrency.trim().toUpperCase() == currency.trim().toUpperCase();
  }

  MoneySnapshot copyWith({
    num? sourceAmount,
    String? sourceCurrency,
    String? targetCurrency,
    num? conversionRate,
    num? convertedAmount,
    DateTime? capturedAt,
    DateTime? rateUpdatedAt,
    bool clearRateUpdatedAt = false,
    String? rateSource,
    String? rateFreshness,
  }) {
    return MoneySnapshot(
      sourceAmount: sourceAmount?.toDouble() ?? this.sourceAmount,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      conversionRate: conversionRate?.toDouble() ?? this.conversionRate,
      convertedAmount: convertedAmount?.toDouble() ?? this.convertedAmount,
      capturedAt: capturedAt ?? this.capturedAt,
      rateUpdatedAt:
          clearRateUpdatedAt ? null : rateUpdatedAt ?? this.rateUpdatedAt,
      rateSource: rateSource ?? this.rateSource,
      rateFreshness: rateFreshness ?? this.rateFreshness,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MoneySnapshot &&
            other.sourceAmount == sourceAmount &&
            other.sourceCurrency == sourceCurrency &&
            other.targetCurrency == targetCurrency &&
            other.conversionRate == conversionRate &&
            other.convertedAmount == convertedAmount &&
            other.capturedAt == capturedAt &&
            other.rateUpdatedAt == rateUpdatedAt &&
            other.rateSource == rateSource &&
            other.rateFreshness == rateFreshness;
  }

  @override
  int get hashCode => Object.hash(
        sourceAmount,
        sourceCurrency,
        targetCurrency,
        conversionRate,
        convertedAmount,
        capturedAt,
        rateUpdatedAt,
        rateSource,
        rateFreshness,
      );
}
