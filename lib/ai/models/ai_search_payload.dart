import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/utils/amount_parser.dart';

class AiSearchPayload {
  final String query;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categoryNames;
  final List<String> categoryIds;
  final num? minAmount;
  final num? maxAmount;
  final List<PaymentMethod> paymentMethods;
  final String? currency;
  final String? periodText;

  const AiSearchPayload({
    this.query = '',
    this.startDate,
    this.endDate,
    this.categoryNames = const [],
    this.categoryIds = const [],
    this.minAmount,
    this.maxAmount,
    this.paymentMethods = const [],
    this.currency,
    this.periodText,
  });

  factory AiSearchPayload.fromJson(Map<String, dynamic> json) {
    return AiSearchPayload(
      query: json['query'] as String? ?? '',
      startDate: _dateFromJson(json['startDate']),
      endDate: _dateFromJson(json['endDate']),
      categoryNames: _stringList(json['categoryNames']),
      categoryIds: _stringList(json['categoryIds']),
      minAmount: _doubleFromJson(json['minAmount']),
      maxAmount: _doubleFromJson(json['maxAmount']),
      paymentMethods: _paymentMethodsFromJson(json['paymentMethods']),
      currency: json['currency'] as String?,
      periodText: json['periodText'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'query': query,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'categoryNames': categoryNames,
      'categoryIds': categoryIds,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'paymentMethods':
          paymentMethods.map((method) => method.storageValue).toList(),
      'currency': currency,
      'periodText': periodText,
    };
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _doubleFromJson(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return parseAmountInput(value);
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<PaymentMethod> _paymentMethodsFromJson(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => PaymentMethod.fromStorageValue(
              item.toString().trim().toLowerCase().replaceAll(' ', '_'),
            ))
        .toList();
  }
}
