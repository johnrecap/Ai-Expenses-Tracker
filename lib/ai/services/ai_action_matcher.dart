import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_target_match.dart';

class AiActionMatcher {
  static const double strongMatchThreshold = 70;
  static const double ambiguityGap = 18;

  const AiActionMatcher();

  AiTargetMatchResult match({
    required List<Expense> expenses,
    String query = '',
    num? amount,
    String? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    bool preferLast = false,
  }) {
    final matches = expenses
        .map(
          (expense) => _scoreExpense(
            expense: expense,
            query: query,
            amount: amount?.toDouble(),
            category: category,
            date: date,
            paymentMethod: paymentMethod,
            preferLast: preferLast,
          ),
        )
        .where((match) => match.score > 0)
        .toList()
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return b.expense.date.compareTo(a.expense.date);
      });

    if (matches.isEmpty) {
      return const AiTargetMatchResult(
        resolution: AiTargetMatchResolution.noMatch,
        candidates: [],
      );
    }

    final top = matches.first;
    final secondScore = matches.length > 1 ? matches[1].score : 0.0;
    final isSingleExplainableMatch =
        matches.length == 1 && top.matchedFields.isNotEmpty && top.score >= 35;
    final isStrong = isSingleExplainableMatch ||
        (top.score >= strongMatchThreshold &&
            top.score - secondScore >= ambiguityGap);

    return AiTargetMatchResult(
      resolution: isStrong
          ? AiTargetMatchResolution.singleStrongMatch
          : AiTargetMatchResolution.multipleCandidates,
      candidates: matches.take(5).toList(),
    );
  }

  AiTargetMatch _scoreExpense({
    required Expense expense,
    required String query,
    required double? amount,
    required String? category,
    required DateTime? date,
    required PaymentMethod? paymentMethod,
    required bool preferLast,
  }) {
    var score = 0.0;
    final fields = <String>[];

    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isNotEmpty) {
      final haystack = _normalize(
        [
          expense.description,
          expense.categoryName,
          expense.category.name,
          expense.paymentMethod.label,
          expense.paymentMethod.storageValue,
        ].join(' '),
      );
      if (haystack.contains(normalizedQuery)) {
        score += 35;
        fields.add('text');
      } else if (_tokens(normalizedQuery).any(haystack.contains)) {
        score += 18;
        fields.add('partial text');
      }
    }

    if (amount != null) {
      final difference = (expense.amount - amount).abs();
      if (difference == 0) {
        score += 30;
        fields.add('amount');
      } else if (difference <= 10) {
        score += 12;
        fields.add('near amount');
      }
    }

    final normalizedCategory = _normalize(category ?? '');
    if (normalizedCategory.isNotEmpty) {
      final expenseCategory = _normalize(
        '${expense.categoryId} ${expense.categoryName} ${expense.category.name}',
      );
      if (expenseCategory.contains(normalizedCategory)) {
        score += 25;
        fields.add('category');
      }
    }

    if (date != null) {
      if (_sameDay(expense.date, date)) {
        score += 25;
        fields.add('date');
      } else if ((expense.date.difference(date).inDays).abs() <= 1) {
        score += 8;
        fields.add('near date');
      }
    }

    if (paymentMethod != null && expense.paymentMethod == paymentMethod) {
      score += 15;
      fields.add('payment method');
    }

    if (preferLast) {
      final daysOld = DateTime.now().difference(expense.date).inDays;
      if (daysOld <= 1) {
        score += 25;
        fields.add('recent');
      } else if (daysOld <= 7) {
        score += 12;
        fields.add('recent week');
      }
    }

    return AiTargetMatch(
      expense: expense,
      score: score,
      matchedFields: fields,
      reason: fields.isEmpty
          ? 'No deterministic fields matched.'
          : 'Matched ${fields.join(', ')}.',
    );
  }

  bool _sameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  List<String> _tokens(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((token) => token.length > 2)
        .toList();
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }
}
