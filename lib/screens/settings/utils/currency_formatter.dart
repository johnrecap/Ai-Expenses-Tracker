import 'package:intl/intl.dart';

String formatAmountWithCurrency(num amount, String currencyCode) {
  final normalizedCurrency = currencyCode.trim().toUpperCase();
  final formatter = NumberFormat.decimalPattern()
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 2;

  return '${formatter.format(amount.toDouble())} $normalizedCurrency';
}
