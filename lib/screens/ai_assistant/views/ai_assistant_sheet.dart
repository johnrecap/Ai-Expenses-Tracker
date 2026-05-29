import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/cubit/ai_assistant_cubit.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_controller.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_service.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/ai_assistant/utils/ai_defaults_guard.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/ai_action_preview_card.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/ai_text_input.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/financial_advice_button.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/receipt_capture_button.dart';
import 'package:expenses_tracker/screens/expenses/views/expenses_screen.dart';
import 'package:expenses_tracker/screens/recurring_expenses/widgets/recurring_expense_form.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/finance/duplicate_expense_detector.dart';
import 'package:expenses_tracker/services/finance/money_snapshot_service.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:expenses_tracker/widgets/settings_load_guard_card.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({
    required this.userId,
    required this.expenses,
    super.key,
  });

  final String userId;
  final List<Expense> expenses;

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final TextEditingController _inputController = TextEditingController();
  late final AiVoiceInputController _voiceController;
  List<Category> _categories = const [];
  List<CategoryAlias> _categoryAliases = const [];
  List<String> _currencies = const ['EGP', 'USD'];
  String? _defaultCurrency;
  PaymentMethod? _defaultPaymentMethod;
  UserSettings? _settings;
  bool _settingsReady = false;
  bool _settingsLoadFailed = false;
  String _localeTag = 'en-US';
  Budget? _budget;
  String? _pendingAiExpenseId;
  String? _confirmedDuplicateExpenseId;
  AiFinancialAdvicePayload? _providerAdvice;
  AiUsageStatus? _aiUnavailableStatus;

  @override
  void initState() {
    super.initState();
    _voiceController = AiVoiceInputController(
      service: SpeechToTextVoiceInputService(),
    );
    _loadContext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localeTag = localeTagForAppContext(context);
    _voiceController.setPreferredLocaleId(voiceLocaleIdForAppContext(context));
  }

  @override
  void dispose() {
    _voiceController.close();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadContext() async {
    SettingsRepository settingsRepository;
    try {
      settingsRepository = context.read<SettingsRepository>();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _settingsReady = false;
        _settingsLoadFailed = true;
        _defaultCurrency = null;
        _defaultPaymentMethod = null;
        _settings = null;
      });
      return;
    }

    try {
      final settings = await settingsRepository.getSettings();
      final categories = await _loadActiveCategories();
      final budget = await _loadCurrentBudget();
      final aliases = await _loadCategoryAliases();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _currencies = _normalizedCurrencies(settings);
        _defaultCurrency = settings.baseCurrency;
        _defaultPaymentMethod = settings.defaultPaymentMethod;
        _settings = settings;
        _settingsReady = true;
        _settingsLoadFailed = false;
        _budget = budget;
        _categoryAliases = aliases;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _settingsReady = false;
        _settingsLoadFailed = true;
        _defaultCurrency = null;
        _defaultPaymentMethod = null;
        _settings = null;
      });
    }
  }

  Future<List<Category>> _loadActiveCategories() async {
    try {
      final categories =
          await context.read<CategoryRepository>().getCategories();
      return categories.where((category) => !category.isArchived).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Budget?> _loadCurrentBudget() async {
    try {
      final now = DateTime.now();
      return context.read<BudgetRepository>().getCurrentMonthBudget(
            year: now.year,
            month: now.month,
          );
    } catch (_) {
      return null;
    }
  }

  Future<List<CategoryAlias>> _loadCategoryAliases() async {
    try {
      return context.read<CategoryAliasRepository>().getAliases();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _parse(BuildContext context) async {
    final aiContext = _tryAiContext();
    if (aiContext == null) {
      _showSettingsRequiredMessage(context);
      return;
    }
    if (_voiceController.state.canStop) {
      await _voiceController.stopListening();
    }
    if (!context.mounted) return;
    context.read<AiAssistantCubit>().parseText(
          _inputController.text,
          context: aiContext,
        );
  }

  void _updateMonetizationUsage(
    BuildContext context,
    AiUsageStatus? status,
  ) {
    if (status == null) return;
    try {
      context.read<MonetizationCubit>().updateUsage(status);
    } catch (_) {
      // The AI flow must stay usable even when monetization state is absent.
    }
  }

  void _markAiUsageStale(
    BuildContext context,
    AiUsageRequestType requestType,
  ) {
    try {
      context.read<MonetizationCubit>().markUsageStale(requestType);
    } catch (_) {
      // The manual finance flow does not depend on monetization state.
    }
  }

  AiContext? _tryAiContext() {
    if (!hasRequiredAiDefaults(
      settingsReady: _settingsReady,
      defaultCurrency: _defaultCurrency,
      defaultPaymentMethod: _defaultPaymentMethod,
    )) {
      return null;
    }
    return AiContext(
      now: DateTime.now(),
      userId: widget.userId,
      categories: _categories,
      categoryAliases: _categoryAliases,
      expenses: widget.expenses,
      budget: _budget,
      settings: _settings,
      defaultCurrency: _defaultCurrency!,
      defaultPaymentMethod: _defaultPaymentMethod!,
      locale: _localeTag,
    );
  }

  void _showSettingsRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.settingsLoadRequiredForAi)),
      );
  }

  List<String> _normalizedCurrencies(UserSettings settings) {
    final values = <String>[];
    for (final code in [
      if (settings.supportedCurrencies.isEmpty)
        ..._currencies
      else
        ...settings.supportedCurrencies,
      settings.baseCurrency,
    ]) {
      final currency = code.trim().toUpperCase();
      if (currency.isEmpty || values.contains(currency)) continue;
      values.add(currency);
    }
    return values;
  }

  Future<void> _confirm(BuildContext context) async {
    if (_tryAiContext() == null) {
      _showSettingsRequiredMessage(context);
      return;
    }
    final cubit = context.read<AiAssistantCubit>();
    var preview = cubit.state.preview;
    if (preview == null) return;

    if (preview.category == null &&
        preview.categoryResolution?.suggestedCategory != null) {
      final suggestion = preview.categoryResolution!.suggestedCategory!;
      final category = Category(
        categoryId: const Uuid().v1(),
        userId: widget.userId,
        name: preview.categoryName.trim().isNotEmpty
            ? preview.categoryName.trim()
            : suggestion.name,
        totalExpenses: 0,
        icon: suggestion.icon,
        color: suggestion.color,
      );
      try {
        await context.read<CategoryRepository>().createCategory(category);
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToCreateAiSuggestedCategory),
            ),
          );
        return;
      }
      if (!context.mounted) return;
      setState(() {
        _categories = [..._categories, category];
      });
      preview = preview.copyWith(
        category: category,
        categoryName: category.name,
        categoryResolution: preview.categoryResolution?.copyWith(
          categoryId: category.categoryId,
          categoryName: category.name,
          source: AiCategoryResolutionSource.manual,
          clearSuggestedCategory: true,
        ),
      );
      cubit.updatePreview(preview);
    }

    final duplicateDraft = preview.toExpense(userId: widget.userId);
    final duplicate = const DuplicateExpenseDetector().bestCandidate(
      draft: duplicateDraft,
      existingExpenses: widget.expenses,
    );
    if (duplicate != null &&
        _confirmedDuplicateExpenseId != duplicate.expense.expenseId) {
      final saveAnyway = await _showDuplicateWarning(context, duplicate);
      if (!context.mounted || !saveAnyway) return;
      _confirmedDuplicateExpenseId = duplicate.expense.expenseId;
    }
    final expense = cubit.confirmPreview(
      userId: widget.userId,
      locale: _localeTag,
    );
    if (expense == null) return;
    final settings = _settings;
    if (settings == null) {
      _showSettingsRequiredMessage(context);
      return;
    }
    final snapshotResult = const MoneySnapshotService().snapshotForExpense(
      expense: expense,
      settings: settings,
    );
    if (!snapshotResult.hasSnapshot) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.unconvertedCurrenciesStatus(
                1,
                snapshotResult.missingCurrency ?? expense.currency,
              ),
            ),
          ),
        );
      return;
    }
    expense.moneySnapshot = snapshotResult.snapshot;
    _pendingAiExpenseId = expense.expenseId;
    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  Future<bool> _showDuplicateWarning(
    BuildContext context,
    DuplicateExpenseCandidate candidate,
  ) async {
    final existing = candidate.expense;
    final categoryName = existing.categoryName.isNotEmpty
        ? existing.categoryName
        : existing.category.name;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.possibleDuplicateExpense),
        content: Text(
          context.l10n.possibleDuplicateExpenseMessage(
            formatAmountInput(existing.amount),
            existing.currency,
            categoryName,
            DateFormat(
              'dd/MM/yyyy',
              Localizations.localeOf(context).toLanguageTag(),
            ).format(existing.date),
            _duplicateReasonLabels(context, candidate).join(', '),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.saveAnyway),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<String> _duplicateReasonLabels(
    BuildContext context,
    DuplicateExpenseCandidate candidate,
  ) {
    return candidate.reasons.map((reason) {
      return switch (reason) {
        DuplicateExpenseReason.sameDay => context.l10n.duplicateReasonSameDay,
        DuplicateExpenseReason.sameAmount =>
          context.l10n.duplicateReasonSameAmount,
        DuplicateExpenseReason.sameCategory =>
          context.l10n.duplicateReasonSameCategory,
        DuplicateExpenseReason.sameMerchant =>
          context.l10n.duplicateReasonSameMerchant,
      };
    }).toList();
  }

  Future<void> _confirmCommand(BuildContext context) async {
    final confirmed = await context.read<AiAssistantCubit>().confirmCommand();
    if (!context.mounted || !confirmed) return;
    Navigator.pop(context, true);
  }

  void _openSearch(BuildContext context, ExpenseFilter filter) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExpensesScreen(
          expenses: widget.expenses,
          initialFilter: filter,
        ),
      ),
    );
  }

  Future<void> _openRecurringSuggestion(
    BuildContext context,
    RepeatedExpenseSuggestion suggestion,
  ) async {
    final paymentMethod = _defaultPaymentMethod;
    if (!hasRequiredAiDefaults(
          settingsReady: _settingsReady,
          defaultCurrency: _defaultCurrency,
          defaultPaymentMethod: paymentMethod,
        ) ||
        paymentMethod == null) {
      _showSettingsRequiredMessage(context);
      return;
    }
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.createCategoryBeforeSavingRecurrence),
          ),
        );
      return;
    }
    final category = _categories.firstWhere(
      (category) =>
          category.name.toLowerCase() == suggestion.categoryName.toLowerCase(),
      orElse: () => _categories.first,
    );
    final now = DateTime.now();
    final initialRule = RecurringExpense(
      recurringExpenseId: const Uuid().v1(),
      userId: widget.userId,
      amount: suggestion.averageAmount,
      category: category,
      description: suggestion.description,
      paymentMethod: paymentMethod,
      currency: suggestion.currency,
      startDate: suggestion.lastDate,
      nextRunDate: suggestion.lastDate,
      frequency: suggestion.frequency,
      createdAt: now,
      updatedAt: now,
    );
    final rule = await showDialog<RecurringExpense>(
      context: context,
      builder: (_) => RecurringExpenseForm(
        categories: _categories,
        initialRule: initialRule,
        currencies: _currencies,
      ),
    );
    if (!context.mounted || rule == null) return;
    await context
        .read<RecurringExpenseRepository>()
        .createRecurringExpense(rule);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.recurringExpenseSuggestionSaved),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final config = AiProviderConfig.fromEnvironment();
    final authRepository = context.read<AuthRepository>();
    final gatewayClient = AiGatewayClient(
      config: config,
      tokenProvider: authRepository.getIdToken,
    );
    final aiContext = _tryAiContext();
    final receiptService = GatewayReceiptAiService(client: gatewayClient);
    final adviceService =
        GatewayFinancialAdviceAiService(client: gatewayClient);
    final repeatedSuggestions = aiContext != null
        ? const RepeatedExpenseDetector()
            .detect(widget.expenses)
            .take(2)
            .toList()
        : const <RepeatedExpenseSuggestion>[];
    final prediction = aiContext != null
        ? const SpendingPredictionService().predictMonth(
            expenses: widget.expenses,
            now: aiContext.now,
            currency: aiContext.defaultCurrency,
          )
        : null;
    return BlocProvider(
      create: (context) => AiAssistantCubit(
        aiService: AiServiceFactory.create(
          config: config,
          authRepository: authRepository,
        ),
        expenseRepository: context.read<ExpenseRepository>(),
        actionLogRepository: context.read<AiActionLogRepository>(),
        categoryAliasRepository: context.read<CategoryAliasRepository>(),
      ),
      child: BlocListener<CreateExpenseBloc, CreateExpenseState>(
        listener: (context, state) {
          if (state is CreateExpenseSuccess) {
            context.read<AiAssistantCubit>().markCurrentActionConfirmed(
                targetExpenseId: _pendingAiExpenseId);
            Navigator.pop(context, true);
          }
          if (state is CreateExpenseFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(context.l10n.failedToSaveAiExpense)),
              );
          }
        },
        child: BlocConsumer<AiAssistantCubit, AiAssistantState>(
          listenWhen: (previous, current) =>
              previous.usageStatus != current.usageStatus ||
              previous.staleUsageRequestType != current.staleUsageRequestType ||
              previous.quotaError != current.quotaError,
          listener: (context, state) {
            _updateMonetizationUsage(context, state.usageStatus);
            final staleUsageRequestType = state.staleUsageRequestType;
            if (staleUsageRequestType != null) {
              _markAiUsageStale(context, staleUsageRequestType);
            }
            final quotaError = state.quotaError;
            if (quotaError != null &&
                quotaError.category != AiQuotaErrorCategory.quotaExhausted) {
              _markAiUsageStale(
                context,
                quotaError.requestType ?? AiUsageRequestType.parseText,
              );
            }
          },
          builder: (context, state) {
            final isParsing = state.status == AiAssistantStatus.parsing;
            final isConfirming = state.status == AiAssistantStatus.confirming;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.aiAssistant,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            tooltip: context.l10n.close,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!kReleaseMode) ...[
                        _InternalAiStatusCard(
                          config: config,
                          state: state,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_settingsLoadFailed) ...[
                        SettingsLoadGuardCard(
                          message: context.l10n.settingsLoadRequiredForAi,
                          onRetry: _loadContext,
                        ),
                        const SizedBox(height: 8),
                      ],
                      AiTextInput(
                        controller: _inputController,
                        onSubmit: () => _parse(context),
                        onClear: () async {
                          await _voiceController.cancelListening();
                          _inputController.clear();
                          if (!context.mounted) return;
                          context.read<AiAssistantCubit>().reset();
                        },
                        isLoading: isParsing,
                        voiceController: _voiceController,
                      ),
                      StreamBuilder<AiVoiceInputState>(
                        stream: _voiceController.stream,
                        initialData: _voiceController.state,
                        builder: (context, snapshot) {
                          return _VoiceStatusMessage(
                            state: snapshot.data ?? const AiVoiceInputState(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      if (aiContext != null)
                        Row(
                          children: [
                            Expanded(
                              child: ReceiptCaptureButton(
                                service: receiptService,
                                aiContext: aiContext,
                                onExtracted: (result) {
                                  final currentContext = _tryAiContext();
                                  if (currentContext == null) {
                                    _showSettingsRequiredMessage(context);
                                    return;
                                  }
                                  final payload = result.payload;
                                  if (payload == null) return;
                                  final status = result.usageStatus;
                                  _updateMonetizationUsage(context, status);
                                  setState(() {
                                    _aiUnavailableStatus =
                                        status?.fallbackReason !=
                                                    AiFallbackReason.none ||
                                                status?.message != null
                                            ? status
                                            : null;
                                  });
                                  context
                                      .read<AiAssistantCubit>()
                                      .showReceiptPreview(
                                        payload,
                                        context: currentContext,
                                        usageStatus: result.usageStatus,
                                      );
                                },
                                onUnavailable: (status) {
                                  _updateMonetizationUsage(context, status);
                                  if (status.fallbackReason !=
                                      AiFallbackReason.quotaExhausted) {
                                    _markAiUsageStale(
                                      context,
                                      status.requestType,
                                    );
                                  }
                                  setState(() => _aiUnavailableStatus = status);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FinancialAdviceButton(
                                service: adviceService,
                                aiContext: aiContext,
                                onAdvice: (advice) {
                                  _updateMonetizationUsage(
                                    context,
                                    advice.usageStatus,
                                  );
                                  if (advice.usageStatus?.allowed == false &&
                                      advice.usageStatus?.fallbackReason !=
                                          AiFallbackReason.quotaExhausted) {
                                    _markAiUsageStale(
                                      context,
                                      AiUsageRequestType.financialAdvice,
                                    );
                                  }
                                  setState(() => _providerAdvice = advice);
                                },
                              ),
                            ),
                          ],
                        ),
                      if (_aiUnavailableStatus != null)
                        _UsageStatusCard(status: _aiUnavailableStatus!),
                      if (_providerAdvice != null)
                        _ProviderAdviceCard(advice: _providerAdvice!),
                      if (prediction != null)
                        _PredictionCard(prediction: prediction),
                      for (final suggestion in repeatedSuggestions)
                        _RepeatedSuggestionCard(
                          suggestion: suggestion,
                          onAccept: () =>
                              _openRecurringSuggestion(context, suggestion),
                        ),
                      if (state.status == AiAssistantStatus.needsClarification)
                        _MessageBox(
                          message: state.clarifyingQuestion ??
                              context.l10n.pleaseAddMoreDetails,
                          isError: false,
                        ),
                      if (state.status == AiAssistantStatus.failure)
                        _MessageBox(
                          message: state.errorMessage ??
                              context.l10n.couldNotParseExpense,
                          isError: true,
                        ),
                      if (state.searchFilter != null)
                        _CommandResultCard(
                          title: context.l10n.searchReady,
                          message: state.resultMessage ??
                              context.l10n.readyToOpenFilteredExpenses,
                          actionLabel: context.l10n.openResults,
                          onAction: () =>
                              _openSearch(context, state.searchFilter!),
                        ),
                      if (state.historyAnswer != null)
                        _HistoryAnswerCard(
                          answer: state.historyAnswer!,
                          onOpenResults: state.historyAnswer!.filter == null
                              ? null
                              : () => _openSearch(
                                    context,
                                    state.historyAnswer!.filter!,
                                  ),
                        ),
                      if (state.summaryReport != null)
                        _SummaryCard(report: state.summaryReport!),
                      if (state.advice != null)
                        _AdviceCard(advice: state.advice!),
                      if (state.targetMatchResult != null)
                        _TargetCommandCard(
                          state: state,
                          onSelect:
                              context.read<AiAssistantCubit>().selectTarget,
                          onConfirm: () => _confirmCommand(context),
                          onCancel:
                              context.read<AiAssistantCubit>().cancelCommand,
                        ),
                      if (state.preview != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: AiActionPreviewCard(
                            preview: state.preview!,
                            categories: _categories,
                            currencies: _currencies,
                            onChanged:
                                context.read<AiAssistantCubit>().updatePreview,
                            onConfirm: () => _confirm(context),
                            isConfirming: isConfirming,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

class _InternalAiStatusCard extends StatelessWidget {
  const _InternalAiStatusCard({
    required this.config,
    required this.state,
  });

  final AiProviderConfig config;
  final AiAssistantState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = config.enabled ? 'Gateway enabled' : 'Mock fallback';
    final detail = config.enabled
        ? '${config.provider} / ${config.model} / ${config.timeout.inSeconds}s'
        : 'AI_GATEWAY_URL is not set. Provider-backed AI is disabled.';
    final usageDetail = state.staleUsageRequestType == null
        ? 'usage live when Worker quota metadata arrives'
        : '${state.staleUsageRequestType!.label} usage waiting for '
            'Worker metadata';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              config.enabled
                  ? Icons.cloud_done_outlined
                  : Icons.science_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$status - $detail - $usageDetail',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceStatusMessage extends StatelessWidget {
  const _VoiceStatusMessage({required this.state});

  final AiVoiceInputState state;

  @override
  Widget build(BuildContext context) {
    final message = _messageForState(context, state);
    if (message == null) return const SizedBox.shrink();
    final isError = state.status == AiVoiceInputStatus.permissionDenied ||
        state.status == AiVoiceInputStatus.unavailable ||
        state.status == AiVoiceInputStatus.failure;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? colorScheme.error : colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String? _messageForState(BuildContext context, AiVoiceInputState state) {
    switch (state.status) {
      case AiVoiceInputStatus.initializing:
        return context.l10n.preparingVoiceInput;
      case AiVoiceInputStatus.listening:
        return context.l10n.listeningVoiceInput;
      case AiVoiceInputStatus.pausedByPlatform:
      case AiVoiceInputStatus.permissionDenied:
      case AiVoiceInputStatus.unavailable:
      case AiVoiceInputStatus.failure:
        return state.errorMessage;
      case AiVoiceInputStatus.idle:
      case AiVoiceInputStatus.stopped:
        return null;
    }
  }
}

class _CommandResultCard extends StatelessWidget {
  const _CommandResultCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final topCategory = report.topCategory;
    return _CommandResultCard(
      title: context.l10n.summary,
      message: [
        context.l10n.totalAmountLabel(
          formatAmountWithCurrency(report.total, report.currency),
        ),
        if (topCategory != null)
          context.l10n.topCategoryWithAmount(
            topCategory.categoryName,
            formatAmountWithCurrency(topCategory.total, report.currency),
          ),
        if (report.ignoredCurrencyCount > 0)
          context.l10n.ignoredOtherCurrencyExpensesBecause(
            report.ignoredCurrencyCount,
          ),
      ].join('\n'),
    );
  }
}

class _HistoryAnswerCard extends StatelessWidget {
  const _HistoryAnswerCard({
    required this.answer,
    this.onOpenResults,
  });

  final HistoryAnswer answer;
  final VoidCallback? onOpenResults;

  @override
  Widget build(BuildContext context) {
    final report = answer.report;
    final driver = answer.driver;
    final lines = <String>[
      answer.message,
      if (report != null && report.topCategory != null)
        context.l10n.topCategoryWithAmount(
          report.topCategory!.categoryName,
          formatAmountWithCurrency(report.topCategory!.total, report.currency),
        ),
      if (driver != null)
        'Driver: ${driver.categoryName} (${formatAmountWithCurrency(driver.difference, report?.currency ?? 'EGP')})',
      if (answer.matchingExpenses.isNotEmpty)
        '${answer.matchingExpenses.length} matching expense(s).',
      if (report != null && report.ignoredCurrencyCount > 0)
        context.l10n.ignoredOtherCurrencyExpensesBecause(
          report.ignoredCurrencyCount,
        ),
      'Source: deterministic local history',
    ];
    return _CommandResultCard(
      title: answer.isMutationRefusal ? context.l10n.aiNeedsReview : 'History',
      message: lines.join('\n'),
      actionLabel: onOpenResults == null ? null : context.l10n.openResults,
      onAction: onOpenResults,
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.advice});

  final AiFinancialAdvice advice;

  @override
  Widget build(BuildContext context) {
    return _CommandResultCard(
      title: context.l10n.financialAdvice,
      message: [
        advice.message,
        '',
        ...advice.evidence,
      ].join('\n'),
    );
  }
}

class _ProviderAdviceCard extends StatelessWidget {
  const _ProviderAdviceCard({required this.advice});

  final AiFinancialAdvicePayload advice;

  @override
  Widget build(BuildContext context) {
    final remaining = advice.usageStatus?.remaining;
    return _CommandResultCard(
      title: advice.usageStatus?.allowed == false
          ? context.l10n.localAdviceFallback
          : context.l10n.aiFinancialAdvice,
      message: [
        advice.advice,
        if (advice.groundedSummary.isNotEmpty) '',
        if (advice.groundedSummary.isNotEmpty) advice.groundedSummary,
        if (advice.categoryDrivers.isNotEmpty) '',
        for (final driver in advice.categoryDrivers.take(3))
          '${driver.category}: ${formatAmountWithCurrency(driver.amount, driver.currency ?? 'EGP')}',
        if (remaining != null) '',
        if (remaining != null)
          context.l10n.aiAdviceRequestsLeftToday(remaining),
        if (advice.qualityNote?.trim().isNotEmpty == true) '',
        if (advice.qualityNote?.trim().isNotEmpty == true)
          advice.qualityNote!.trim(),
      ].join('\n'),
    );
  }
}

class _UsageStatusCard extends StatelessWidget {
  const _UsageStatusCard({required this.status});

  final AiUsageStatus status;

  @override
  Widget build(BuildContext context) {
    return _CommandResultCard(
      title: status.allowed
          ? context.l10n.aiNeedsReview
          : context.l10n.aiUnavailable,
      message:
          status.message ?? context.l10n.providerAiUnavailableManualStillWorks,
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.prediction});

  final AiPredictionPayload prediction;

  @override
  Widget build(BuildContext context) {
    if (prediction.expectedTotal <= 0 && prediction.categoryDrivers.isEmpty) {
      return const SizedBox.shrink();
    }
    return _CommandResultCard(
      title: context.l10n.localSpendingPrediction,
      message: [
        context.l10n.expectedThisMonth(
          formatAmountWithCurrency(
            prediction.expectedTotal,
            prediction.currency,
          ),
        ),
        for (final driver in prediction.categoryDrivers.take(3))
          '${driver.category}: ${formatAmountWithCurrency(driver.expectedAmount, prediction.currency)}',
        '',
        prediction.qualityNote,
      ].join('\n'),
    );
  }
}

class _RepeatedSuggestionCard extends StatelessWidget {
  const _RepeatedSuggestionCard({
    required this.suggestion,
    required this.onAccept,
  });

  final RepeatedExpenseSuggestion suggestion;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return _CommandResultCard(
      title: context.l10n.repeatedExpenseFound,
      message: [
        context.l10n.repeatedExpenseLooksFrequency(
          suggestion.description,
          localizedRecurringFrequency(context.l10n, suggestion.frequency)
              .toLowerCase(),
        ),
        context.l10n.matchingExpensesAverage(
          suggestion.sampleCount,
          formatAmountWithCurrency(
            suggestion.averageAmount,
            suggestion.currency,
          ),
        ),
      ].join('\n'),
      actionLabel: context.l10n.reviewRecurring,
      onAction: onAccept,
    );
  }
}

class _TargetCommandCard extends StatelessWidget {
  const _TargetCommandCard({
    required this.state,
    required this.onSelect,
    required this.onConfirm,
    required this.onCancel,
  });

  final AiAssistantState state;
  final ValueChanged<AiTargetMatch> onSelect;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final matches = state.targetMatchResult?.candidates ?? const [];
    final selected = state.selectedTarget;
    final isDelete = state.pendingIntent == AiIntent.deleteExpense;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isDelete
                  ? context.l10n.confirmDelete
                  : context.l10n.confirmUpdate,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (selected == null) ...[
              Text(context.l10n.chooseExactExpenseFirst),
              const SizedBox(height: 8),
              for (final match in matches)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_expenseTitle(match.expense)),
                  subtitle: Text(match.reason),
                  trailing: Text(match.score.toStringAsFixed(0)),
                  onTap: () => onSelect(match),
                ),
            ] else ...[
              _ExpenseSummary(label: context.l10n.target, expense: selected),
              if (!isDelete && state.updatedExpense != null) ...[
                const SizedBox(height: 8),
                _ExpenseSummary(
                  label: context.l10n.after,
                  expense: state.updatedExpense!,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: state.status == AiAssistantStatus.confirming
                          ? null
                          : onConfirm,
                      child: Text(
                        isDelete ? context.l10n.delete : context.l10n.update,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _expenseTitle(Expense expense) {
    return '${expense.categoryName} · '
        '${formatAmountWithCurrency(expense.amount, expense.currency)}';
  }
}

class _ExpenseSummary extends StatelessWidget {
  const _ExpenseSummary({
    required this.label,
    required this.expense,
  });

  final String label;
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${expense.categoryName} · '
              '${formatAmountWithCurrency(expense.amount, expense.currency)}',
            ),
            Text(
              DateFormat(
                'dd/MM/yyyy',
                Localizations.localeOf(context).toLanguageTag(),
              ).format(expense.date),
            ),
            if (expense.description.isNotEmpty) Text(expense.description),
          ],
        ),
      ),
    );
  }
}
