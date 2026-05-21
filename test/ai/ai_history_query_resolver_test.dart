import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ai_history_fixtures.dart';

void main() {
  const resolver = AiHistoryQueryResolver();
  final now = DateTime(2026, 5, 20);

  HistoryAnswer resolve(String input) {
    return resolver.resolve(
      input: input,
      expenses: historyExpenses(),
      settings: historySettings(),
      now: now,
      categories: historyCategories(),
    );
  }

  test('answers 12 common English and Arabic history questions locally', () {
    final cases = <String, HistoryQuestionIntent>{
      'How much did I spend on food this month?':
          HistoryQuestionIntent.total,
      'total spending this month': HistoryQuestionIntent.total,
      'show expenses over 500 this month': HistoryQuestionIntent.search,
      'find visa expenses this month': HistoryQuestionIntent.search,
      'what is my top category this month?':
          HistoryQuestionIntent.categoryDriver,
      'why did spending increase this month?':
          HistoryQuestionIntent.comparison,
      'كم صرفت على Food هذا الشهر؟': HistoryQuestionIntent.total,
      'إجمالي مصروفات الشهر ده': HistoryQuestionIntent.total,
      'اعرض مصروفات فوق 500': HistoryQuestionIntent.search,
      'وريني مصروفات visa': HistoryQuestionIntent.search,
      'اكتر فئة صرفت عليها': HistoryQuestionIntent.categoryDriver,
      'ليه الصرف زاد الشهر ده؟': HistoryQuestionIntent.comparison,
    };

    for (final entry in cases.entries) {
      final answer = resolve(entry.key);

      expect(
        answer.intent,
        entry.value,
        reason: 'Question failed: ${entry.key}',
      );
      expect(answer.message, isNotEmpty);
      expect(answer.confidence, greaterThan(0.8));
    }
  });

  test('food total uses deterministic report math for the current month', () {
    final answer = resolve('How much did I spend on food this month?');

    expect(answer.intent, HistoryQuestionIntent.total);
    expect(answer.report?.total, 650);
    expect(answer.matchingExpenses.map((expense) => expense.expenseId), [
      'food-current-1',
      'food-current-2',
    ]);
  });

  test('threshold search maps to existing expense filter semantics', () {
    final answer = resolve('show expenses over 500 this month');

    expect(answer.intent, HistoryQuestionIntent.search);
    expect(answer.filter?.minAmount, 500);
    expect(answer.matchingExpenses.map((expense) => expense.expenseId), [
      'shopping-current',
    ]);
  });

  test('no-data periods return a deterministic empty answer', () {
    final answer = resolver.resolve(
      input: 'How much did I spend this month?',
      expenses: const [],
      settings: historySettings(),
      now: now,
      categories: historyCategories(),
    );

    expect(answer.intent, HistoryQuestionIntent.total);
    expect(answer.report?.total, 0);
    expect(answer.message, contains('0'));
  });

  test('comparison identifies the largest category change', () {
    final answer = resolve('why did spending increase this month?');

    expect(answer.intent, HistoryQuestionIntent.comparison);
    expect(answer.driver?.categoryName, 'Shopping');
    expect(answer.driver?.difference, 800);
  });

  test('mutation-like history requests are refused without side effects', () {
    final answer = resolve('delete all expenses over 500');

    expect(answer.intent, HistoryQuestionIntent.unsupportedMutation);
    expect(answer.isMutationRefusal, isTrue);
    expect(answer.filter, isNull);
    expect(answer.matchingExpenses, isEmpty);
  });

  test('unknown non-history text falls through to existing assistant flow', () {
    final answer = resolve('spent 90 on coffee yesterday');

    expect(answer.intent, HistoryQuestionIntent.unknown);
    expect(answer.isKnown, isFalse);
  });
}
