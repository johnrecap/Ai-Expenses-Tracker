import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RecurringExpenseForm extends StatefulWidget {
  final List<Category> categories;
  final RecurringExpense? initialRule;
  final List<String> currencies;

  const RecurringExpenseForm({
    super.key,
    required this.categories,
    this.initialRule,
    this.currencies = const ['EGP', 'USD'],
  });

  @override
  State<RecurringExpenseForm> createState() => _RecurringExpenseFormState();
}

class _RecurringExpenseFormState extends State<RecurringExpenseForm> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  Category? _selectedCategory;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  String _currency = 'EGP';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _error;

  bool get _isEditMode => widget.initialRule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    if (rule != null) {
      _amountController.text = formatAmountInput(rule.amount);
      _descriptionController.text = rule.description;
      for (final category in widget.categories) {
        if (category.categoryId == rule.categoryId) {
          _selectedCategory = category;
          break;
        }
      }
      _paymentMethod = rule.paymentMethod;
      _frequency = rule.frequency;
      if (widget.currencies.isEmpty ||
          widget.currencies.contains(rule.currency)) {
        _currency = rule.currency;
      } else {
        _currency = widget.currencies.first;
      }
      _startDate = rule.startDate;
      _endDate = rule.endDate;
    } else if (widget.currencies.isNotEmpty) {
      _currency = widget.currencies.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selectedDate == null) return;
    setState(() {
      _startDate = selectedDate;
      if (_endDate != null && _endDate!.isBefore(_startDate)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selectedDate == null) return;
    setState(() {
      _endDate = selectedDate;
    });
  }

  void _submit() {
    final amount = parseAmountInput(_amountController.text);
    final category = _selectedCategory;

    if (amount == null || amount <= 0 || category == null) {
      setState(() {
        _error = context.l10n.enterRecurringAmountAndCategory;
      });
      return;
    }

    final now = DateTime.now();
    final initialRule = widget.initialRule;
    final rule = RecurringExpense(
      recurringExpenseId: initialRule?.recurringExpenseId ?? const Uuid().v1(),
      userId: initialRule?.userId,
      amount: amount,
      category: category,
      description: _descriptionController.text.trim(),
      paymentMethod: _paymentMethod,
      currency: _currency.trim().toUpperCase(),
      startDate: _startDate,
      nextRunDate: initialRule?.nextRunDate ?? _startDate,
      endDate: _endDate,
      frequency: _frequency,
      isActive: initialRule?.isActive ?? true,
      isArchived: initialRule?.isArchived ?? false,
      createdAt: initialRule?.createdAt ?? now,
      updatedAt: now,
    );
    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    final currencyOptions =
        widget.currencies.isEmpty ? <String>[_currency] : widget.currencies;
    return AlertDialog(
      title: Text(
        _isEditMode
            ? context.l10n.editRecurringExpense
            : context.l10n.newRecurring,
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.amount,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  border: const OutlineInputBorder(),
                ),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(
                  labelText: context.l10n.frequency,
                  border: const OutlineInputBorder(),
                ),
                items: RecurringFrequency.values
                    .map(
                      (frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(
                          localizedRecurringFrequency(context.l10n, frequency),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (frequency) {
                  if (frequency == null) return;
                  setState(() {
                    _frequency = frequency;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: context.l10n.paymentMethod,
                  border: const OutlineInputBorder(),
                ),
                items: PaymentMethod.values
                    .map(
                      (paymentMethod) => DropdownMenuItem(
                        value: paymentMethod,
                        child: Text(
                          localizedPaymentMethod(context.l10n, paymentMethod),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (paymentMethod) {
                  if (paymentMethod == null) return;
                  setState(() {
                    _paymentMethod = paymentMethod;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: InputDecoration(
                  labelText: context.l10n.currency,
                  border: const OutlineInputBorder(),
                ),
                items: currencyOptions
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
                    _currency = currency;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.startDate),
                subtitle: Text(_dateFormat.format(_startDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickStartDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.endDate),
                subtitle: Text(
                  _endDate == null
                      ? context.l10n.noEndDate
                      : _dateFormat.format(_endDate!),
                ),
                trailing: Wrap(
                  children: [
                    if (_endDate != null)
                      IconButton(
                        tooltip: context.l10n.clearEndDate,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _endDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
                onTap: _pickEndDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
