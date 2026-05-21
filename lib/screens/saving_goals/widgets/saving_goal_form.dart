import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SavingGoalForm extends StatefulWidget {
  final SavingGoal? initialGoal;
  final List<String> currencies;

  const SavingGoalForm({
    super.key,
    this.initialGoal,
    this.currencies = const ['EGP', 'USD'],
  });

  @override
  State<SavingGoalForm> createState() => _SavingGoalFormState();
}

class _SavingGoalFormState extends State<SavingGoalForm> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  String _currency = 'EGP';
  DateTime? _deadline;
  String? _error;

  bool get _isEditMode => widget.initialGoal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;
    if (goal != null) {
      _nameController.text = goal.name;
      _targetController.text = goal.targetAmount.toString();
      _currentController.text = goal.currentAmount.toString();
      _currency = widget.currencies.contains(goal.currency)
          ? goal.currency
          : widget.currencies.isNotEmpty
              ? widget.currencies.first
              : goal.currency;
      _deadline = goal.deadline;
    } else if (widget.currencies.isNotEmpty) {
      _currency = widget.currencies.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (selectedDate == null) return;
    setState(() {
      _deadline = selectedDate;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final targetAmount = double.tryParse(_targetController.text.trim());
    final currentAmountText = _currentController.text.trim();
    final currentAmount =
        currentAmountText.isEmpty ? 0.0 : double.tryParse(currentAmountText);

    if (name.isEmpty || targetAmount == null || targetAmount <= 0) {
      setState(() {
        _error = context.l10n.enterSavingGoalNameAndTarget;
      });
      return;
    }
    if (currentAmount == null || currentAmount < 0) {
      setState(() {
        _error = context.l10n.currentAmountCannotBeNegative;
      });
      return;
    }

    final now = DateTime.now();
    final initialGoal = widget.initialGoal;
    final goal = SavingGoal(
      goalId: initialGoal?.goalId ?? const Uuid().v1(),
      userId: initialGoal?.userId ?? '',
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      currency: _currency.trim().toUpperCase(),
      deadline: _deadline,
      isArchived: initialGoal?.isArchived ?? false,
      createdAt: initialGoal?.createdAt ?? now,
      updatedAt: now,
    );
    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    final currencyOptions =
        widget.currencies.isEmpty ? <String>[_currency] : widget.currencies;

    return AlertDialog(
      title: Text(
        _isEditMode ? context.l10n.editSavingGoal : context.l10n.newSavingGoal,
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
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.goalName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.targetAmount,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.currentAmount,
                  border: const OutlineInputBorder(),
                ),
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
                title: Text(context.l10n.deadline),
                subtitle: Text(
                  _deadline == null
                      ? context.l10n.noDeadline
                      : _dateFormat.format(_deadline!),
                ),
                trailing: Wrap(
                  children: [
                    if (_deadline != null)
                      IconButton(
                        tooltip: context.l10n.clearDeadline,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _deadline = null;
                          });
                        },
                      ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
                onTap: _pickDeadline,
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
