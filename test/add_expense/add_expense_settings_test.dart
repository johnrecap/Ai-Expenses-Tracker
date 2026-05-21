import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/utils/expense_form_defaults.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseFormDefaults', () {
    test(
        'uses settings base currency and payment method independently of language',
        () {
      final settings = UserSettings.defaults(userId: 'user-1').copyWith(
        languagePreference: LanguagePreference.arabic,
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
        defaultPaymentMethod: PaymentMethod.wallet,
      );

      final defaults = ExpenseFormDefaults.fromSettings(settings);

      expect(defaults.currency, 'USD');
      expect(defaults.paymentMethod, PaymentMethod.wallet);
      expect(defaults.currencies, ['USD', 'EGP']);
      expect(defaults.canSaveWithDefaults, isTrue);
    });

    test('blocks default-backed saves when settings are unavailable', () {
      final defaults = ExpenseFormDefaults.unavailable(
        fallbackCurrencies: const ['egp', 'USD', ''],
      );

      expect(defaults.currency, isNull);
      expect(defaults.paymentMethod, isNull);
      expect(defaults.currencies, ['EGP', 'USD']);
      expect(defaults.canSaveWithDefaults, isFalse);
    });
  });
}
