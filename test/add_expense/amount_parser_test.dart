import 'package:expenses_tracker/utils/amount_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses positive decimal amount input', () {
    expect(parseAmountInput('12.50'), 12.5);
    expect(parseAmountInput('12,50'), 12.5);
    expect(parseAmountInput('1,200.50'), 1200.5);
    expect(parseAmountInput('1,200'), 1200);
  });

  test('returns null for invalid amount text', () {
    expect(parseAmountInput('abc'), isNull);
    expect(parseAmountInput(''), isNull);
  });

  test('formats amount input without unnecessary trailing zeros', () {
    expect(formatAmountInput(12), '12');
    expect(formatAmountInput(12.50), '12.5');
  });
}
