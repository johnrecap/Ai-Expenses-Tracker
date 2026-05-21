import 'payment_method.dart';

class ExpenseFilter {
  final String query;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categoryIds;
  final num? minAmount;
  final num? maxAmount;
  final List<PaymentMethod> paymentMethods;
  final String? currency;
  final String? walletAccountId;

  const ExpenseFilter({
    this.query = '',
    this.startDate,
    this.endDate,
    this.categoryIds = const [],
    this.minAmount,
    this.maxAmount,
    this.paymentMethods = const [],
    this.currency,
    this.walletAccountId,
  });

  static const empty = ExpenseFilter();

  bool get isEmpty =>
      query.trim().isEmpty &&
      startDate == null &&
      endDate == null &&
      categoryIds.isEmpty &&
      minAmount == null &&
      maxAmount == null &&
      paymentMethods.isEmpty &&
      (currency == null || currency!.trim().isEmpty) &&
      (walletAccountId == null || walletAccountId!.trim().isEmpty);

  ExpenseFilter copyWith({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    num? minAmount,
    num? maxAmount,
    List<PaymentMethod>? paymentMethods,
    String? currency,
    String? walletAccountId,
  }) {
    return ExpenseFilter(
      query: query ?? this.query,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      currency: currency ?? this.currency,
      walletAccountId: walletAccountId ?? this.walletAccountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExpenseFilter &&
            other.query == query &&
            other.startDate == startDate &&
            other.endDate == endDate &&
            _listEquals(other.categoryIds, categoryIds) &&
            other.minAmount == minAmount &&
            other.maxAmount == maxAmount &&
            _listEquals(other.paymentMethods, paymentMethods) &&
            other.currency == currency &&
            other.walletAccountId == walletAccountId;
  }

  @override
  int get hashCode => Object.hash(
        query,
        startDate,
        endDate,
        Object.hashAll(categoryIds),
        minAmount,
        maxAmount,
        Object.hashAll(paymentMethods),
        currency,
        walletAccountId,
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
