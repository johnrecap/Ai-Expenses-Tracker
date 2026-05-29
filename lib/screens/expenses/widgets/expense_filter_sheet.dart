import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter/material.dart';

class ExpenseFilterSheet extends StatefulWidget {
  final ExpenseFilter initialFilter;
  final List<Category> categories;

  const ExpenseFilterSheet({
    super.key,
    required this.initialFilter,
    required this.categories,
  });

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  late ExpenseFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _minAmountController.text = _filter.minAmount == null
        ? ''
        : formatAmountInput(_filter.minAmount!);
    _maxAmountController.text = _filter.maxAmount == null
        ? ''
        : formatAmountInput(_filter.maxAmount!);
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.filters,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ExpenseFilter.empty),
                  child: Text(context.l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DateRangeTile(
              startDate: _filter.startDate,
              endDate: _filter.endDate,
              onPick: _pickDateRange,
              onClear: () {
                setState(() {
                  _filter = ExpenseFilter(
                    query: _filter.query,
                    categoryIds: _filter.categoryIds,
                    minAmount: _filter.minAmount,
                    maxAmount: _filter.maxAmount,
                    paymentMethods: _filter.paymentMethods,
                    currency: _filter.currency,
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            _Section(
              title: context.l10n.categories,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories
                    .map(
                      (category) => FilterChip(
                        avatar: CategoryIconView(
                          iconKey: category.icon,
                          backgroundColor: Color(category.color),
                          size: 24,
                          iconSize: 14,
                        ),
                        label: Text(category.name),
                        selected: _filter.categoryIds.contains(
                          category.categoryId,
                        ),
                        onSelected: (_) => _toggleCategory(category.categoryId),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: context.l10n.amount,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.min,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.max,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: context.l10n.paymentMethod,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentMethod.values
                    .map(
                      (paymentMethod) => FilterChip(
                        label: Text(
                          localizedPaymentMethod(context.l10n, paymentMethod),
                        ),
                        selected: _filter.paymentMethods.contains(
                          paymentMethod,
                        ),
                        onSelected: (_) => _togglePayment(paymentMethod),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _filter.currency?.toUpperCase(),
              decoration: InputDecoration(
                labelText: context.l10n.currency,
                border: const OutlineInputBorder(),
              ),
              items: const ['EGP', 'USD', 'EUR', 'SAR', 'AED']
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(currency: value);
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(context.l10n.applyFilters),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _filter.startDate != null && _filter.endDate != null
          ? DateTimeRange(start: _filter.startDate!, end: _filter.endDate!)
          : null,
    );
    if (range == null) return;
    setState(() {
      _filter = _filter.copyWith(startDate: range.start, endDate: range.end);
    });
  }

  void _toggleCategory(String categoryId) {
    final categoryIds = List<String>.from(_filter.categoryIds);
    if (categoryIds.contains(categoryId)) {
      categoryIds.remove(categoryId);
    } else {
      categoryIds.add(categoryId);
    }
    setState(() {
      _filter = _filter.copyWith(categoryIds: categoryIds);
    });
  }

  void _togglePayment(PaymentMethod paymentMethod) {
    final paymentMethods = List<PaymentMethod>.from(_filter.paymentMethods);
    if (paymentMethods.contains(paymentMethod)) {
      paymentMethods.remove(paymentMethod);
    } else {
      paymentMethods.add(paymentMethod);
    }
    setState(() {
      _filter = _filter.copyWith(paymentMethods: paymentMethods);
    });
  }

  void _apply() {
    final minAmount = parseAmountInput(_minAmountController.text);
    final maxAmount = parseAmountInput(_maxAmountController.text);
    Navigator.pop(
      context,
      _filter.copyWith(minAmount: minAmount, maxAmount: maxAmount),
    );
  }
}

class _DateRangeTile extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DateRangeTile({
    required this.startDate,
    required this.endDate,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = startDate == null || endDate == null
        ? context.l10n.anyDate
        : '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.dateRange),
      subtitle: Text(label),
      trailing: Wrap(
        children: [
          if (startDate != null || endDate != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              tooltip: context.l10n.clearDates,
            ),
          IconButton(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_month),
            tooltip: context.l10n.pickDates,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
