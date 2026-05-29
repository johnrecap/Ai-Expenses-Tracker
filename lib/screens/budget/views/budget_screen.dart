import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetScreen extends StatefulWidget {
  final Budget? initialBudget;
  final List<Expense> expenses;
  final UserSettings? settings;

  const BudgetScreen({
    super.key,
    this.initialBudget,
    this.expenses = const [],
    this.settings,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();
  final _thresholdController = TextEditingController(text: '80');
  late List<String> _currencies;
  late String _currency;
  BudgetRecommendation? _recommendation;

  @override
  void initState() {
    super.initState();
    final budget = widget.initialBudget;
    _amountController.text = budget == null || budget.amount == 0
        ? ''
        : budget.amount.toString();
    _thresholdController.text = (budget?.warningThresholdPercent ?? 80)
        .toString();
    _currency = budget?.currency ?? 'EGP';
    _currencies = _currencyChoices(widget.settings, _currency);
    final settings = widget.settings;
    if (settings != null) {
      _recommendation = const BudgetRecommendationService()
          .recommendMonthlyBudget(
            BudgetRecommendationInput(
              expenses: widget.expenses,
              settings: settings,
              existingMonthlyBudget: budget,
            ),
          );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    final threshold = int.tryParse(_thresholdController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage(context.l10n.enterValidBudgetAmount);
      return;
    }
    if (threshold == null || threshold < 1 || threshold > 100) {
      _showMessage(context.l10n.warningThresholdRange);
      return;
    }

    final now = DateTime.now();
    final currentBudget = widget.initialBudget;
    final budget = Budget(
      budgetId: Budget.budgetIdFor(month: now.month, year: now.year),
      userId: currentBudget?.userId ?? '',
      month: now.month,
      year: now.year,
      amount: amount,
      currency: _currency,
      warningThresholdPercent: threshold,
      createdAt: currentBudget?.createdAt ?? now,
      updatedAt: now,
    );

    context.read<BudgetBloc>().add(BudgetSaveRequested(budget));
  }

  void _applyRecommendation(BudgetRecommendation recommendation) {
    setState(() {
      _amountController.text = recommendation.suggestedAmount.toStringAsFixed(
        0,
      );
      _thresholdController.text = recommendation.warningThresholdPercent
          .toString();
      _currency = recommendation.currency;
      _currencies = _currencyChoices(widget.settings, _currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetFailure) {
          _showMessage(_localizedBudgetMessage(state.message));
        } else if (state is BudgetSaved) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text(context.l10n.monthlyBudgetTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_recommendation != null) ...[
              _BudgetRecommendationCard(
                recommendation: _recommendation!,
                onApply: _recommendation!.suggestedAmount > 0
                    ? () => _applyRecommendation(_recommendation!)
                    : null,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.budgetAmount,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
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
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _currency = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.warningThresholdPercent,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                final isSaving = state is BudgetSaving;
                return ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(context.l10n.saveBudget),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _localizedBudgetMessage(String message) {
    switch (message) {
      case 'Failed to load budget.':
        return context.l10n.failedToLoadBudget;
      case 'Enter a valid budget amount.':
        return context.l10n.enterValidBudgetAmount;
      case 'Warning threshold must be between 1 and 100.':
        return context.l10n.warningThresholdRange;
      case 'Failed to save budget.':
        return context.l10n.failedToSaveBudget;
      default:
        return message;
    }
  }
}

List<String> _currencyChoices(UserSettings? settings, String selected) {
  final values = <String>{
    'EGP',
    'USD',
    'EUR',
    'SAR',
    'AED',
    ...?settings?.supportedCurrencies.map((currency) {
      return currency.trim().toUpperCase();
    }),
    selected.trim().toUpperCase(),
  }..remove('');
  return values.toList(growable: false)..sort();
}

class _BudgetRecommendationCard extends StatelessWidget {
  const _BudgetRecommendationCard({
    required this.recommendation,
    required this.onApply,
  });

  final BudgetRecommendation recommendation;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final caveats = recommendation.caveats
        .map((caveat) => _localizedCaveat(context, caveat))
        .toList(growable: false);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.budgetRecommendationTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              formatAmountWithCurrency(
                recommendation.suggestedAmount,
                recommendation.currency,
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.budgetRecommendationMeta(
                _localizedConfidence(context, recommendation.confidence),
                recommendation.sourcePeriodLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.budgetRecommendationMonthlyExplanation),
            if (caveats.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...caveats.map(
                (caveat) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(caveat)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.useEditableRecommendation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedConfidence(
  BuildContext context,
  BudgetRecommendationConfidence confidence,
) {
  switch (confidence) {
    case BudgetRecommendationConfidence.high:
      return context.l10n.recommendationConfidenceHigh;
    case BudgetRecommendationConfidence.medium:
      return context.l10n.recommendationConfidenceMedium;
    case BudgetRecommendationConfidence.low:
      return context.l10n.recommendationConfidenceLow;
  }
}

String _localizedCaveat(
  BuildContext context,
  BudgetRecommendationCaveat caveat,
) {
  switch (caveat) {
    case BudgetRecommendationCaveat.sparseHistory:
      return context.l10n.recommendationCaveatSparseHistory;
    case BudgetRecommendationCaveat.outlierMonth:
      return context.l10n.recommendationCaveatOutlierMonth;
    case BudgetRecommendationCaveat.missingRates:
      return context.l10n.recommendationCaveatMissingRates;
    case BudgetRecommendationCaveat.existingBudget:
      return context.l10n.recommendationCaveatExistingBudget;
  }
}
