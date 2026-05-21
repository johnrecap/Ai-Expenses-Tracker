import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/cubit/ai_assistant_cubit.dart';
import 'package:expenses_tracker/ai/models/ai_action_preview.dart';
import 'package:expenses_tracker/ai/models/ai_advice_payload.dart';
import 'package:expenses_tracker/ai/models/ai_expense_payload.dart';
import 'package:expenses_tracker/ai/models/ai_intent.dart';
import 'package:expenses_tracker/ai/models/ai_provider_metadata.dart';
import 'package:expenses_tracker/ai/models/ai_response.dart';
import 'package:expenses_tracker/ai/models/ai_search_payload.dart';
import 'package:expenses_tracker/ai/models/ai_summary_payload.dart';
import 'package:expenses_tracker/ai/models/ai_usage_status.dart';
import 'package:expenses_tracker/ai/services/ai_gateway_error.dart';
import 'package:expenses_tracker/ai/services/mock_ai_service.dart';
import 'package:expenses_tracker/ai/services/ai_response_parser.dart';
import 'package:expenses_tracker/ai/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiService implements AiService {
  FakeAiService(this.response);

  final AiResponse response;

  @override
  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    return response;
  }
}

class ThrowingAiService implements AiService {
  const ThrowingAiService(this.error);

  final Object error;

  @override
  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    throw error;
  }
}

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository(List<Expense> initialExpenses) {
    for (final expense in initialExpenses) {
      expenses[expense.expenseId] = expense;
    }
  }

  final Map<String, Expense> expenses = {};

  @override
  Future<void> createExpense(Expense expense) async {
    expenses[expense.expenseId] = expense;
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    expenses[expense.expenseId] = expense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    expenses.remove(expenseId);
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async =>
      expenses[expenseId];

  @override
  Future<List<Expense>> getExpenses() async => expenses.values.toList();

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    return ExpensePage.fromOrderedExpenses(
      expenses.values.toList(),
      limit: limit,
    );
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return expenses.values.toList();
  }

  @override
  Stream<List<Expense>> watchExpenses() async* {
    yield expenses.values.toList();
  }

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) async* {
    yield await getExpensePage(limit: limit);
  }
}

class FakeAiActionLogRepository implements AiActionLogRepository {
  final logs = <String, AiActionLog>{};

  @override
  Future<void> createActionLog(AiActionLog log) async {
    logs[log.actionId] = log;
  }

  @override
  Future<List<AiActionLog>> getRecentActionLogs({int limit = 50}) async {
    return logs.values.take(limit).toList();
  }

  @override
  Future<void> updateActionLogStatus({
    required String actionId,
    required AiActionLogStatus status,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
  }) async {
    final existing = logs[actionId];
    if (existing == null) return;
    logs[actionId] = existing.copyWith(
      status: status,
      confirmedAt: confirmedAt,
      targetExpenseId: targetExpenseId,
      errorMessage: errorMessage,
    );
  }
}

