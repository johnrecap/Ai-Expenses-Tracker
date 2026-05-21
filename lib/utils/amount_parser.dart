double? parseAmountInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final normalized = _normalizeDecimalText(trimmed);
  return double.tryParse(normalized);
}

String formatAmountInput(num amount) {
  final value = amount.toDouble();
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

String _normalizeDecimalText(String value) {
  if (!value.contains(',')) return value;
  if (value.contains('.')) return value.replaceAll(',', '');

  final parts = value.split(',');
  final looksLikeThousands = parts.length > 1 &&
      parts.last.length == 3 &&
      parts.every((part) => RegExp(r'^-?\d{1,3}$').hasMatch(part));
  return looksLikeThousands ? parts.join() : value.replaceAll(',', '.');
}
