import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats EGP amount with currency code', () {
    expect(formatAmountWithCurrency(2500, 'EGP'), '2,500 EGP');
  });

  test('formats USD amount with normalized currency code', () {
    expect(formatAmountWithCurrency(99, 'usd'), '99 USD');
  });

  test('formats decimal amounts without floating point noise', () {
    expect(formatAmountWithCurrency(12.5, 'usd'), '12.5 USD');
    expect(formatAmountWithCurrency(12.499999999, 'usd'), '12.5 USD');
  });
}
