import 'dart:convert';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/services.dart';

part 'ai_assistant_state.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  AiAssistantCubit({
    required AiService aiService,
    ExpenseRepository? expenseRepository,
    AiActionLogRepository? actionLogRepository,
    CategoryAliasRepository? categoryAliasRepository,
    AiAdviceService adviceService = const AiAdviceService(),
    AiActionMatcher actionMatcher = const AiActionMatcher(),
    AiHistoryQueryResolver historyQueryResolver =
        const AiHistoryQueryResolver(),
  })  : _aiService = aiService,
        _expenseRepository = expenseRepository,
        _actionLogRepository = actionLogRepository,
        _categoryAliasRepository = categoryAliasRepository,
        _adviceService = adviceService,
        _actionMatcher = actionMatcher,
        _historyQueryResolver = historyQueryResolver,
        super(const AiAssistantState());

  final AiService _aiService;
  final ExpenseRepository? _expenseRepository;
  final AiActionLogRepository? _actionLogRepository;
  final CategoryAliasRepository? _categoryAliasRepository;
  final AiAdviceService _adviceService;
  final AiActionMatcher _actionMatcher;
  final AiHistoryQueryResolver _historyQueryResolver;

  Future<void> parseText(
    String input, {
    required AiContext context,
  }) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          input: trimmed,
          clearDraft: true,
          clearPreview: true,
          clearCommandData: true,
          clarifyingQuestion: 'Please describe the expense.',
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final historyAnswer = _historyQueryResolver.resolve(
      input: trimmed,
      expenses: context.expenses,
      settings: context.effectiveSettings,
      now: context.now,
      categories: context.categories,
    );
    if (historyAnswer.isKnown) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.historyReady,
          input: trimmed,
          historyAnswer: historyAnswer,
          resultMessage: historyAnswer.message,
          pendingIntent: AiIntent.searchExpenses,
          clearDraft: true,
          clearPreview: true,
          clearCommandData: true,
          clearClarifyingQuestion: true,
          clearErrorMessage: true,
          clearUsageStatus: true,
          clearStaleUsageRequestType: true,
          clearQuotaError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AiAssistantStatus.parsing,
        input: trimmed,
        clearDraft: true,
        clearPreview: true,
        clearCommandData: true,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
        clearUsageStatus: true,
        clearStaleUsageRequestType: true,
        clearQuotaError: true,
      ),
    );

    try {
      final response = await _aiService.parseExpenseText(trimmed, context);
      final actionLogId = await _logPreview(
        userId: context.userId,
        input: trimmed,
        response: response,
      );

      switch (response.intent) {
        case AiIntent.addExpense:
          _handleAddExpenseResponse(response, context, actionLogId);
        case AiIntent.searchExpenses:
          _handleSearchResponse(response, context, actionLogId);
        case AiIntent.summarizeExpenses:
          _handleSummaryResponse(response, context, actionLogId);
        case AiIntent.financialAdvice:
          _handleAdviceResponse(response, context, actionLogId);
        case AiIntent.updateExpense:
        case AiIntent.deleteExpense:
          _handleMutationResponse(response, context, actionLogId);
        case AiIntent.unknown:
          _emitDraftPreview(
            response: response,
            context: context,
            actionLogId: actionLogId,
            description: trimmed,
          );
      }
    } catch (error) {
      await _logFailure(
        userId: context.userId,
        input: trimmed,
        error: error,
      );
      if (error is AiResponseParserException) {
        emit(
          state.copyWith(
            status: AiAssistantStatus.needsClarification,
            clarifyingQuestion: _parserClarification(error),
            clearDraft: true,
            clearPreview: true,
            clearCommandData: true,
            clearErrorMessage: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AiAssistantStatus.failure,
          errorMessage: error is AiGatewayException
              ? error.userMessage
              : error.toString(),
          usageStatus: error is AiGatewayException ? error.usageStatus : null,
          quotaError: error is AiGatewayException ? error.quotaError : null,
          clearDraft: true,
          clearPreview: true,
          clearCommandData: true,
        ),
      );
    }
  }

  void _handleAddExpenseResponse(
    AiResponse response,
    AiContext context,
    String? actionLogId,
  ) {
    final rawPayload = response.expensePayload;
    if (rawPayload == null) {
      _emitDraftPreview(
        response: response,
        context: context,
        actionLogId: actionLogId,
        description: state.input,
      );
      return;
    }

    final payload = _payloadWithDefaultExpenseFields(
      _payloadWithResolvedCategory(
        rawPayload,
        context,
      ),
      context,
    );
    final draft = AiExpenseDraft.fromPayload(
      payload,
      confidence: response.confidence,
    );
    final preview = AiActionPreview.fromPayload(
      payload,
      categories: context.categories,
      defaultCurrency: context.defaultCurrency,
      defaultPaymentMethod: context.defaultPaymentMethod,
      confidence: response.confidence,
    );
    final previewWithDraftErrors = _previewWithDraftErrors(preview, draft);

    emit(
      state.copyWith(
        status: AiAssistantStatus.previewReady,
        draft: draft,
        preview: previewWithDraftErrors,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        pendingIntent: AiIntent.addExpense,
        actionLogId: actionLogId,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
        clearCommandData: true,
      ),
    );
  }

  void _emitDraftPreview({
    required AiResponse response,
    required AiContext context,
    required String? actionLogId,
    required String description,
  }) {
    final payload = _payloadWithDefaultExpenseFields(
      _payloadWithResolvedCategory(
        AiExpensePayload(
          amount: _amountFromText(description),
          currency: _currencyFromText(description),
          date: _dateFromText(description, context.now),
          paymentMethod: _paymentMethodFromText(description),
          description: description.trim().isEmpty ? 'AI expense' : description,
        ),
        context,
        inputText: description,
      ),
      context,
    );
    final draft = AiExpenseDraft.fromPayload(
      payload,
      confidence: response.confidence,
    );
    final preview = AiActionPreview.fromPayload(
      payload,
      categories: context.categories,
      defaultCurrency: context.defaultCurrency,
      defaultPaymentMethod: context.defaultPaymentMethod,
      confidence: response.confidence,
    );
    final previewWithDraftErrors = _previewWithDraftErrors(preview, draft);
    emit(
      state.copyWith(
        status: AiAssistantStatus.previewReady,
        draft: draft,
        preview: previewWithDraftErrors,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        pendingIntent: AiIntent.addExpense,
        actionLogId: actionLogId,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
        clearCommandData: true,
      ),
    );
  }

  double? _amountFromText(String text) {
    final amountText = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(text)?.group(0);
    if (amountText == null) return null;
    return parseAmountInput(amountText);
  }

  String? _currencyFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('usd') ||
        normalized.contains('dollar') ||
        normalized.contains('dollars') ||
        normalized.contains('دولار')) {
      return 'USD';
    }
    if (normalized.contains('egp') || normalized.contains('جنيه')) {
      return 'EGP';
    }
    return null;
  }

  DateTime? _dateFromText(String text, DateTime now) {
    final normalized = text.toLowerCase();
    if (normalized.contains('last night') ||
        normalized.contains('yesterday') ||
        normalized.contains('امبارح') ||
        normalized.contains('أمس')) {
      final date = now.subtract(const Duration(days: 1));
      return DateTime(date.year, date.month, date.day);
    }
    if (normalized.contains('today') ||
        normalized.contains('tonight') ||
        normalized.contains('النهاردة') ||
        normalized.contains('اليوم')) {
      return DateTime(now.year, now.month, now.day);
    }
    return null;
  }

  PaymentMethod? _paymentMethodFromText(String text) {
    final normalized = text.toLowerCase().replaceAll('-', ' ');
    if (normalized.contains('cash') ||
        normalized.contains('كاش') ||
        normalized.contains('نقدي')) {
      return PaymentMethod.cash;
    }
    if (normalized.contains('visa') ||
        normalized.contains('card') ||
        normalized.contains('فيزا')) {
      return PaymentMethod.visa;
    }
    if (normalized.contains('wallet') || normalized.contains('محفظة')) {
      return PaymentMethod.wallet;
    }
    if (normalized.contains('bank transfer') ||
        normalized.contains('transfer') ||
        normalized.contains('تحويل بنكي')) {
      return PaymentMethod.bankTransfer;
    }
    return null;
  }

  AiExpensePayload _payloadWithResolvedCategory(
    AiExpensePayload payload,
    AiContext context, {
    String? inputText,
  }) {
    final resolution = const AiCategoryResolver().resolve(
      inputText: inputText ?? state.input,
      parsedCategoryId: payload.categoryId,
      parsedCategoryName: payload.categoryName,
      activeCategories: context.categories,
      learnedAliases: context.categoryAliases,
      recentExpenses: context.expenses,
    );

    if (resolution.hasExistingCategory) {
      return payload.copyWith(
        categoryId: resolution.categoryId,
        categoryName: resolution.categoryName,
        categoryResolution: resolution,
      );
    }

    if (resolution.suggestedCategory != null) {
      return payload.copyWith(
        clearCategoryId: true,
        categoryName: resolution.categoryName,
        categoryResolution: resolution,
      );
    }

    return payload.copyWith(
      clearCategoryId: true,
      clearCategoryName: payload.categoryName?.trim().isEmpty ?? true,
      categoryResolution: resolution,
    );
  }

  AiExpensePayload _payloadWithDefaultExpenseFields(
    AiExpensePayload payload,
    AiContext context,
  ) {
    return payload.copyWith(
      date: payload.date ?? context.now,
      paymentMethod: payload.paymentMethod ?? context.defaultPaymentMethod,
      currency: payload.currency?.trim().isNotEmpty == true
          ? payload.currency!.trim().toUpperCase()
          : context.defaultCurrency,
      missingFields: payload.missingFields
          .where(
            (field) => !{
              'date',
              'payment method',
              'currency',
            }.contains(field.trim().toLowerCase()),
          )
          .toList(growable: false),
    );
  }

  AiActionPreview _previewWithDraftErrors(
    AiActionPreview preview,
    AiExpenseDraft draft,
  ) {
    if (draft.missingFields.isEmpty) return preview;
    final errors = <String>{
      ...preview.validationErrors,
      'Complete missing fields: ${draft.missingFields.join(', ')}.',
    }.toList(growable: false);
    return preview.copyWith(validationErrors: errors);
  }

  void _handleSearchResponse(
    AiResponse response,
    AiContext context,
    String? actionLogId,
  ) {
    final payload = response.searchPayload;
    if (payload == null || response.requiresClarification) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          lastResponse: response,
          actionLogId: actionLogId,
          usageStatus: response.usageStatus,
          staleUsageRequestType: _staleUsageRequestType(response),
          clarifyingQuestion:
              response.clarifyingQuestion ?? 'I need clearer search filters.',
        ),
      );
      return;
    }

    final mappedPayload = AiActionMapper.searchPayloadFromJson(
      payload.toJson(),
      now: context.now,
    );
    final filter = AiActionMapper.searchPayloadToFilter(
      mappedPayload,
      now: context.now,
    );

    emit(
      state.copyWith(
        status: AiAssistantStatus.searchReady,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        searchFilter: filter,
        resultMessage: _filterSummary(filter),
        pendingIntent: AiIntent.searchExpenses,
        actionLogId: actionLogId,
        clearPreview: true,
        clearCommandData: true,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void _handleSummaryResponse(
    AiResponse response,
    AiContext context,
    String? actionLogId,
  ) {
    final payload = response.summaryPayload;
    if (payload == null || response.requiresClarification) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          lastResponse: response,
          actionLogId: actionLogId,
          usageStatus: response.usageStatus,
          staleUsageRequestType: _staleUsageRequestType(response),
          clarifyingQuestion:
              response.clarifyingQuestion ?? 'I need a clearer summary period.',
        ),
      );
      return;
    }

    final report = ReportCalculator.calculate(
      expenses: context.expenses,
      range: AiActionMapper.summaryPayloadToRange(payload, now: context.now),
      settings: context.effectiveSettings,
    );

    emit(
      state.copyWith(
        status: AiAssistantStatus.summaryReady,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        summaryReport: report,
        resultMessage: _summaryMessage(report),
        pendingIntent: AiIntent.summarizeExpenses,
        actionLogId: actionLogId,
        clearPreview: true,
        clearCommandData: true,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void _handleAdviceResponse(
    AiResponse response,
    AiContext context,
    String? actionLogId,
  ) {
    final payload = response.advicePayload;
    if (payload == null || response.requiresClarification) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          lastResponse: response,
          actionLogId: actionLogId,
          usageStatus: response.usageStatus,
          staleUsageRequestType: _staleUsageRequestType(response),
          clarifyingQuestion:
              response.clarifyingQuestion ?? 'I need a clearer advice request.',
        ),
      );
      return;
    }

    final advice = _adviceService.generate(
      expenses: context.expenses,
      payload: payload,
      budget: context.budget,
      settings: context.effectiveSettings,
      now: context.now,
      locale: context.locale,
    );

    emit(
      state.copyWith(
        status: AiAssistantStatus.adviceReady,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        advice: advice,
        resultMessage: advice.message,
        pendingIntent: AiIntent.financialAdvice,
        actionLogId: actionLogId,
        clearPreview: true,
        clearCommandData: true,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void _handleMutationResponse(
    AiResponse response,
    AiContext context,
    String? actionLogId,
  ) {
    final payload = response.expensePayload;
    if (payload == null || response.confidence < 0.75) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          lastResponse: response,
          actionLogId: actionLogId,
          usageStatus: response.usageStatus,
          staleUsageRequestType: _staleUsageRequestType(response),
          clarifyingQuestion:
              response.clarifyingQuestion ?? 'I need clearer target details.',
        ),
      );
      return;
    }

    final matchResult = _actionMatcher.match(
      expenses: context.expenses,
      query: payload.description ?? state.input,
      amount: payload.amount,
      category: payload.categoryName ?? payload.categoryId,
      date: payload.date,
      paymentMethod: payload.paymentMethod,
      preferLast: _mentionsLast(state.input),
    );

    if (matchResult.resolution == AiTargetMatchResolution.noMatch) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          lastResponse: response,
          actionLogId: actionLogId,
          usageStatus: response.usageStatus,
          staleUsageRequestType: _staleUsageRequestType(response),
          clarifyingQuestion: 'I could not find a matching expense to change.',
        ),
      );
      return;
    }

    final selected = matchResult.selected;
    emit(
      state.copyWith(
        status: selected == null
            ? AiAssistantStatus.targetSelectionRequired
            : AiAssistantStatus.targetPreviewReady,
        lastResponse: response,
        usageStatus: response.usageStatus,
        staleUsageRequestType: _staleUsageRequestType(response),
        targetMatchResult: matchResult,
        selectedTarget: selected?.expense,
        updatedExpense: selected == null
            ? null
            : _updatedExpenseFromPayload(selected.expense, payload),
        pendingIntent: response.intent,
        actionLogId: actionLogId,
        clearPreview: true,
        clearCommandData: true,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void setPreviewForEditing(AiActionPreview preview) {
    emit(
      state.copyWith(
        status: AiAssistantStatus.previewReady,
        draft: AiExpenseDraft.fromPreview(preview),
        preview: preview.copyWith(validationErrors: preview.validate()),
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void showReceiptPreview(
    AiReceiptPayload payload, {
    required AiContext context,
    AiUsageStatus? usageStatus,
  }) {
    final expensePayload = _payloadWithDefaultExpenseFields(
      AiExpensePayload(
        amount: payload.amount,
        categoryId: payload.categoryId,
        categoryName: payload.categoryName,
        date: payload.date,
        paymentMethod: context.defaultPaymentMethod,
        currency: payload.currency ?? context.defaultCurrency,
        description: payload.description ??
            (payload.merchant?.trim().isNotEmpty == true
                ? 'Receipt from ${payload.merchant!.trim()}'
                : 'Receipt expense'),
        merchant: payload.merchant,
        missingFields: payload.missingFields(),
      ),
      context,
    );
    final preview = AiActionPreview.fromPayload(
      _payloadWithResolvedCategory(
        expensePayload,
        context,
        inputText: [
          payload.merchant,
          payload.description,
          payload.categoryName,
        ].whereType<String>().join(' '),
      ),
      categories: context.categories,
      defaultCurrency: context.defaultCurrency,
      defaultPaymentMethod: context.defaultPaymentMethod,
      confidence: payload.confidence,
    );
    final missing = payload.missingFields();
    final errors = [
      ...preview.validate(),
      if (payload.hasLowConfidence) 'Review receipt fields before saving.',
      if (missing.isNotEmpty)
        'Complete missing receipt fields: ${missing.join(', ')}.',
      if (usageStatus?.message?.trim().isNotEmpty == true)
        usageStatus!.message!.trim(),
    ];
    emit(
      state.copyWith(
        status: errors.isEmpty
            ? AiAssistantStatus.previewReady
            : AiAssistantStatus.needsClarification,
        draft: AiExpenseDraft.fromPayload(
          expensePayload,
          confidence: payload.confidence,
        ),
        preview: preview.copyWith(validationErrors: errors),
        pendingIntent: AiIntent.addExpense,
        clarifyingQuestion: errors.isEmpty ? null : errors.join(' '),
        clearErrorMessage: true,
        clearCommandData: true,
      ),
    );
  }

  void updatePreview(AiActionPreview preview) {
    emit(
      state.copyWith(
        status: AiAssistantStatus.previewReady,
        draft: AiExpenseDraft.fromPreview(preview),
        preview: preview.copyWith(validationErrors: preview.validate()),
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  void selectTarget(AiTargetMatch match) {
    final intent = state.pendingIntent;
    if (intent != AiIntent.updateExpense && intent != AiIntent.deleteExpense) {
      return;
    }
    final payload = state.lastResponse?.expensePayload;
    emit(
      state.copyWith(
        status: AiAssistantStatus.targetPreviewReady,
        selectedTarget: match.expense,
        updatedExpense: intent == AiIntent.updateExpense && payload != null
            ? _updatedExpenseFromPayload(match.expense, payload)
            : match.expense,
        clearClarifyingQuestion: true,
        clearErrorMessage: true,
      ),
    );
  }

  Expense? confirmPreview({
    required String userId,
    String locale = 'auto',
  }) {
    final preview = state.preview;
    if (preview == null) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.failure,
          errorMessage: 'No AI preview is ready to confirm.',
        ),
      );
      return null;
    }

    final errors = preview.validate();
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.needsClarification,
          preview: preview.copyWith(validationErrors: errors),
          clarifyingQuestion: errors.join(' '),
        ),
      );
      return null;
    }

    emit(state.copyWith(status: AiAssistantStatus.confirming));
    final expense = preview.toExpense(userId: userId)
      ..aiActionId = state.actionLogId;
    _learnCategoryAliasIfUseful(preview, userId, locale);
    emit(state.copyWith(status: AiAssistantStatus.confirmed));
    return expense;
  }

  void _learnCategoryAliasIfUseful(
    AiActionPreview preview,
    String userId,
    String locale,
  ) {
    final repository = _categoryAliasRepository;
    final category = preview.category;
    final resolution = preview.categoryResolution;
    final phrase = state.input.trim();
    if (repository == null ||
        category == null ||
        resolution == null ||
        resolution.confidence < 0.85 ||
        phrase.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final normalizedPhrase = _normalizeAliasPhrase(phrase);
    if (normalizedPhrase.isEmpty) return;
    final aliasId = _aliasIdFor(category.categoryId, normalizedPhrase);
    unawaited(
      repository.upsertAlias(
        CategoryAlias(
          aliasId: aliasId,
          userId: userId,
          categoryId: category.categoryId,
          phrase: normalizedPhrase,
          locale: locale,
          createdAt: now,
          updatedAt: now,
          lastUsedAt: now,
          useCount: 1,
        ),
      ),
    );
  }

  String _normalizeAliasPhrase(String value) {
    final text = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return text.length > 80 ? text.substring(0, 80) : text;
  }

  String _aliasIdFor(String categoryId, String phrase) {
    final encoded =
        base64Url.encode(utf8.encode(phrase)).replaceAll('=', '').toLowerCase();
    return '${categoryId}_$encoded';
  }

  Future<bool> confirmCommand() async {
    final expenseRepository = _expenseRepository;
    final selectedTarget = state.selectedTarget;
    final actionLogId = state.actionLogId;
    if (expenseRepository == null || selectedTarget == null) {
      emit(
        state.copyWith(
          status: AiAssistantStatus.failure,
          errorMessage: 'No confirmed target is ready.',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: AiAssistantStatus.confirming));
    try {
      if (state.pendingIntent == AiIntent.updateExpense) {
        await expenseRepository
            .updateExpense(state.updatedExpense ?? selectedTarget);
      } else if (state.pendingIntent == AiIntent.deleteExpense) {
        await expenseRepository.deleteExpense(selectedTarget.expenseId);
      } else {
        throw StateError('Unsupported AI command confirmation.');
      }

      if (actionLogId != null) {
        await _actionLogRepository?.updateActionLogStatus(
          actionId: actionLogId,
          status: AiActionLogStatus.confirmed,
          confirmedAt: DateTime.now(),
          targetExpenseId: selectedTarget.expenseId,
        );
      }

      emit(state.copyWith(status: AiAssistantStatus.confirmed));
      return true;
    } catch (error) {
      if (actionLogId != null) {
        await _actionLogRepository?.updateActionLogStatus(
          actionId: actionLogId,
          status: AiActionLogStatus.failed,
          targetExpenseId: selectedTarget.expenseId,
          errorMessage: error.toString(),
        );
      }
      emit(
        state.copyWith(
          status: AiAssistantStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> cancelCommand() async {
    final actionLogId = state.actionLogId;
    if (actionLogId != null) {
      await _actionLogRepository?.updateActionLogStatus(
        actionId: actionLogId,
        status: AiActionLogStatus.canceled,
      );
    }
    cancel();
  }

  Future<void> markCurrentActionConfirmed({String? targetExpenseId}) async {
    final actionLogId = state.actionLogId;
    if (actionLogId == null) return;
    await _actionLogRepository?.updateActionLogStatus(
      actionId: actionLogId,
      status: AiActionLogStatus.confirmed,
      confirmedAt: DateTime.now(),
      targetExpenseId: targetExpenseId,
    );
  }

  void cancel() {
    emit(const AiAssistantState());
  }

  void reset() {
    emit(const AiAssistantState());
  }

  Future<String?> _logPreview({
    required String? userId,
    required String input,
    required AiResponse response,
  }) async {
    final repository = _actionLogRepository;
    if (repository == null || userId == null || userId.isEmpty) return null;
    final actionId = const Uuid().v1();
    await repository.createActionLog(
      AiActionLog(
        actionId: actionId,
        userId: userId,
        rawInput: input,
        parsedResponse: Map<String, Object?>.from(
          jsonDecode(response.rawJson) as Map<String, dynamic>,
        ),
        intent: response.intent.value,
        confidence: response.confidence,
        status: AiActionLogStatus.previewed,
        createdAt: DateTime.now(),
        provider: response.providerMetadata?.provider,
        model: response.providerMetadata?.model,
        providerRequestId: response.providerMetadata?.requestId,
        inputTokens: response.providerMetadata?.inputTokens,
        outputTokens: response.providerMetadata?.outputTokens,
        errorCode: response.errorCode,
      ),
    );
    return actionId;
  }

  Future<void> _logFailure({
    required String? userId,
    required String input,
    required Object error,
  }) async {
    final repository = _actionLogRepository;
    if (repository == null || userId == null || userId.isEmpty) return;
    final gatewayError = error is AiGatewayException ? error : null;
    final actionId = const Uuid().v1();
    await repository.createActionLog(
      AiActionLog(
        actionId: actionId,
        userId: userId,
        rawInput: input,
        parsedResponse: const {},
        intent: 'unknown',
        confidence: 0,
        status: AiActionLogStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: gatewayError?.userMessage ?? error.toString(),
        provider: gatewayError?.provider,
        model: gatewayError?.model,
        providerRequestId: gatewayError?.requestId,
        errorCode: gatewayError?.code.value,
      ),
    );
  }

  Expense _updatedExpenseFromPayload(
      Expense expense, AiExpensePayload payload) {
    final category = _categoryFromPayload(expense.category, payload);
    return Expense(
      expenseId: expense.expenseId,
      userId: expense.userId,
      category: category,
      categoryId: category.categoryId,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColor: category.color,
      date: payload.date ?? expense.date,
      amount: payload.amount ?? expense.amount,
      description: payload.description?.trim().isNotEmpty == true
          ? payload.description!.trim()
          : expense.description,
      paymentMethod: payload.paymentMethod ?? expense.paymentMethod,
      currency: payload.currency ?? expense.currency,
      createdAt: expense.createdAt,
      updatedAt: DateTime.now(),
      source: expense.source,
      recurringExpenseId: expense.recurringExpenseId,
      aiActionId: state.actionLogId,
      moneySnapshot: _preservedSnapshotForPayload(expense, payload),
    );
  }

  MoneySnapshot? _preservedSnapshotForPayload(
    Expense expense,
    AiExpensePayload payload,
  ) {
    final changesMoney = payload.amount != null ||
        payload.currency != null ||
        payload.date != null;
    return changesMoney ? null : expense.moneySnapshot;
  }

  Category _categoryFromPayload(Category fallback, AiExpensePayload payload) {
    final categoryName = payload.categoryName?.trim();
    if (categoryName == null || categoryName.isEmpty) return fallback;
    return Category(
      categoryId: payload.categoryId ?? fallback.categoryId,
      userId: fallback.userId,
      name: categoryName,
      totalExpenses: fallback.totalExpenses,
      icon: fallback.icon,
      color: fallback.color,
      isArchived: fallback.isArchived,
      createdAt: fallback.createdAt,
      updatedAt: fallback.updatedAt,
    );
  }

  String _filterSummary(ExpenseFilter filter) {
    final parts = <String>[
      if (filter.query.trim().isNotEmpty) 'text "${filter.query.trim()}"',
      if (filter.categoryIds.isNotEmpty)
        'categories ${filter.categoryIds.join(', ')}',
      if (filter.paymentMethods.isNotEmpty)
        'payments ${filter.paymentMethods.map((method) => method.label).join(', ')}',
      if (filter.currency?.trim().isNotEmpty == true) filter.currency!,
    ];
    return parts.isEmpty
        ? 'Ready to open all expenses.'
        : 'Ready to open filtered expenses by ${parts.join(', ')}.';
  }

  String _summaryMessage(ExpenseReport report) {
    final topCategory = report.topCategory;
    final topText = topCategory == null
        ? 'No top category for this period.'
        : 'Top category is ${topCategory.categoryName} with '
            '${topCategory.total.toStringAsFixed(0)} ${report.currency}.';
    return 'Total spending is ${report.total.toStringAsFixed(0)} '
        '${report.currency}. $topText';
  }

  String _parserClarification(AiResponseParserException error) {
    if (error.message.contains('missing required fields')) {
      return 'I need the amount, category, date, and payment method before preparing the preview.';
    }
    if (error.message.contains('Amount is required')) {
      return 'I need a valid amount before preparing the preview.';
    }
    return 'I could not understand the AI response. Please add more details.';
  }

  bool _mentionsLast(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('last') ||
        normalized.contains('اخر') ||
        normalized.contains('آخر');
  }

  AiUsageRequestType? _staleUsageRequestType(AiResponse response) {
    if (response.providerMetadata == null || response.usageStatus != null) {
      return null;
    }
    return AiUsageRequestType.parseText;
  }
}
