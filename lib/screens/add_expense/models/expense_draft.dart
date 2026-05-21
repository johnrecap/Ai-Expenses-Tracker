import 'package:expense_repository/expense_repository.dart';

enum CaptureMode {
  quickManual,
  naturalLanguage,
  receipt,
}

enum DraftSourceStatus {
  manual,
  aiText,
  receipt,
}

class ExpenseDraft {
  const ExpenseDraft({
    required this.amountText,
    required this.category,
    required this.date,
    required this.currency,
    required this.paymentMethod,
    required this.description,
    required this.merchant,
    required this.tags,
    required this.sourceStatus,
    this.statusMessage,
    this.missingFields = const [],
  });

  final String amountText;
  final Category? category;
  final DateTime date;
  final String? currency;
  final PaymentMethod? paymentMethod;
  final String description;
  final String merchant;
  final List<String> tags;
  final DraftSourceStatus sourceStatus;
  final String? statusMessage;
  final List<String> missingFields;

  bool get needsReview => missingFields.isNotEmpty;
}
