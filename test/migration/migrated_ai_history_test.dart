import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/history_question.dart';
import 'package:expenses_tracker/ai/services/ai_history_query_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI history answers use migrated local data and keep action logs local',
      () async {
    final store = LocalRepositoryStore(
      userId: 'user-1',
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
    );
    final expenseRepository = LocalExpenseRepository(store: store);
    final actionLogs = LocalAiActionLogRepository(store: store);
    await expenseRepository.createExpense(_expense('expense-1', 50, 'USD'));
    await actionLogs.createActionLog(
      AiActionLog(
        actionId: 'ai-1',
        userId: 'user-1',
        rawInput: 'how much this month?',
        parsedResponse: const {},
        intent: 'history_query',
        confidence: 0.8,
        status: AiActionLogStatus.previewed,
        createdAt: DateTime(2026, 5, 20),
        provider: 'cloudflare-worker',
      ),
    );

    final answer = const AiHistoryQueryResolver().resolve(
      input: 'how much did I spend this month?',
      expenses: await expenseRepository.getExpenses(),
      settings: store.settings,
      now: DateTime(2026, 5, 20),
    );

    expect(answer.intent, HistoryQuestionIntent.total);
    expect(answer.report!.total, 2500);
    expect((await actionLogs.getRecentActionLogs()).single.provider,
        'cloudflare-worker');
  });
}

Expense _expense(String id, num amount, String currency) {
  final category = Category(
    categoryId: 'subscriptions',
    name: 'Subscriptions',
    totalExpenses: 0,
    icon: 'play_circle',
    color: 0,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    date: DateTime(2026, 5, 20),
    amount: amount,
    currency: currency,
  );
}