void main() {
  final categories = [
    Category(
      categoryId: 'food',
      name: 'Food',
      totalExpenses: 0,
      icon: 'food',
      color: 0xFFFFFFFF,
    ),
  ];

  AiResponse successResponse() => AiResponse(
        intent: AiIntent.addExpense,
        expensePayload: AiExpensePayload(
          amount: 250,
          categoryName: 'Food',
          date: DateTime(2026, 5, 14),
          paymentMethod: PaymentMethod.cash,
          currency: 'EGP',
          description: 'Food expense',
        ),
        confidence: 0.92,
        needsConfirmation: true,
        rawJson: '{}',
      );

  test('emits preview for a high confidence add expense response', () async {
    final cubit = AiAssistantCubit(aiService: FakeAiService(successResponse()));

    await cubit.parseText(
      'spent 250 on food yesterday cash',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        categories: categories,
        defaultCurrency: 'EGP',
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.preview?.amount, 250);
    expect(cubit.state.preview?.category?.categoryId, 'food');
  });

  test('keeps explicit AI currency over base currency in preview', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        AiResponse(
          intent: AiIntent.addExpense,
          expensePayload: successResponse().expensePayload?.copyWith(
                currency: 'USD',
              ),
          confidence: 0.92,
          needsConfirmation: true,
          rawJson: '{}',
        ),
      ),
    );

    await cubit.parseText(
      'spent 20 dollars on food',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        categories: categories,
        defaultCurrency: 'EGP',
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.preview?.currency, 'USD');
  });

  test('infers preview for reported English sentence without clarification',
      () async {
    final repository = FakeExpenseRepository([]);
    final cubit = AiAssistantCubit(
      aiService: const MockAiService(),
      expenseRepository: repository,
    );

    await cubit.parseText(
      'spent 100 dollar on food last night',
      context: AiContext(
        now: DateTime(2026, 5, 19, 12),
        categories: categories,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.wallet,
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.clarifyingQuestion, isNull);
    expect(cubit.state.preview?.amount, 100);
    expect(cubit.state.preview?.currency, 'USD');
    expect(cubit.state.preview?.date, DateTime(2026, 5, 18));
    expect(cubit.state.preview?.paymentMethod, PaymentMethod.wallet);
    expect(cubit.state.preview?.category?.categoryId, 'food');
    expect(repository.expenses, isEmpty);
  });

  test('uses default payment method when omitted', () async {
    final cubit = AiAssistantCubit(aiService: const MockAiService());

    await cubit.parseText(
      'spent 100 dollars on food',
      context: AiContext(
        now: DateTime(2026, 5, 19),
        categories: categories,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.visa,
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.preview?.paymentMethod, PaymentMethod.visa);
    expect(cubit.state.preview?.currency, 'USD');
  });

  test('shows editable draft when amount is missing', () async {
    final cubit = AiAssistantCubit(aiService: const MockAiService());

    await cubit.parseText(
      'food last night',
      context: AiContext(
        now: DateTime(2026, 5, 19),
        categories: categories,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.cash,
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.clarifyingQuestion, isNull);
    expect(cubit.state.preview?.amount, 0);
    expect(cubit.state.preview?.category?.categoryId, 'food');
    expect(cubit.state.preview?.date, DateTime(2026, 5, 18));
    expect(cubit.state.preview?.validationErrors,
        contains('Enter a valid amount.'));
  });

  test('shows editable draft when category cannot be inferred', () async {
    final cubit = AiAssistantCubit(aiService: const MockAiService());

    await cubit.parseText(
      'spent 100 dollars last night',
      context: AiContext(
        now: DateTime(2026, 5, 19),
        categories: categories,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.cash,
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.clarifyingQuestion, isNull);
    expect(cubit.state.preview?.amount, 100);
    expect(cubit.state.preview?.category, isNull);
    expect(cubit.state.preview?.categoryName, isEmpty);
    expect(
        cubit.state.preview?.validationErrors, contains('Select a category.'));
  });

  test('falls back to an editable draft for vague non-empty input', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.unknown,
          confidence: 0.2,
          needsConfirmation: true,
          rawJson: '{}',
        ),
      ),
    );

    await cubit.parseText(
      'maybe something from yesterday',
      context: AiContext(
        now: DateTime(2026, 5, 19),
        categories: categories,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.cash,
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.pendingIntent, AiIntent.addExpense);
    expect(cubit.state.preview?.description, 'maybe something from yesterday');
    expect(cubit.state.preview?.amount, 0);
    expect(cubit.state.preview?.validationErrors,
        contains('Enter a valid amount.'));
    expect(
        cubit.state.preview?.validationErrors, contains('Select a category.'));
  });

  test('resolves missing AI category from Arabic input before preview',
      () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        AiResponse(
          intent: AiIntent.addExpense,
          expensePayload: AiExpensePayload(
            amount: 100,
            date: DateTime(2026, 5, 16),
            paymentMethod: PaymentMethod.cash,
            currency: 'EGP',
            description: 'Transport expense',
          ),
          confidence: 0.9,
          needsConfirmation: true,
          rawJson: '{}',
        ),
      ),
    );

    await cubit.parseText(
      'صرفت 100 جنيه امبارح على المواصلات',
      context: AiContext(
        now: DateTime(2026, 5, 17),
        categories: [
          Category(
            categoryId: 'transport',
            name: 'Transport',
            totalExpenses: 0,
            icon: 'transport',
            color: 0xFFFFFFFF,
          ),
        ],
        defaultCurrency: 'EGP',
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.preview?.category?.categoryId, 'transport');
    expect(cubit.state.preview?.categoryResolution?.reason, isNotEmpty);
  });

  test('keeps low confidence add expense as an editable draft', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        AiResponse(
          intent: AiIntent.addExpense,
          expensePayload: successResponse().expensePayload,
          confidence: 0.5,
          needsConfirmation: true,
          rawJson: '{}',
        ),
      ),
    );

    await cubit.parseText(
      'unclear',
      context: AiContext(now: DateTime(2026, 5, 15)),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.preview?.validationErrors, isEmpty);
  });

  test('turns parser exceptions into clarification instead of failure',
      () async {
    final cubit = AiAssistantCubit(
      aiService: const ThrowingAiService(
        AiResponseParserException(
          'Add expense intent is missing required fields.',
        ),
      ),
    );

    await cubit.parseText(
      'صرفت 100 جنيه امبارح علي المواصلات',
      context: AiContext(now: DateTime(2026, 5, 17)),
    );

    expect(cubit.state.status, AiAssistantStatus.needsClarification);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.clarifyingQuestion, contains('amount'));
  });

  test('surfaces quota exhaustion with reset metadata', () async {
    final cubit = AiAssistantCubit(
      aiService: ThrowingAiService(
        AiGatewayException(
          code: AiGatewayErrorCode.quotaExceeded,
          message: 'Daily limit reached.',
          usageStatus: AiUsageStatus(
            requestType: AiUsageRequestType.parseText,
            allowed: false,
            limit: 5,
            used: 5,
            remaining: 0,
            resetAt: DateTime(2026, 5, 18),
          ),
        ),
      ),
    );

    await cubit.parseText(
      'spent 100 on food',
      context: AiContext(now: DateTime(2026, 5, 17)),
    );

    expect(cubit.state.status, AiAssistantStatus.failure);
    expect(cubit.state.errorMessage, contains('Daily AI limit'));
    expect(cubit.state.usageStatus?.remaining, 0);
    expect(
      cubit.state.quotaError?.category,
      AiQuotaErrorCategory.quotaExhausted,
    );
  });

  test('surfaces provider outage without quota upsell state', () async {
    final cubit = AiAssistantCubit(
      aiService: const ThrowingAiService(
        AiGatewayException(
          code: AiGatewayErrorCode.providerUnavailable,
          message: 'Provider unavailable.',
        ),
      ),
    );

    await cubit.parseText(
      'spent 100 on food',
      context: AiContext(now: DateTime(2026, 5, 17)),
    );

    expect(cubit.state.status, AiAssistantStatus.failure);
    expect(cubit.state.errorMessage, contains('temporarily unavailable'));
    expect(cubit.state.usageStatus, isNull);
    expect(
      cubit.state.quotaError?.category,
      AiQuotaErrorCategory.providerUnavailable,
    );
  });

  test('surfaces missing auth token as auth-specific failure', () async {
    final cubit = AiAssistantCubit(
      aiService: const ThrowingAiService(
        AiGatewayException(
          code: AiGatewayErrorCode.unauthenticated,
          message: 'Missing authentication token.',
        ),
      ),
    );

    await cubit.parseText(
      'spent 100 on food',
      context: AiContext(now: DateTime(2026, 5, 17)),
    );

    expect(cubit.state.status, AiAssistantStatus.failure);
    expect(cubit.state.errorMessage, contains('sign in'));
    expect(
      cubit.state.quotaError?.category,
      AiQuotaErrorCategory.unauthorized,
    );
    expect(cubit.state.preview, isNull);
  });

  test('marks parse usage stale when Worker omits quota metadata', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        successResponse().copyWith(
          providerMetadata: const AiProviderMetadata(
            provider: 'gemini',
            model: 'gemini-2.5-flash',
            requestId: 'request-no-quota',
          ),
        ),
      ),
    );

    await cubit.parseText(
      'spent 250 on food',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        categories: categories,
        defaultCurrency: 'EGP',
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.previewReady);
    expect(cubit.state.usageStatus, isNull);
    expect(cubit.state.staleUsageRequestType, AiUsageRequestType.parseText);
  });

  test('manual preview confirmation remains available after AI failure',
      () async {
    final cubit = AiAssistantCubit(
      aiService: const ThrowingAiService(
        AiGatewayException(
          code: AiGatewayErrorCode.providerUnavailable,
          message: 'Provider unavailable.',
        ),
      ),
    );
    final preview = AiActionPreview.fromPayload(
      successResponse().expensePayload!,
      categories: categories,
      defaultCurrency: 'EGP',
    );

    await cubit.parseText(
      'spent 100 on food',
      context: AiContext(now: DateTime(2026, 5, 17)),
    );
    expect(cubit.state.status, AiAssistantStatus.failure);

    cubit.setPreviewForEditing(preview);
    final expense = cubit.confirmPreview(userId: 'user-1');

    expect(expense, isNotNull);
    expect(expense?.source, ExpenseSource.ai);
  });

  test('history question returns local answer when provider would fail',
      () async {
    final cubit = AiAssistantCubit(
      aiService: const ThrowingAiService(
        AiGatewayException(
          code: AiGatewayErrorCode.providerUnavailable,
          message: 'Provider unavailable.',
        ),
      ),
    );

    await cubit.parseText(
      'How much did I spend on food this month?',
      context: AiContext(
        now: DateTime(2026, 5, 17),
        categories: categories,
        expenses: [_expense(id: '1', amount: 120, categoryName: 'Food')],
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.historyReady);
    expect(cubit.state.historyAnswer?.report?.total, 120);
    expect(cubit.state.errorMessage, isNull);
  });

  test('updates editable preview fields before confirm', () {
    final cubit = AiAssistantCubit(aiService: FakeAiService(successResponse()));
    final preview = AiActionPreview.fromPayload(
      successResponse().expensePayload!,
      categories: categories,
      defaultCurrency: 'EGP',
    );

    cubit.setPreviewForEditing(preview);
    cubit.updatePreview(preview.copyWith(amount: 300, description: 'Dinner'));

    expect(cubit.state.preview?.amount, 300);
    expect(cubit.state.preview?.description, 'Dinner');
  });

  test('confirm creates an AI sourced expense without service side effects',
      () {
    final cubit = AiAssistantCubit(aiService: FakeAiService(successResponse()));
    final preview = AiActionPreview.fromPayload(
      successResponse().expensePayload!,
      categories: categories,
      defaultCurrency: 'EGP',
    );

    cubit.setPreviewForEditing(preview);
    final expense = cubit.confirmPreview(userId: 'user-1');

    expect(expense, isNotNull);
    expect(expense?.source, ExpenseSource.ai);
    expect(expense?.userId, 'user-1');
    expect(cubit.state.status, AiAssistantStatus.confirmed);
  });

  test('answers search-like history command locally before provider parsing',
      () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.searchExpenses,
          searchPayload: AiSearchPayload(
            query: 'food this month',
            categoryNames: ['Food'],
            currency: 'EGP',
            periodText: 'this month',
          ),
          confidence: 0.9,
          needsConfirmation: false,
          rawJson: '{"intent":"search_expenses","confidence":0.9}',
        ),
      ),
    );

    await cubit.parseText(
      'show food this month',
      context: AiContext(now: DateTime(2026, 5, 15)),
    );

    expect(cubit.state.status, AiAssistantStatus.historyReady);
    expect(cubit.state.historyAnswer?.filter?.categoryIds, contains('food'));
    expect(cubit.state.historyAnswer?.filter?.currency, isNull);
  });

  test('calculates summary command from real expenses', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.summarizeExpenses,
          summaryPayload: AiSummaryPayload(
            period: ReportRangeType.weekly,
            currency: 'EGP',
          ),
          confidence: 0.9,
          needsConfirmation: false,
          rawJson: '{"intent":"summarize_expenses","confidence":0.9}',
        ),
      ),
    );

    await cubit.parseText(
      'summarize this week',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        expenses: [_expense(id: '1', amount: 120, categoryName: 'Food')],
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.summaryReady);
    expect(cubit.state.summaryReport?.total, 120);
  });

  test('generates advice command from aggregates', () async {
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.financialAdvice,
          advicePayload: AiAdvicePayload(
            period: ReportRangeType.weekly,
            currency: 'EGP',
          ),
          confidence: 0.9,
          needsConfirmation: false,
          rawJson: '{"intent":"financial_advice","confidence":0.9}',
        ),
      ),
    );

    await cubit.parseText(
      'advice',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        expenses: [_expense(id: '1', amount: 120, categoryName: 'Food')],
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.adviceReady);
    expect(cubit.state.advice?.report.total, 120);
  });

  test('previews and confirms update command', () async {
    final original =
        _expense(id: 'uber', description: 'Uber ride', amount: 100);
    final repository = FakeExpenseRepository([original]);
    final logRepository = FakeAiActionLogRepository();
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.updateExpense,
          expensePayload: AiExpensePayload(
            amount: 180,
            categoryName: 'Transport',
            description: 'Uber',
          ),
          confidence: 0.9,
          needsConfirmation: true,
          rawJson: '{"intent":"update_expense","confidence":0.9}',
        ),
      ),
      expenseRepository: repository,
      actionLogRepository: logRepository,
    );

    await cubit.parseText(
      'change Uber to 180',
      context: AiContext(
        userId: 'user-1',
        now: DateTime(2026, 5, 15),
        expenses: [original],
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.targetPreviewReady);
    expect(cubit.state.updatedExpense?.amount, 180);

    final confirmed = await cubit.confirmCommand();
    expect(confirmed, isTrue);
    expect(repository.expenses['uber']?.amount, 180);
    expect(
        logRepository.logs.values.single.status, AiActionLogStatus.confirmed);
  });

  test('previews and confirms delete command', () async {
    final original = _expense(id: 'last', description: 'Food lunch');
    final repository = FakeExpenseRepository([original]);
    final cubit = AiAssistantCubit(
      aiService: FakeAiService(
        const AiResponse(
          intent: AiIntent.deleteExpense,
          expensePayload: AiExpensePayload(description: 'Food lunch'),
          confidence: 0.9,
          needsConfirmation: true,
          rawJson: '{"intent":"delete_expense","confidence":0.9}',
        ),
      ),
      expenseRepository: repository,
    );

    await cubit.parseText(
      'delete Food lunch',
      context: AiContext(
        now: DateTime(2026, 5, 15),
        expenses: [original],
      ),
    );

    expect(cubit.state.status, AiAssistantStatus.targetPreviewReady);

    final confirmed = await cubit.confirmCommand();
    expect(confirmed, isTrue);
    expect(repository.expenses, isEmpty);
  });
}

Expense _expense({
  required String id,
  String description = '',
  String categoryName = 'Food',
  int amount = 100,
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: 0xFFFFFFFF,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: DateTime(2026, 5, 15),
    amount: amount,
    description: description,
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
  );
}
