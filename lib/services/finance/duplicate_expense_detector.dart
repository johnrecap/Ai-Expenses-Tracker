import 'package:expense_repository/expense_repository.dart';

enum DuplicateExpenseReason {
  sameDay,
  sameAmount,
  sameCategory,
  sameMerchant,
}

class DuplicateExpenseCandidate {
  const DuplicateExpenseCandidate({
    required this.expense,
    required this.score,
    required this.reasons,
  });

  final Expense expense;
  final double score;
  final List<DuplicateExpenseReason> reasons;

  bool get isLikelyDuplicate => score >= 0.75;
}

class DuplicateExpenseDetector {
  const DuplicateExpenseDetector({
    this.amountTolerance = 0.01,
    this.amountTolerancePercent = 0.02,
    this.warningThreshold = 0.75,
  });

  final double amountTolerance;
  final double amountTolerancePercent;
  final double warningThreshold;

  List<DuplicateExpenseCandidate> findCandidates({
    required Expense draft,
    required List<Expense> existingExpenses,
  }) {
    final candidates = <DuplicateExpenseCandidate>[];
    for (final existing in existingExpenses) {
      if (existing.expenseId == draft.expenseId) continue;
      final candidate = _score(draft, existing);
      if (candidate != null && candidate.score >= warningThreshold) {
        candidates.add(candidate);
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates;
  }

  DuplicateExpenseCandidate? bestCandidate({
    required Expense draft,
    required List<Expense> existingExpenses,
  }) {
    final candidates = findCandidates(
      draft: draft,
      existingExpenses: existingExpenses,
    );
    return candidates.isEmpty ? null : candidates.first;
  }

  DuplicateExpenseCandidate? _score(Expense draft, Expense existing) {
    if (!_sameLocalDay(draft.date, existing.date)) return null;
    if (draft.currency.toUpperCase() != existing.currency.toUpperCase()) {
      return null;
    }

    var score = 0.25;
    final reasons = <DuplicateExpenseReason>[DuplicateExpenseReason.sameDay];

    final amountDelta = (draft.amount - existing.amount).abs();
    final relativeTolerance = draft.amount.abs() * amountTolerancePercent;
    if (amountDelta <= amountTolerance ||
        amountDelta <= relativeTolerance) {
      score += 0.35;
      reasons.add(DuplicateExpenseReason.sameAmount);
    }

    if (_sameCategory(draft, existing)) {
      score += 0.25;
      reasons.add(DuplicateExpenseReason.sameCategory);
    }

    if (_sameMerchant(draft, existing)) {
      score += 0.2;
      reasons.add(DuplicateExpenseReason.sameMerchant);
    }

    if (!reasons.contains(DuplicateExpenseReason.sameMerchant) &&
        _sameDescription(draft, existing)) {
      score += 0.1;
    }

    return DuplicateExpenseCandidate(
      expense: existing,
      score: score.clamp(0, 1).toDouble(),
      reasons: List.unmodifiable(reasons),
    );
  }

  bool _sameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _sameCategory(Expense a, Expense b) {
    final aId = a.categoryId.trim();
    final bId = b.categoryId.trim();
    if (aId.isNotEmpty && bId.isNotEmpty) return aId == bId;
    final aName = a.categoryName.isNotEmpty ? a.categoryName : a.category.name;
    final bName = b.categoryName.isNotEmpty ? b.categoryName : b.category.name;
    final normalizedA = _normalize(aName);
    final normalizedB = _normalize(bName);
    return normalizedA.isNotEmpty && normalizedA == normalizedB;
  }

  bool _sameMerchant(Expense a, Expense b) {
    final merchantA = _normalize(a.merchant);
    final merchantB = _normalize(b.merchant);
    return merchantA.isNotEmpty && merchantA == merchantB;
  }

  bool _sameDescription(Expense a, Expense b) {
    final descriptionA = _normalize(a.description);
    final descriptionB = _normalize(b.description);
    return descriptionA.isNotEmpty && descriptionA == descriptionB;
  }

  String _normalize(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
