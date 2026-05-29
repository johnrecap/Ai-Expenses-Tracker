import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/cubit/ai_assistant_cubit.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_controller.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_service.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/ai_text_input.dart';
import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:expenses_tracker/widgets/app_status_banner.dart';
import 'package:expenses_tracker/widgets/finance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiExpenseCapturePanel extends AiExpenseFormFillCard {
  const AiExpenseCapturePanel({
    required super.categories,
    required super.currencies,
    required super.defaultCurrency,
    required super.defaultPaymentMethod,
    required super.onPreviewReady,
    required super.onSettingsRetry,
    super.settingsReady,
    super.expenses,
    super.onDraftPreviewReady,
    super.key,
  });
}

class AiExpenseFormFillCard extends StatefulWidget {
  const AiExpenseFormFillCard({
    required this.categories,
    required this.currencies,
    required this.defaultCurrency,
    required this.defaultPaymentMethod,
    required this.onPreviewReady,
    required this.onSettingsRetry,
    this.settingsReady = true,
    this.expenses = const [],
    this.onDraftPreviewReady,
    super.key,
  });

  final List<Category> categories;
  final List<String> currencies;
  final String? defaultCurrency;
  final PaymentMethod? defaultPaymentMethod;
  final bool settingsReady;
  final List<Expense> expenses;
  final ValueChanged<AiActionPreview> onPreviewReady;
  final void Function(AiExpenseDraft draft, AiActionPreview preview)?
  onDraftPreviewReady;
  final VoidCallback onSettingsRetry;

  @override
  State<AiExpenseFormFillCard> createState() => _AiExpenseFormFillCardState();
}

class _AiExpenseFormFillCardState extends State<AiExpenseFormFillCard> {
  final TextEditingController _controller = TextEditingController();
  late final AiAssistantCubit _cubit;
  late final AiVoiceInputController _voiceController;
  List<CategoryAlias> _categoryAliases = const [];

  @override
  void initState() {
    super.initState();
    _cubit = AiAssistantCubit(
      aiService: _createAiService(),
      actionLogRepository: _tryRead<AiActionLogRepository>(),
      categoryAliasRepository: _tryRead<CategoryAliasRepository>(),
    );
    _voiceController = AiVoiceInputController(
      service: SpeechToTextVoiceInputService(),
    );
    _loadCategoryAliases();
  }

  @override
  void dispose() {
    _controller.dispose();
    _voiceController.close();
    _cubit.close();
    super.dispose();
  }

  AiService _createAiService() {
    final authRepository = _tryRead<AuthRepository>();
    if (authRepository == null) return const MockAiService();
    return AiServiceFactory.create(
      config: AiProviderConfig.fromEnvironment(),
      authRepository: authRepository,
    );
  }

  T? _tryRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadCategoryAliases() async {
    final repository = _tryRead<CategoryAliasRepository>();
    if (repository == null) return;
    try {
      final aliases = await repository.getAliases();
      if (!mounted) return;
      setState(() => _categoryAliases = aliases);
    } catch (_) {
      // Alias loading should not block quick add; category names still resolve.
    }
  }

  Future<void> _fillForm() async {
    final aiContext = _aiContext();
    if (_voiceController.state.canStop) {
      await _voiceController.stopListening();
    }
    await _cubit.parseText(_controller.text, context: aiContext);
  }

  AiContext _aiContext() {
    final currency = widget.defaultCurrency?.trim().toUpperCase();
    final defaultCurrency = currency == null || currency.isEmpty
        ? UserSettings.defaultBaseCurrency
        : currency;
    return AiContext(
      now: DateTime.now(),
      userId: _tryRead<AuthRepository>()?.currentUser?.userId,
      categories: widget.categories,
      categoryAliases: _categoryAliases,
      expenses: widget.expenses,
      defaultCurrency: defaultCurrency,
      defaultPaymentMethod:
          widget.defaultPaymentMethod ?? UserSettings.defaultPaymentMethodValue,
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider<AiAssistantCubit>.value(
      value: _cubit,
      child: BlocConsumer<AiAssistantCubit, AiAssistantState>(
        listener: (context, state) {
          if (state.status == AiAssistantStatus.previewReady &&
              state.preview != null) {
            final preview = state.preview!;
            final draft = state.draft ?? AiExpenseDraft.fromPreview(preview);
            widget.onDraftPreviewReady?.call(draft, preview);
            if (widget.onDraftPreviewReady == null) {
              widget.onPreviewReady(preview);
            }
            _showSnack(context.l10n.aiFormFillApplied);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AiAssistantStatus.parsing;
          final message = switch (state.status) {
            AiAssistantStatus.needsClarification =>
              state.clarifyingQuestion ?? context.l10n.aiFormFillNeedsReview,
            AiAssistantStatus.failure =>
              state.errorMessage ?? context.l10n.aiFormFillFailed,
            _ => null,
          };
          final isError = state.status == AiAssistantStatus.failure;
          return FinanceCard(
            leadingAccent: colorScheme.primary,
            backgroundColor: colorScheme.primaryContainer.withValues(
              alpha: 0.22,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.l10n.aiFormFillTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AiTextInput(
                  inputKey: const Key('ai-expense-form-fill-input'),
                  controller: _controller,
                  onSubmit: _fillForm,
                  onClear: () {
                    unawaited(_voiceController.cancelListening());
                    _controller.clear();
                    _cubit.reset();
                  },
                  isLoading: isLoading,
                  voiceController: _voiceController,
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackAction = constraints.maxWidth < 330;
                    final helper = Text(
                      context.l10n.aiFormFillHelper,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    );
                    final action = FilledButton.icon(
                      key: const Key('ai-expense-form-fill-button'),
                      onPressed: isLoading ? null : _fillForm,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_fix_high),
                      label: Text(
                        context.l10n.aiFormFillAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                    if (stackAction) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          helper,
                          const SizedBox(height: AppSpacing.sm),
                          action,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: helper),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(child: action),
                      ],
                    );
                  },
                ),
                if (!widget.settingsReady) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: widget.onSettingsRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                ],
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppStatusBanner(
                    message: message,
                    tone: isError ? AppStatusTone.danger : AppStatusTone.info,
                    icon: isError ? Icons.error_outline : Icons.info_outline,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
