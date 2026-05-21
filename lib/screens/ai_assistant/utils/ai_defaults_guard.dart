import 'package:expense_repository/expense_repository.dart';

bool hasRequiredAiDefaults({
  required bool settingsReady,
  required String? defaultCurrency,
  required PaymentMethod? defaultPaymentMethod,
}) {
  return settingsReady &&
      defaultCurrency != null &&
      defaultCurrency.trim().isNotEmpty &&
      defaultPaymentMethod != null;
}
