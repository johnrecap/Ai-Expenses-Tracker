import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_action_preview.dart';
import 'package:expenses_tracker/ai/models/ai_category_resolution.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AiActionPreviewCard extends StatefulWidget {
  const AiActionPreviewCard({
    required this.preview,
    required this.categories,
    required this.currencies,
    required this.onChanged,
    required this.onConfirm,
    required this.isConfirming,
    super.key,
  });

  final AiActionPreview preview;
  final List<Category> categories;
  final List<String> currencies;
  final ValueChanged<AiActionPreview> onChanged;
  final VoidCallback onConfirm;
  final bool isConfirming;

  @override
  State<AiActionPreviewCard> createState() => _AiActionPreviewCardState();
}

class _AiActionPreviewCardState extends State<AiActionPreviewCard> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _merchantController;
  late final TextEditingController _tagsController;
  late final TextEditingController _categoryController;
  late DateTime _date;
  late PaymentMethod _paymentMethod;
  late String _currency;
  Category? _category;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: _amountText(widget.preview.amount));
    _descriptionController =
        TextEditingController(text: widget.preview.description);
    _merchantController =
        TextEditingController(text: widget.preview.merchant ?? '');
    _tagsController =
        TextEditingController(text: widget.preview.tags.join(', '));
    _categoryController =
        TextEditingController(text: widget.preview.categoryName);
    _date = widget.preview.date;
    _paymentMethod = widget.preview.paymentMethod;
    _currency = widget.preview.currency;
    _category = widget.preview.category;
  }

  @override
  void didUpdateWidget(covariant AiActionPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preview != widget.preview) {
      _amountController.text = _amountText(widget.preview.amount);
      _descriptionController.text = widget.preview.description;
      _merchantController.text = widget.preview.merchant ?? '';
      _tagsController.text = widget.preview.tags.join(', ');
      _categoryController.text = widget.preview.categoryName;
      _date = widget.preview.date;
      _paymentMethod = widget.preview.paymentMethod;
      _currency = widget.preview.currency;
      _category = widget.preview.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final amount = parseAmountInput(_amountController.text) ?? 0;
    final categoryName = _category?.name ?? _categoryController.text.trim();
    final categoryResolution = _category == null &&
            widget.preview.categoryResolution?.suggestedCategory != null
        ? widget.preview.categoryResolution!.copyWith(
            categoryName: categoryName,
            suggestedCategory: widget
                .preview.categoryResolution!.suggestedCategory!
                .copyWith(name: categoryName),
          )
        : widget.preview.categoryResolution;
    final preview = widget.preview.copyWith(
      amount: amount,
      category: _category,
      clearCategory: _category == null,
      categoryName: categoryName,
      categoryResolution: categoryResolution,
      date: _date,
      paymentMethod: _paymentMethod,
      currency: _currency,
      description: _descriptionController.text.trim(),
      merchant: _merchantController.text.trim(),
      clearMerchant: _merchantController.text.trim().isEmpty,
      tags: _parseTags(_tagsController.text),
    );
    widget.onChanged(preview.copyWith(validationErrors: preview.validate()));
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

  String _amountText(num amount) {
    return amount <= 0 ? '' : formatAmountInput(amount);
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.preview.validationErrors;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.reviewBeforeSaving,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${(widget.preview.confidence * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.preview.categoryResolution != null) ...[
              _CategoryResolutionNote(preview: widget.preview),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: context.l10n.amount),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: InputDecoration(labelText: context.l10n.category),
              items: widget.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
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
                          Text(category.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                setState(() {
                  _category = category;
                  _categoryController.text = category?.name ?? '';
                });
                _emitChange();
              },
            ),
            if (_category == null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: context.l10n.newCategoryName,
                  helperText: context.l10n.confirmingCreatesCategoryFirst,
                ),
                onChanged: (_) => _emitChange(),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected == null) return;
                setState(() {
                  _date = selected;
                });
                _emitChange();
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat('dd/MM/yyyy').format(_date)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: InputDecoration(
                labelText: context.l10n.paymentMethod,
              ),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(localizedPaymentMethod(context.l10n, method)),
                    ),
                  )
                  .toList(),
              onChanged: (method) {
                if (method == null) return;
                setState(() {
                  _paymentMethod = method;
                });
                _emitChange();
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: widget.currencies.contains(_currency)
                  ? _currency
                  : widget.currencies.first,
              decoration: InputDecoration(labelText: context.l10n.currency),
              items: widget.currencies
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
                _emitChange();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: context.l10n.description),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _merchantController,
              decoration: InputDecoration(labelText: context.l10n.merchant),
              onChanged: (_) => _emitChange(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: context.l10n.tags,
                helperText: context.l10n.tagsHelper,
              ),
              onChanged: (_) => _emitChange(),
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errors.join('\n'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.isConfirming || errors.isNotEmpty
                  ? null
                  : widget.onConfirm,
              icon: widget.isConfirming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(context.l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryResolutionNote extends StatelessWidget {
  const _CategoryResolutionNote({required this.preview});

  final AiActionPreview preview;

  @override
  Widget build(BuildContext context) {
    final resolution = preview.categoryResolution;
    if (resolution == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final isSuggestion = resolution.suggestedCategory != null &&
        !resolution.hasExistingCategory &&
        preview.category == null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSuggestion
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSuggestion
                  ? Icons.add_circle_outline
                  : Icons.check_circle_outline,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                [
                  isSuggestion
                      ? context.l10n.suggestedNewCategory(
                          preview.categoryName,
                        )
                      : context.l10n.matchedCategory(preview.categoryName),
                  context.l10n.sourceLabel(
                    _sourceLabel(context, resolution.source),
                  ),
                  resolution.reason,
                  context.l10n.confidenceLabel(
                    (resolution.confidence * 100).round(),
                  ),
                ].join('\n'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(BuildContext context, AiCategoryResolutionSource source) {
    switch (source) {
      case AiCategoryResolutionSource.exactId:
        return context.l10n.aiCategoryId;
      case AiCategoryResolutionSource.exactName:
        return context.l10n.aiCategoryName;
      case AiCategoryResolutionSource.alias:
        return context.l10n.categoryAlias;
      case AiCategoryResolutionSource.recentHistory:
        return context.l10n.recentHistory;
      case AiCategoryResolutionSource.aiSuggested:
        return context.l10n.newCategorySuggestion;
      case AiCategoryResolutionSource.manual:
        return context.l10n.manualSelection;
      case AiCategoryResolutionSource.none:
        return context.l10n.noMatch;
    }
  }
}
