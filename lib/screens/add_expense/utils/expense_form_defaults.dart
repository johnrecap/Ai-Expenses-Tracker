import 'package:expense_repository/expense_repository.dart';

class ExpenseFormDefaults {
  const ExpenseFormDefaults({
    required this.currencies,
    required this.currency,
    required this.paymentMethod,
  });

  final List<String> currencies;
  final String? currency;
  final PaymentMethod? paymentMethod;

  bool get canSaveWithDefaults =>
      currency != null && currency!.trim().isNotEmpty && paymentMethod != null;

  static ExpenseFormDefaults fromSettings(
    UserSettings settings, {
    List<String> fallbackCurrencies = UserSettings.defaultSupportedCurrencies,
  }) {
    return ExpenseFormDefaults(
      currencies: _normalizedCurrencies(settings, fallbackCurrencies),
      currency: settings.baseCurrency,
      paymentMethod: settings.defaultPaymentMethod,
    );
  }

  static ExpenseFormDefaults unavailable({
    List<String> fallbackCurrencies = UserSettings.defaultSupportedCurrencies,
  }) {
    return ExpenseFormDefaults(
      currencies: _normalizedFallbackCurrencies(fallbackCurrencies),
      currency: null,
      paymentMethod: null,
    );
  }

  static List<String> _normalizedCurrencies(
    UserSettings settings,
    List<String> fallbackCurrencies,
  ) {
    return _normalizedFallbackCurrencies([
      if (settings.supportedCurrencies.isEmpty)
        ...fallbackCurrencies
      else
        ...settings.supportedCurrencies,
      settings.baseCurrency,
    ]);
  }

  static List<String> _normalizedFallbackCurrencies(List<String> currencies) {
    final values = <String>[];
    for (final code in currencies) {
      final currency = code.trim().toUpperCase();
      if (currency.isEmpty || values.contains(currency)) continue;
      values.add(currency);
    }
    return values;
  }
}
