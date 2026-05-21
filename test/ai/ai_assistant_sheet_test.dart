import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/ai_assistant/utils/ai_defaults_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasRequiredAiDefaults', () {
    test('does not allow AI requests when settings are not ready', () {
      final allowed = hasRequiredAiDefaults(
        settingsReady: false,
        defaultCurrency: 'EGP',
        defaultPaymentMethod: PaymentMethod.cash,
      );

      expect(allowed, isFalse);
    });

    test('does not allow AI requests with missing currency or payment method',
        () {
      expect(
        hasRequiredAiDefaults(
          settingsReady: true,
          defaultCurrency: '',
          defaultPaymentMethod: PaymentMethod.wallet,
        ),
        isFalse,
      );
      expect(
        hasRequiredAiDefaults(
          settingsReady: true,
          defaultCurrency: 'USD',
          defaultPaymentMethod: null,
        ),
        isFalse,
      );
    });

    test('allows AI requests only after settings provide required defaults',
        () {
      final allowed = hasRequiredAiDefaults(
        settingsReady: true,
        defaultCurrency: 'USD',
        defaultPaymentMethod: PaymentMethod.bankTransfer,
      );

      expect(allowed, isTrue);
    });
  });
}
