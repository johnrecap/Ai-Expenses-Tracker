import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/export/cubit/export_cubit.dart';
import 'package:expenses_tracker/services/export/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({
    required this.expenses,
    super.key,
  });

  final List<Expense> expenses;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  ExportFormat _format = ExportFormat.csv;
  final Set<String> _categoryIds = {};
  final Set<PaymentMethod> _paymentMethods = {};
  String? _currency;

  List<Category> get _categories {
    final categoriesById = <String, Category>{};
    for (final expense in widget.expenses) {
      final id = expense.categoryId.isNotEmpty
          ? expense.categoryId
          : expense.category.categoryId;
      if (id.isEmpty || categoriesById.containsKey(id)) continue;
      categoriesById[id] = Category(
        categoryId: id,
        name: expense.categoryName.isNotEmpty
            ? expense.categoryName
            : expense.category.name,
        totalExpenses: 0,
        icon: expense.categoryIcon,
        color: expense.categoryColor,
      );
    }
    return categoriesById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<String> get _currencies {
    final currencies = widget.expenses
        .map((expense) => expense.currency.trim().toUpperCase())
        .where((currency) => currency.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return currencies;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(
        exportService: const ExpenseExportService(),
      ),
      child: BlocListener<ExportCubit, ExportState>(
        listener: (context, state) {
          if (state is ExportFailure) {
            _showMessage(_localizedExportFailure(context, state.message));
          }
          if (state is ExportSuccess) {
            _showMessage(context.l10n.exportReady(state.result.fileName));
            _maybeShowExportInterstitial();
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(context.l10n.exportData),
              ),
              body: BlocBuilder<ExportCubit, ExportState>(
                builder: (context, state) {
                  final isLoading = state is ExportLoading;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _DateRangeSection(
                        startDate: _startDate,
                        endDate: _endDate,
                        onPick: _pickDateRange,
                      ),
                      const SizedBox(height: 16),
                      _FormatSection(
                        selected: _format,
                        onChanged: (format) {
                          setState(() => _format = format);
                        },
                      ),
                      const SizedBox(height: 16),
                      _CategorySection(
                        categories: _categories,
                        selectedIds: _categoryIds,
                        onToggle: _toggleCategory,
                      ),
                      const SizedBox(height: 16),
                      _PaymentSection(
                        selected: _paymentMethods,
                        onToggle: _togglePayment,
                      ),
                      if (_currencies.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: InputDecoration(
                            labelText: context.l10n.currency,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(context.l10n.allCurrencies),
                            ),
                            ..._currencies.map(
                              (currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _currency = value);
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: isLoading ? null : () => _export(context),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_download_outlined),
                        label: Text(context.l10n.export),
                      ),
                      if (state is ExportSuccess) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<ExportCubit>().share(state.result);
                          },
                          icon: const Icon(Icons.ios_share),
                          label: Text(context.l10n.shareFile),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.result.path ?? state.result.fileName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
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
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range == null) return;
    setState(() {
      _startDate = range.start;
      _endDate = range.end;
    });
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_categoryIds.contains(categoryId)) {
        _categoryIds.remove(categoryId);
      } else {
        _categoryIds.add(categoryId);
      }
    });
  }

  void _togglePayment(PaymentMethod method) {
    setState(() {
      if (_paymentMethods.contains(method)) {
        _paymentMethods.remove(method);
      } else {
        _paymentMethods.add(method);
      }
    });
  }

  Future<void> _export(BuildContext context) async {
    final startDate = _startDate;
    final endDate = _endDate;
    if (startDate == null || endDate == null) {
      _showMessage(context.l10n.selectDateRangeBeforeExporting);
      return;
    }

    UserSettings? settings;
    try {
      settings = await context.read<SettingsRepository>().getSettings();
    } catch (_) {
      settings = null;
    }
    if (!context.mounted) return;

    context.read<ExportCubit>().exportExpenses(
          expenses: widget.expenses,
          request: ExportRequest(
            startDate: startDate,
            endDate: endDate,
            format: _format,
            categoryIds: _categoryIds.toList(),
            paymentMethods: _paymentMethods.toList(),
            currency: _currency,
            settings: settings,
            labels: ExportLabels(
              pdfTitle: context.l10n.exportPdfTitle,
              pdfPeriod: context.l10n.exportPdfPeriod(
                '{startDate}',
                '{endDate}',
              ),
              pdfTotal: context.l10n.exportPdfTotal('{total}'),
              dateHeader: context.l10n.exportHeaderDate,
              amountHeader: context.l10n.exportHeaderAmount,
              currencyHeader: context.l10n.exportHeaderCurrency,
              categoryHeader: context.l10n.exportHeaderCategory,
              paymentMethodHeader: context.l10n.exportHeaderPaymentMethod,
              descriptionHeader: context.l10n.exportHeaderDescription,
              merchantHeader: context.l10n.merchant,
              tagsHeader: context.l10n.tags,
              convertedAmountHeader:
                  context.l10n.exportHeaderConvertedAmount,
              convertedCurrencyHeader:
                  context.l10n.exportHeaderConvertedCurrency,
              conversionRateHeader:
                  context.l10n.exportHeaderConversionRate,
              conversionRateDateHeader:
                  context.l10n.exportHeaderConversionRateDate,
              conversionStatusHeader:
                  context.l10n.exportHeaderConversionStatus,
              conversionStatusOriginal:
                  context.l10n.exportConversionStatusOriginal,
              conversionStatusConverted:
                  context.l10n.exportConversionStatusConverted,
              conversionStatusMissingRate:
                  context.l10n.exportConversionStatusMissingRate,
              pdfConvertedTotal:
                  context.l10n.exportPdfConvertedTotal('{total}'),
              pdfMissingRatesBuilder: ({
                required count,
                required currencies,
              }) =>
                  context.l10n.exportPdfMissingRates(currencies, count),
              arabicFontMissing: context.l10n.exportArabicFontMissing,
            ),
          ),
        );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _maybeShowExportInterstitial() async {
    try {
      await context.read<MonetizationCubit>().maybeShowInterstitial(
            AdPlacementKey.exportInterstitial,
            routeName: '/export/completed',
          );
    } catch (_) {
      // Export completion must stay independent from ad availability.
    }
  }
}

String _localizedExportFailure(BuildContext context, String message) {
  final l10n = context.l10n;
  switch (message) {
    case 'End date must be on or after start date.':
      return l10n.exportEndDateBeforeStart;
    case 'Currency filter must not be empty.':
      return l10n.exportCurrencyFilterEmpty;
    default:
      if (message.contains('End date must be on or after start date.')) {
        return l10n.exportEndDateBeforeStart;
      }
      if (message.contains('Currency filter must not be empty.')) {
        return l10n.exportCurrencyFilterEmpty;
      }
      return message;
  }
}

class _DateRangeSection extends StatelessWidget {
  const _DateRangeSection({
    required this.startDate,
    required this.endDate,
    required this.onPick,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final label = startDate == null || endDate == null
        ? context.l10n.required
        : '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.dateRange),
      subtitle: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_month),
        tooltip: context.l10n.pickRange,
        onPressed: onPick,
      ),
    );
  }
}

class _FormatSection extends StatelessWidget {
  const _FormatSection({
    required this.selected,
    required this.onChanged,
  });

  final ExportFormat selected;
  final ValueChanged<ExportFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ExportFormat>(
      segments: ExportFormat.values
          .map(
            (format) => ButtonSegment(
              value: format,
              label: Text(format.label),
              icon: Icon(_iconFor(format)),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }

  IconData _iconFor(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return Icons.table_rows_outlined;
      case ExportFormat.excel:
        return Icons.grid_on_outlined;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf_outlined;
    }
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Category> categories;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: context.l10n.categories,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories
            .map(
              (category) => FilterChip(
                label: Text(category.name),
                selected: selectedIds.contains(category.categoryId),
                onSelected: (_) => onToggle(category.categoryId),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.selected,
    required this.onToggle,
  });

  final Set<PaymentMethod> selected;
  final ValueChanged<PaymentMethod> onToggle;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: context.l10n.paymentMethod,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PaymentMethod.values
            .map(
              (method) => FilterChip(
                label: Text(localizedPaymentMethod(context.l10n, method)),
                selected: selected.contains(method),
                onSelected: (_) => onToggle(method),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
