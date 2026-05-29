import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/expenses/models/expense_edit_draft.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/finance/money_snapshot_service.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

Future<Expense?> showExpenseEditSheet({
  required BuildContext context,
  required Expense expense,
  required List<Category> categories,
}) {
  return showModalBottomSheet<Expense>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ExpenseEditSheet(expense: expense, categories: categories),
  );
}

class _ExpenseEditSheet extends StatefulWidget {
  const _ExpenseEditSheet({required this.expense, required this.categories});

  final Expense expense;
  final List<Category> categories;

  @override
  State<_ExpenseEditSheet> createState() => _ExpenseEditSheetState();
}

class _ExpenseEditSheetState extends State<_ExpenseEditSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _merchantController;
  late final TextEditingController _tagsController;
  late final TextEditingController _dateController;
  late final TextEditingController _adjustmentController;
  late final List<Category> _categories;
  late final List<String> _currencies;
  late Category _selectedCategory;
  late DateTime _selectedDate;
  late PaymentMethod _selectedPaymentMethod;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategory(widget.expense);
    _categories = _dedupeCategories([_selectedCategory, ...widget.categories]);
    _currencies = _dedupeCurrencies([
      widget.expense.currency,
      ...UserSettings.defaultSupportedCurrencies,
    ]);
    _selectedDate = widget.expense.date;
    _selectedPaymentMethod = widget.expense.paymentMethod;
    _selectedCurrency = widget.expense.currency;
    _amountController = TextEditingController(
      text: formatAmountInput(widget.expense.amount),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _merchantController = TextEditingController(
      text: widget.expense.merchant ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.expense.tags.join(', '),
    );
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedDate),
    );
    _adjustmentController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _tagsController.dispose();
    _dateController.dispose();
    _adjustmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.editExpense,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.amount,
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.dollarSign,
                            size: 16,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _QuickAdjustmentPanel(
                        controller: _adjustmentController,
                        onAdd: () => _applyAdjustment(isAddition: true),
                        onSubtract: () => _applyAdjustment(isAddition: false),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: context.l10n.description,
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.noteSticky,
                            size: 16,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _merchantController,
                        decoration: InputDecoration(
                          labelText: context.l10n.merchant,
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.store,
                            size: 16,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: context.l10n.tags,
                          helperText: context.l10n.tagsHelper,
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.tags,
                            size: 16,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory.categoryId,
                        decoration: InputDecoration(
                          labelText: context.l10n.category,
                          border: const OutlineInputBorder(),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.categoryId,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CategoryIconView(
                                      iconKey: category.icon,
                                      backgroundColor: Color(category.color),
                                      size: 28,
                                      iconSize: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        category.name,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (categoryId) {
                          if (categoryId == null) return;
                          setState(() {
                            _selectedCategory = _categories.firstWhere(
                              (category) => category.categoryId == categoryId,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PaymentMethod>(
                        initialValue: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: context.l10n.paymentMethod,
                          border: const OutlineInputBorder(),
                        ),
                        items: PaymentMethod.values
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(
                                  localizedPaymentMethod(context.l10n, method),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (method) {
                          if (method == null) return;
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: InputDecoration(
                          labelText: context.l10n.currency,
                          border: const OutlineInputBorder(),
                        ),
                        items: _currencies
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
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: context.l10n.date,
                          prefixIcon: const FaIcon(
                            FontAwesomeIcons.clock,
                            size: 16,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: Text(context.l10n.save)),
            ],
          ),
        ),
      ),
    );
  }

  void _applyAdjustment({required bool isAddition}) {
    final adjustment = parseAmountInput(_adjustmentController.text);
    final current = parseAmountInput(_amountController.text);
    if (adjustment == null ||
        adjustment <= 0 ||
        current == null ||
        current <= 0) {
      _showError(context.l10n.invalidExpenseAdjustment);
      return;
    }

    final next = isAddition ? current + adjustment : current - adjustment;
    if (next <= 0) {
      _showError(context.l10n.invalidExpenseAdjustment);
      return;
    }

    setState(() {
      _amountController.text = formatAmountInput(next);
      _adjustmentController.clear();
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedDate = selected;
      _dateController.text = _formatDate(selected);
    });
  }

  Future<void> _save() async {
    final draft = _buildDraft();
    final errors =
        draft?.validate() ?? [ExpenseEditValidationError.invalidAmount];
    if (errors.isNotEmpty) {
      _showValidationError(errors.first);
      return;
    }

    final updated = draft!.toExpense(widget.expense);

    UserSettings settings;
    try {
      settings = await context.read<SettingsRepository>().getSettings();
    } catch (_) {
      if (!mounted) return;
      _showError(context.l10n.settingsUnavailableMessage);
      return;
    }
    final withSnapshot = const MoneySnapshotService().preserveOrRefreshForEdit(
      previous: widget.expense,
      next: updated,
      settings: settings,
    );
    if (draft.moneyInputsChanged(widget.expense) &&
        withSnapshot.moneySnapshot == null) {
      if (!mounted) return;
      _showError(context.l10n.unconvertedCurrenciesStatus(1, updated.currency));
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, withSnapshot);
  }

  ExpenseEditDraft? _buildDraft() {
    final amount = parseAmountInput(_amountController.text);
    if (amount == null) return null;
    return ExpenseEditDraft(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text,
      merchant: _merchantController.text.trim(),
      tags: _parseTags(_tagsController.text),
      paymentMethod: _selectedPaymentMethod,
      currency: _selectedCurrency,
    );
  }

  void _showValidationError(ExpenseEditValidationError error) {
    switch (error) {
      case ExpenseEditValidationError.invalidAmount:
        _showError(context.l10n.enterValidExpenseAmount);
        break;
      case ExpenseEditValidationError.missingCategory:
        _showError(context.l10n.selectCategoryBeforeSaving);
        break;
      case ExpenseEditValidationError.missingCurrency:
        _showError(context.l10n.chooseCurrencyAndPaymentBeforeSaving);
        break;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd/MM/yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }
}

Category _expenseCategory(Expense expense) {
  return Category(
    categoryId: expense.categoryId.isNotEmpty
        ? expense.categoryId
        : expense.category.categoryId,
    name: expense.categoryName.isNotEmpty
        ? expense.categoryName
        : expense.category.name,
    totalExpenses: expense.category.totalExpenses,
    icon: expense.categoryIcon.isNotEmpty
        ? expense.categoryIcon
        : expense.category.icon,
    color: expense.categoryColor != 0
        ? expense.categoryColor
        : expense.category.color,
  );
}

List<Category> _dedupeCategories(List<Category> categories) {
  final byId = <String, Category>{};
  for (final category in categories) {
    if (category.categoryId.isEmpty) continue;
    byId.putIfAbsent(category.categoryId, () => category);
  }
  return byId.values.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

List<String> _dedupeCurrencies(List<String> currencies) {
  final values = <String>{};
  for (final currency in currencies) {
    final normalized = currency.trim().toUpperCase();
    if (normalized.isNotEmpty) values.add(normalized);
  }
  return values.toList()..sort();
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

class _QuickAdjustmentPanel extends StatelessWidget {
  const _QuickAdjustmentPanel({
    required this.controller,
    required this.onAdd,
    required this.onSubtract,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.quickAmountAdjustment,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.adjustmentAmount,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSubtract,
                    icon: const Icon(Icons.remove),
                    label: Text(context.l10n.subtractFromAmount),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.addToAmount),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String expenseDeleteContext(BuildContext context, Expense expense) {
  final categoryName = expense.categoryName.isNotEmpty
      ? expense.categoryName
      : expense.category.name;
  final date = DateFormat(
    'dd/MM/yyyy',
    Localizations.localeOf(context).toLanguageTag(),
  ).format(expense.date);
  final amount = formatAmountWithCurrency(expense.amount, expense.currency);
  return context.l10n.deleteExpenseMessage(categoryName, amount, date);
}
