import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/models/expense_draft.dart';
import 'package:expenses_tracker/screens/add_expense/utils/expense_form_defaults.dart';
import 'package:expenses_tracker/screens/add_expense/views/category_creation.dart';
import 'package:expenses_tracker/screens/add_expense/widgets/ai_expense_form_fill_card.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/receipt_capture_button.dart';
import 'package:expenses_tracker/services/finance/duplicate_expense_detector.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:expenses_tracker/widgets/settings_load_guard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({
    this.recentExpenses = const [],
    this.initialCaptureMode = CaptureMode.quickManual,
    super.key,
  });

  final List<Expense> recentExpenses;
  final CaptureMode initialCaptureMode;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController merchantController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<String> currencies = UserSettings.defaultSupportedCurrencies;
  // DateTime selectDate = DateTime.now();
  late Expense expense;
  bool isLoading = false;
  Category? _pendingCategory;
  bool _loadedSettingsDefaults = false;
  bool _settingsLoadFailed = false;
  PaymentMethod? _selectedPaymentMethod;
  String? _selectedCurrency;
  String? _lastDateLocaleTag;
  CaptureMode _captureMode = CaptureMode.quickManual;
  bool _showAdvancedFields = false;
  ExpenseDraft? _currentDraft;
  String? _confirmedDuplicateExpenseId;

  @override
  void initState() {
    final now = DateTime.now();
    _captureMode = widget.initialCaptureMode;
    dateController.text = DateFormat('dd/MM/yyyy').format(now);
    expense = Expense(
      expenseId: const Uuid().v1(),
      category: Category.empty,
      date: now,
      amount: 0,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    if (_lastDateLocaleTag != localeTag) {
      _lastDateLocaleTag = localeTag;
      dateController.text = _formatDate(expense.date);
    }
    if (_loadedSettingsDefaults) return;
    _loadedSettingsDefaults = true;
    _loadSettingsDefaults();
  }

  @override
  void dispose() {
    expenseController.dispose();
    descriptionController.dispose();
    merchantController.dispose();
    tagsController.dispose();
    categoryController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _selectCategory(Category category) {
    setState(() {
      expense.category = category;
      categoryController.text = category.name;
      _syncDraft(
        sourceStatus: _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
        statusMessage: _currentDraft?.statusMessage,
        missingFields: _currentDraft?.missingFields ?? const [],
      );
    });
  }

  void _applyAiPreviewToForm(AiActionPreview preview) {
    setState(() {
      if (preview.amount > 0) {
        expenseController.text = formatAmountInput(preview.amount);
      } else {
        expenseController.clear();
      }

      final description = preview.description.trim();
      descriptionController.text =
          description == 'AI expense' ? '' : description;
      merchantController.clear();
      tagsController.clear();

      final category = preview.category;
      if (category != null) {
        expense.category = category;
        categoryController.text = category.name;
      }

      final currency = preview.currency.trim().toUpperCase();
      if (currency.isNotEmpty) {
        if (!currencies.contains(currency)) {
          currencies = [...currencies, currency];
        }
        _selectedCurrency = currency;
      }

      _selectedPaymentMethod = preview.paymentMethod;
      expense.date = preview.date;
      dateController.text = _formatDate(preview.date);
      _showAdvancedFields = true;
      _syncDraft(
        sourceStatus: DraftSourceStatus.aiText,
        statusMessage: preview.validationErrors.isEmpty
            ? context.l10n.quickCaptureDraftReady
            : preview.validationErrors.join(' '),
        missingFields: preview.validationErrors,
      );
    });
  }

  void _syncDraft({
    required DraftSourceStatus sourceStatus,
    String? statusMessage,
    List<String> missingFields = const [],
  }) {
    _currentDraft = ExpenseDraft(
      amountText: expenseController.text,
      category: expense.category == Category.empty ? null : expense.category,
      date: expense.date,
      currency: _selectedCurrency,
      paymentMethod: _selectedPaymentMethod,
      description: descriptionController.text,
      merchant: merchantController.text,
      tags: _parseTags(tagsController.text),
      sourceStatus: sourceStatus,
      statusMessage: statusMessage,
      missingFields: missingFields,
    );
  }

  AiContext _aiContext(List<Category> activeCategories) {
    final currency = _selectedCurrency?.trim().toUpperCase();
    return AiContext(
      now: DateTime.now(),
      userId: _tryRead<AuthRepository>()?.currentUser?.userId,
      categories: activeCategories,
      categoryAliases: const [],
      expenses: const [],
      defaultCurrency: currency == null || currency.isEmpty
          ? UserSettings.defaultBaseCurrency
          : currency,
      defaultPaymentMethod:
          _selectedPaymentMethod ?? UserSettings.defaultPaymentMethodValue,
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
  }

  T? _tryRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  ReceiptAiService? _receiptService() {
    final authRepository = _tryRead<AuthRepository>();
    final config = AiProviderConfig.fromEnvironment();
    if (authRepository == null || !config.enabled) return null;
    return GatewayReceiptAiService(
      client: AiGatewayClient(
        config: config,
        tokenProvider: authRepository.getIdToken,
      ),
    );
  }

  void _applyReceiptResultToForm(
    ReceiptAiResult result,
    List<Category> activeCategories,
  ) {
    final payload = result.payload;
    if (payload == null) return;
    final contextDefaults = _aiContext(activeCategories);
    final preview = AiActionPreview.fromPayload(
      AiExpensePayload(
        amount: payload.amount,
        categoryId: payload.categoryId,
        categoryName: payload.categoryName,
        date: payload.date,
        paymentMethod: contextDefaults.defaultPaymentMethod,
        currency: payload.currency ?? contextDefaults.defaultCurrency,
        description: payload.description ??
            (payload.merchant?.trim().isNotEmpty == true
                ? payload.merchant!.trim()
                : null),
      ),
      categories: activeCategories,
      defaultCurrency: contextDefaults.defaultCurrency,
      defaultPaymentMethod: contextDefaults.defaultPaymentMethod,
      confidence: payload.confidence,
    );
    final missing = payload.missingFields();
    final messages = [
      ...preview.validationErrors,
      if (payload.hasLowConfidence) context.l10n.quickCaptureReceiptReview,
      if (missing.isNotEmpty)
        context.l10n.quickCaptureMissingFields(missing.join(', ')),
      if (result.usageStatus?.message?.trim().isNotEmpty == true)
        result.usageStatus!.message!.trim(),
    ];
    _applyAiPreviewToForm(preview);
    setState(() {
      merchantController.text = payload.merchant ?? '';
      _captureMode = CaptureMode.quickManual;
      _syncDraft(
        sourceStatus: DraftSourceStatus.receipt,
        statusMessage: messages.isEmpty
            ? context.l10n.quickCaptureReceiptApplied
            : messages.join(' '),
        missingFields: messages,
      );
    });
  }

  Future<void> _createCategory() async {
    final createCategoryBloc = context.read<CreateCategoryBloc>();
    final newCategory = await getCategoryCreation(context);
    if (newCategory == null) return;
    if (!mounted) return;
    _pendingCategory = newCategory;
    createCategoryBloc.add(CreateCategory(newCategory));
  }

  Future<void> _showCategoryPicker(List<Category> activeCategories) async {
    if (activeCategories.isEmpty) {
      _showError(context.l10n.noActiveCategoriesYet);
      return;
    }

    final selectedCategory = await showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: activeCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = activeCategories[index];
            return ListTile(
              onTap: () => Navigator.pop(context, category),
              leading: CategoryIconView(
                iconKey: category.icon,
                backgroundColor: Color(category.color),
                size: 40,
                iconSize: 22,
              ),
              title: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              tileColor: Color(category.color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      ),
    );

    if (selectedCategory != null) {
      _selectCategory(selectedCategory);
    }
  }

  Future<void> _loadSettingsDefaults() async {
    SettingsRepository? settingsRepository;
    try {
      settingsRepository = context.read<SettingsRepository>();
    } catch (_) {
      return;
    }

    try {
      final settings = await settingsRepository.getSettings();
      final defaults = ExpenseFormDefaults.fromSettings(
        settings,
        fallbackCurrencies: currencies,
      );
      if (!mounted) return;
      setState(() {
        currencies = defaults.currencies;
        _selectedPaymentMethod = defaults.paymentMethod;
        _selectedCurrency = defaults.currency;
        _settingsLoadFailed = false;
      });
    } catch (_) {
      final defaults = ExpenseFormDefaults.unavailable(
        fallbackCurrencies: currencies,
      );
      if (!mounted) return;
      setState(() {
        currencies = defaults.currencies;
        _selectedPaymentMethod = defaults.paymentMethod;
        _selectedCurrency = defaults.currency;
        _settingsLoadFailed = true;
      });
    }
  }

  Future<void> _saveExpense() async {
    final amount = parseAmountInput(expenseController.text);

    if (amount == null || amount <= 0) {
      _showError(context.l10n.enterValidExpenseAmount);
      return;
    }

    if (expense.category == Category.empty ||
        expense.category.categoryId.isEmpty) {
      _showError(context.l10n.selectCategoryBeforeSaving);
      return;
    }

    final paymentMethod = _selectedPaymentMethod;
    final currency = _selectedCurrency;
    if (paymentMethod == null || currency == null || currency.isEmpty) {
      _showError(context.l10n.chooseCurrencyAndPaymentBeforeSaving);
      return;
    }

    setState(() {
      expense.amount = amount;
      expense.description = descriptionController.text.trim();
      expense.merchant = merchantController.text.trim();
      expense.tags = _parseTags(tagsController.text);
      expense.paymentMethod = paymentMethod;
      expense.currency = currency;
      expense.source = switch (_currentDraft?.sourceStatus) {
        DraftSourceStatus.aiText => ExpenseSource.ai,
        DraftSourceStatus.receipt => ExpenseSource.receipt,
        _ => ExpenseSource.manual,
      };
    });

    final duplicate = const DuplicateExpenseDetector().bestCandidate(
      draft: expense,
      existingExpenses: widget.recentExpenses,
    );
    if (duplicate != null &&
        _confirmedDuplicateExpenseId != duplicate.expense.expenseId) {
      final saveAnyway = await _showDuplicateWarning(duplicate);
      if (!mounted || !saveAnyway) return;
      _confirmedDuplicateExpenseId = duplicate.expense.expenseId;
    }

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  Future<bool> _showDuplicateWarning(
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
            _formatDate(existing.date),
            _duplicateReasonLabels(candidate).join(', '),
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

  List<String> _duplicateReasonLabels(DuplicateExpenseCandidate candidate) {
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

  List<String> _parseTags(String value) {
    final seen = <String>{};
    final tags = <String>[];
    for (final part in value.split(',')) {
      final tag = part.trim();
      if (tag.isEmpty) continue;
      if (seen.add(tag.toLowerCase())) tags.add(tag);
    }
    return tags;
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd/MM/yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  Widget _buildModeSelector() {
    return SegmentedButton<CaptureMode>(
      segments: [
        ButtonSegment(
          value: CaptureMode.quickManual,
          icon: const Icon(Icons.flash_on),
          label: Text(
            context.l10n.quickCaptureQuick,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ButtonSegment(
          value: CaptureMode.naturalLanguage,
          icon: const Icon(Icons.auto_awesome),
          label: Text(
            context.l10n.quickCaptureNatural,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ButtonSegment(
          value: CaptureMode.receipt,
          icon: const Icon(Icons.receipt_long),
          label: Text(
            context.l10n.quickCaptureReceipt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      selected: {_captureMode},
      onSelectionChanged: (selection) {
        setState(() {
          _captureMode = selection.single;
          _showAdvancedFields =
              _showAdvancedFields || _captureMode != CaptureMode.quickManual;
        });
      },
    );
  }

  Widget _buildDraftStatus() {
    final draft = _currentDraft;
    if (draft?.statusMessage == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: draft!.needsReview
            ? colorScheme.errorContainer.withValues(alpha: 0.35)
            : colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        draft.statusMessage!,
        style: TextStyle(
          color: draft.needsReview
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      key: const Key('add-expense-amount-field'),
      controller: expenseController,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {
        _syncDraft(sourceStatus: DraftSourceStatus.manual);
      }),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          FontAwesomeIcons.dollarSign,
          size: 16,
          color: Colors.grey,
        ),
        hintText: context.l10n.amount,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryField(List<Category> activeCategories) {
    return TextFormField(
      key: const Key('add-expense-category-field'),
      controller: categoryController,
      textAlignVertical: TextAlignVertical.center,
      readOnly: true,
      onTap: () => _showCategoryPicker(activeCategories),
      decoration: InputDecoration(
        filled: true,
        fillColor: expense.category == Category.empty
            ? Colors.white
            : Color(expense.category.color),
        prefixIcon: expense.category == Category.empty
            ? const Icon(
                FontAwesomeIcons.list,
                size: 16,
                color: Colors.grey,
              )
            : Padding(
                padding: const EdgeInsets.all(8),
                child: CategoryIconView(
                  iconKey: expense.category.icon,
                  backgroundColor: Color(expense.category.color),
                  size: 32,
                  iconSize: 18,
                ),
              ),
        suffixIcon: IconButton(
          onPressed: _createCategory,
          tooltip: context.l10n.addCategory,
          icon: const Icon(
            FontAwesomeIcons.plus,
            size: 16,
            color: Colors.grey,
          ),
        ),
        hintText: context.l10n.category,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryScroller(List<Category> activeCategories) {
    if (activeCategories.isEmpty) {
      return Text(
        context.l10n.noActiveCategoriesYet,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = activeCategories[index];
          final selected = expense.category.categoryId == category.categoryId;
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => _selectCategory(category),
            avatar: CategoryIconView(
              iconKey: category.icon,
              backgroundColor: Color(category.color),
              size: 28,
              iconSize: 16,
            ),
            label: Text(category.name),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFields() {
    return Column(
      children: [
        TextFormField(
          key: const Key('add-expense-merchant-field'),
          controller: merchantController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (_) => setState(() {
            _syncDraft(
              sourceStatus:
                  _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
            );
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.store,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.merchant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('add-expense-tags-field'),
          controller: tagsController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (_) => setState(() {
            _syncDraft(
              sourceStatus:
                  _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
            );
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.tags,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.tags,
            helperText: context.l10n.tagsHelper,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('add-expense-description-field'),
          controller: descriptionController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (_) => setState(() {
            _syncDraft(
              sourceStatus:
                  _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
            );
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.noteSticky,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.description,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_settingsLoadFailed) ...[
          SettingsLoadGuardCard(
            message: context.l10n.settingsUnavailableMessage,
            onRetry: _loadSettingsDefaults,
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<PaymentMethod>(
          key: ValueKey('payment-${_selectedPaymentMethod?.name ?? 'none'}'),
          initialValue: _selectedPaymentMethod,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.creditCard,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.paymentMethod,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: PaymentMethod.values
              .map(
                (paymentMethod) => DropdownMenuItem(
                  value: paymentMethod,
                  child: Text(localizedPaymentMethod(context.l10n, paymentMethod)),
                ),
              )
              .toList(),
          onChanged: (paymentMethod) {
            if (paymentMethod == null) return;
            setState(() {
              _selectedPaymentMethod = paymentMethod;
              _syncDraft(
                sourceStatus:
                    _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
              );
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('currency-${_selectedCurrency ?? 'none'}'),
          initialValue: _selectedCurrency,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.coins,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.currency,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: currencies
              .map(
                (currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                ),
              )
              .toList(),
          onChanged: (currency) {
            if (currency == null) return;
            setState(() {
              _selectedCurrency = currency;
              _syncDraft(
                sourceStatus:
                    _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
              );
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('add-expense-date-field'),
          controller: dateController,
          textAlignVertical: TextAlignVertical.center,
          readOnly: true,
          onTap: () async {
            final newDate = await showDatePicker(
              context: context,
              initialDate: expense.date,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (newDate != null) {
              setState(() {
                dateController.text = _formatDate(newDate);
                expense.date = newDate;
                _syncDraft(
                  sourceStatus:
                      _currentDraft?.sourceStatus ?? DraftSourceStatus.manual,
                );
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              FontAwesomeIcons.clock,
              size: 16,
              color: Colors.grey,
            ),
            hintText: context.l10n.date,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: kToolbarHeight,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TextButton(
              onPressed: () {
                _saveExpense();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.save,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateExpenseBloc, CreateExpenseState>(
          listener: (context, state) {
            if (state is CreateExpenseSuccess) {
              Navigator.pop(context, expense);
            } else if (state is CreateExpenseLoading) {
              setState(() {
                isLoading = true;
              });
            } else if (state is CreateExpenseFailure) {
              setState(() {
                isLoading = false;
              });
              _showError(context.l10n.failedToSaveExpense);
            }
          },
        ),
        BlocListener<CreateCategoryBloc, CreateCategoryState>(
          listener: (context, state) {
            if (state is CreateCategorySucess) {
              final createdCategory = _pendingCategory;
              if (createdCategory != null) {
                setState(() {
                  expense.category = createdCategory;
                  categoryController.text = createdCategory.name;
                  _pendingCategory = null;
                });
              }
              context.read<GetCategoriesBloc>().add(GetCategories());
            } else if (state is CreateCategoryFailure) {
              _pendingCategory = null;
              _showError(context.l10n.failedToSaveCategory);
            }
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                final activeCategories = state.categories
                    .where((category) => !category.isArchived)
                    .toList();
                final mediaQuery = MediaQuery.of(context);
                final bottomPadding = 16.0 +
                    mediaQuery.viewPadding.bottom +
                    mediaQuery.viewInsets.bottom;
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.addExpense,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildModeSelector(),
                      const SizedBox(height: 12),
                      if (_currentDraft?.statusMessage != null) ...[
                        _buildDraftStatus(),
                        const SizedBox(height: 12),
                      ],
                      if (_captureMode == CaptureMode.naturalLanguage) ...[
                        AiExpenseFormFillCard(
                          categories: activeCategories,
                          currencies: currencies,
                          defaultCurrency: _selectedCurrency,
                          defaultPaymentMethod: _selectedPaymentMethod,
                          settingsReady: !_settingsLoadFailed &&
                              _selectedCurrency != null &&
                              _selectedPaymentMethod != null,
                          onSettingsRetry: _loadSettingsDefaults,
                          onPreviewReady: _applyAiPreviewToForm,
                        ),
                        const SizedBox(height: 16),
                      ] else if (_captureMode == CaptureMode.receipt) ...[
                        _ReceiptCapturePanel(
                          settingsReady: !_settingsLoadFailed &&
                              _selectedCurrency != null &&
                              _selectedPaymentMethod != null,
                          service: _receiptService(),
                          aiContext: _aiContext(activeCategories),
                          onSettingsRetry: _loadSettingsDefaults,
                          onExtracted: (result) =>
                              _applyReceiptResultToForm(result, activeCategories),
                          onUnavailable: (status) {
                            setState(() {
                              _syncDraft(
                                sourceStatus: DraftSourceStatus.receipt,
                                statusMessage: status.message ??
                                    context
                                        .l10n.providerAiUnavailableManualStillWorks,
                                missingFields: [status.message ?? 'receipt'],
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildCategoryField(activeCategories),
                      const SizedBox(height: 8),
                      _buildCategoryScroller(activeCategories),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            _showAdvancedFields = !_showAdvancedFields;
                          }),
                          icon: Icon(
                            _showAdvancedFields
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          label: Text(
                            _showAdvancedFields
                                ? context.l10n.quickCaptureLessDetails
                                : context.l10n.quickCaptureMoreDetails,
                          ),
                        ),
                      ),
                      if (_showAdvancedFields) ...[
                        const SizedBox(height: 8),
                        _buildAdvancedFields(),
                      ],
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                );
              } else if (state is GetCategoriesFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.failedToLoadCategories,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context
                                .read<GetCategoriesBloc>()
                                .add(GetCategories());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ReceiptCapturePanel extends StatelessWidget {
  const _ReceiptCapturePanel({
    required this.settingsReady,
    required this.service,
    required this.aiContext,
    required this.onSettingsRetry,
    required this.onExtracted,
    required this.onUnavailable,
  });

  final bool settingsReady;
  final ReceiptAiService? service;
  final AiContext aiContext;
  final VoidCallback onSettingsRetry;
  final ValueChanged<ReceiptAiResult> onExtracted;
  final ValueChanged<AiUsageStatus> onUnavailable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final receiptService = service;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.quickCaptureReceiptTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.quickCaptureReceiptHelper,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            if (!settingsReady) ...[
              SettingsLoadGuardCard(
                message: context.l10n.settingsLoadRequiredForAi,
                onRetry: onSettingsRetry,
              ),
            ] else if (receiptService == null) ...[
              Text(
                context.l10n.providerAiUnavailableManualStillWorks,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              ReceiptCaptureButton(
                service: receiptService,
                aiContext: aiContext,
                onExtracted: onExtracted,
                onUnavailable: onUnavailable,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
