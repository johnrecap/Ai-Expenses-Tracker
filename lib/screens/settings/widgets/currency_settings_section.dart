import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/blocs/settings_bloc/settings_cubit.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencySettingsSection extends StatefulWidget {
  const CurrencySettingsSection({
    required this.settings,
    required this.isSaving,
    this.availableCurrencies = UserSettings.defaultSupportedCurrencies,
    super.key,
  });

  final UserSettings settings;
  final bool isSaving;
  final List<String> availableCurrencies;

  @override
  State<CurrencySettingsSection> createState() =>
      _CurrencySettingsSectionState();
}

class _CurrencySettingsSectionState extends State<CurrencySettingsSection> {
  final Map<String, TextEditingController> _rateControllers = {};

  @override
  void didUpdateWidget(covariant CurrencySettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _syncRateControllers();
    }
  }

  @override
  void dispose() {
    for (final controller in _rateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supported = {
      ...widget.settings.supportedCurrencies
          .map((currency) => currency.trim().toUpperCase())
          .where((currency) => currency.isNotEmpty),
      widget.settings.baseCurrency.trim().toUpperCase(),
    };
    final options = {
      ...widget.availableCurrencies.map((currency) => currency.toUpperCase()),
      ...supported,
      widget.settings.baseCurrency.toUpperCase(),
    }.toList()..sort();
    final baseCurrency = widget.settings.baseCurrency.trim().toUpperCase();
    final rateCurrencies =
        supported.where((currency) => currency != baseCurrency).toList()
          ..sort();
    _ensureRateControllers(rateCurrencies);

    return SettingsSection(
      title: context.l10n.currency,
      subtitle: context.l10n.currencySettingsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('base-currency-${widget.settings.baseCurrency}'),
            initialValue: widget.settings.baseCurrency,
            decoration: InputDecoration(
              labelText: context.l10n.baseCurrency,
              border: const OutlineInputBorder(),
            ),
            items: options
                .map(
                  (currency) =>
                      DropdownMenuItem(value: currency, child: Text(currency)),
                )
                .toList(),
            onChanged: widget.isSaving
                ? null
                : (value) {
                    if (value == null) return;
                    context.read<SettingsCubit>().saveBaseCurrency(value);
                  },
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.supportedCurrencies,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final currency in options)
                FilterChip(
                  label: Text(currency),
                  selected: supported.contains(currency),
                  onSelected: widget.isSaving
                      ? null
                      : (selected) {
                          final next = {...supported};
                          if (selected) {
                            next.add(currency);
                          } else if (currency != widget.settings.baseCurrency) {
                            next.remove(currency);
                          }
                          context.read<SettingsCubit>().saveSupportedCurrencies(
                            next.toList(),
                          );
                        },
                ),
            ],
          ),
          if (rateCurrencies.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              context.l10n.exchangeRates,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${context.l10n.exchangeRatesDescription} $baseCurrency',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            for (final currency in rateCurrencies) ...[
              _ExchangeRateField(
                currency: currency,
                baseCurrency: baseCurrency,
                controller: _rateControllers[currency]!,
                isSaving: widget.isSaving,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  void _syncRateControllers() {
    for (final entry in _rateControllers.entries) {
      entry.value.text = _rateText(widget.settings.conversionRates[entry.key]);
    }
  }

  void _ensureRateControllers(List<String> currencies) {
    final currencySet = currencies.toSet();
    for (final currency in currencies) {
      _rateControllers.putIfAbsent(
        currency,
        () => TextEditingController(
          text: _rateText(widget.settings.conversionRates[currency]),
        ),
      );
    }
    final staleCurrencies = _rateControllers.keys
        .where((currency) => !currencySet.contains(currency))
        .toList();
    for (final currency in staleCurrencies) {
      _rateControllers.remove(currency)?.dispose();
    }
  }

  String _rateText(num? value) {
    if (value == null || value <= 0) return '';
    return value.toString();
  }
}

class _ExchangeRateField extends StatelessWidget {
  const _ExchangeRateField({
    required this.currency,
    required this.baseCurrency,
    required this.controller,
    required this.isSaving,
  });

  final String currency;
  final String baseCurrency;
  final TextEditingController controller;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey('conversion-rate-$currency'),
            controller: controller,
            enabled: !isSaving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.exchangeRateInputLabel(currency),
              suffixText: baseCurrency,
              border: const OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) {
              context.read<SettingsCubit>().saveConversionRate(currency, value);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: context.l10n.save,
          onPressed: isSaving
              ? null
              : () {
                  context.read<SettingsCubit>().saveConversionRate(
                    currency,
                    controller.text,
                  );
                },
          icon: const Icon(Icons.save_outlined),
        ),
      ],
    );
  }
}
