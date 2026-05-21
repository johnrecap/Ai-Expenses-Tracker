import 'package:expenses_tracker/utils/amount_parser.dart';

class AiReceiptPayload {
  const AiReceiptPayload({
    this.amount,
    this.date,
    this.merchant,
    this.categoryId,
    this.categoryName,
    this.currency,
    this.description,
    this.rawText,
    required this.confidence,
  });

  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String? categoryId;
  final String? categoryName;
  final String? currency;
  final String? description;
  final String? rawText;
  final double confidence;

  bool get hasLowConfidence => confidence < 0.75;

  List<String> missingFields() {
    return [
      if (amount == null || amount! <= 0) 'amount',
      if (date == null) 'date',
      if ((categoryId?.trim().isEmpty ?? true) &&
          (categoryName?.trim().isEmpty ?? true))
        'category',
    ];
  }

  factory AiReceiptPayload.fromJson(Map<String, dynamic> json) {
    return AiReceiptPayload(
      amount: _readAmount(json['amount']),
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      merchant: _readString(json['merchant']),
      categoryId: _readString(json['categoryId']),
      categoryName: _readString(json['category']),
      currency: _readString(json['currency'])?.toUpperCase(),
      description: _readString(json['description']),
      rawText: _readString(json['rawText']),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _readAmount(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return parseAmountInput(value.replaceAll(RegExp(r'[^0-9.,-]'), ''));
    }
    return null;
  }
}
