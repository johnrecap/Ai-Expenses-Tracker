import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:expenses_tracker/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String localizedPaymentMethod(AppLocalizations l10n, PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return l10n.cash;
    case PaymentMethod.visa:
      return l10n.visa;
    case PaymentMethod.wallet:
      return l10n.wallet;
    case PaymentMethod.bankTransfer:
      return l10n.bankTransfer;
  }
}

String localizedRecurringFrequency(
  AppLocalizations l10n,
  RecurringFrequency frequency,
) {
  switch (frequency) {
    case RecurringFrequency.daily:
      return l10n.daily;
    case RecurringFrequency.weekly:
      return l10n.weekly;
    case RecurringFrequency.monthly:
      return l10n.monthly;
  }
}
