class AiPredictionPayload {
  const AiPredictionPayload({
    required this.period,
    required this.expectedTotal,
    required this.currency,
    required this.categoryDrivers,
    required this.qualityNote,
    required this.generatedAt,
  });

  final String period;
  final double expectedTotal;
  final String currency;
  final List<AiPredictionCategoryDriver> categoryDrivers;
  final String qualityNote;
  final DateTime generatedAt;
}

class AiPredictionCategoryDriver {
  const AiPredictionCategoryDriver({
    required this.category,
    required this.expectedAmount,
    required this.historyCount,
  });

  final String category;
  final double expectedAmount;
  final int historyCount;
}
