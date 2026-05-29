part of 'ai_assistant_cubit.dart';

enum AiAssistantStatus {
  initial,
  parsing,
  previewReady,
  searchReady,
  summaryReady,
  adviceReady,
  historyReady,
  targetPreviewReady,
  targetSelectionRequired,
  needsClarification,
  failure,
  confirming,
  confirmed,
}

class AiAssistantState extends Equatable {
  const AiAssistantState({
    this.status = AiAssistantStatus.initial,
    this.input = '',
    this.draft,
    this.preview,
    this.lastResponse,
    this.searchFilter,
    this.summaryReport,
    this.advice,
    this.historyAnswer,
    this.targetMatchResult,
    this.selectedTarget,
    this.updatedExpense,
    this.resultMessage,
    this.pendingIntent,
    this.actionLogId,
    this.clarifyingQuestion,
    this.errorMessage,
    this.usageStatus,
    this.staleUsageRequestType,
    this.quotaError,
  });

  final AiAssistantStatus status;
  final String input;
  final AiExpenseDraft? draft;
  final AiActionPreview? preview;
  final AiResponse? lastResponse;
  final ExpenseFilter? searchFilter;
  final ExpenseReport? summaryReport;
  final AiFinancialAdvice? advice;
  final HistoryAnswer? historyAnswer;
  final AiTargetMatchResult? targetMatchResult;
  final Expense? selectedTarget;
  final Expense? updatedExpense;
  final String? resultMessage;
  final AiIntent? pendingIntent;
  final String? actionLogId;
  final String? clarifyingQuestion;
  final String? errorMessage;
  final AiUsageStatus? usageStatus;
  final AiUsageRequestType? staleUsageRequestType;
  final AiQuotaError? quotaError;

  AiAssistantState copyWith({
    AiAssistantStatus? status,
    String? input,
    AiExpenseDraft? draft,
    bool clearDraft = false,
    AiActionPreview? preview,
    bool clearPreview = false,
    AiResponse? lastResponse,
    ExpenseFilter? searchFilter,
    ExpenseReport? summaryReport,
    AiFinancialAdvice? advice,
    HistoryAnswer? historyAnswer,
    AiTargetMatchResult? targetMatchResult,
    Expense? selectedTarget,
    Expense? updatedExpense,
    String? resultMessage,
    AiIntent? pendingIntent,
    String? actionLogId,
    bool clearCommandData = false,
    String? clarifyingQuestion,
    bool clearClarifyingQuestion = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    AiUsageStatus? usageStatus,
    bool clearUsageStatus = false,
    AiUsageRequestType? staleUsageRequestType,
    bool clearStaleUsageRequestType = false,
    AiQuotaError? quotaError,
    bool clearQuotaError = false,
  }) {
    return AiAssistantState(
      status: status ?? this.status,
      input: input ?? this.input,
      draft: clearDraft ? null : draft ?? this.draft,
      preview: clearPreview ? null : preview ?? this.preview,
      lastResponse:
          lastResponse ?? (clearCommandData ? null : this.lastResponse),
      searchFilter:
          searchFilter ?? (clearCommandData ? null : this.searchFilter),
      summaryReport:
          summaryReport ?? (clearCommandData ? null : this.summaryReport),
      advice: advice ?? (clearCommandData ? null : this.advice),
      historyAnswer:
          historyAnswer ?? (clearCommandData ? null : this.historyAnswer),
      targetMatchResult: targetMatchResult ??
          (clearCommandData ? null : this.targetMatchResult),
      selectedTarget:
          selectedTarget ?? (clearCommandData ? null : this.selectedTarget),
      updatedExpense:
          updatedExpense ?? (clearCommandData ? null : this.updatedExpense),
      resultMessage:
          resultMessage ?? (clearCommandData ? null : this.resultMessage),
      pendingIntent:
          pendingIntent ?? (clearCommandData ? null : this.pendingIntent),
      actionLogId: actionLogId ?? (clearCommandData ? null : this.actionLogId),
      clarifyingQuestion: clearClarifyingQuestion
          ? null
          : clarifyingQuestion ?? this.clarifyingQuestion,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      usageStatus: clearUsageStatus ? null : usageStatus ?? this.usageStatus,
      staleUsageRequestType: clearStaleUsageRequestType
          ? null
          : staleUsageRequestType ?? this.staleUsageRequestType,
      quotaError: clearQuotaError ? null : quotaError ?? this.quotaError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        input,
        draft,
        preview,
        lastResponse,
        searchFilter,
        summaryReport,
        advice,
        historyAnswer,
        targetMatchResult,
        selectedTarget,
        updatedExpense,
        resultMessage,
        pendingIntent,
        actionLogId,
        clarifyingQuestion,
        errorMessage,
        usageStatus,
        staleUsageRequestType,
        quotaError,
      ];
}
