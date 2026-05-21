import 'package:expense_repository/expense_repository.dart';

enum AiTargetMatchResolution {
  noMatch,
  singleStrongMatch,
  multipleCandidates,
}

class AiTargetMatch {
  final Expense expense;
  final double score;
  final List<String> matchedFields;
  final String reason;

  const AiTargetMatch({
    required this.expense,
    required this.score,
    required this.matchedFields,
    required this.reason,
  });
}

class AiTargetMatchResult {
  final AiTargetMatchResolution resolution;
  final List<AiTargetMatch> candidates;

  const AiTargetMatchResult({
    required this.resolution,
    required this.candidates,
  });

  AiTargetMatch? get selected =>
      resolution == AiTargetMatchResolution.singleStrongMatch
          ? candidates.first
          : null;

  bool get requiresManualSelection =>
      resolution == AiTargetMatchResolution.multipleCandidates;
}
