enum SpendingHealthStatus {
  insufficientData,
  good,
  watch,
  risk,
}

class SpendingHealthScore {
  final int score;
  final SpendingHealthStatus status;
  final String label;
  final List<String> reasons;

  const SpendingHealthScore({
    required this.score,
    required this.status,
    required this.label,
    required this.reasons,
  });

  bool get hasEnoughData => status != SpendingHealthStatus.insufficientData;
}
