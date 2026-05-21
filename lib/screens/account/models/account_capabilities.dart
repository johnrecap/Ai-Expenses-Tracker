import 'package:expenses_tracker/l10n/l10n.dart';

enum AccountProviderType {
  emailPassword,
  google,
  unknown,
}

class AccountProfileCapabilities {
  const AccountProfileCapabilities({
    required this.providerType,
    this.canEditLocalDisplayName = true,
    this.canSendPasswordReset = false,
    this.canUpdateEmail = false,
    this.canDeleteAccount = true,
    this.needsPasswordReauth = false,
  });

  final AccountProviderType providerType;
  final bool canEditLocalDisplayName;
  final bool canSendPasswordReset;
  final bool canUpdateEmail;
  final bool canDeleteAccount;
  final bool needsPasswordReauth;

  static const unknown = AccountProfileCapabilities(
    providerType: AccountProviderType.unknown,
  );

  String providerLabel(AppLocalizations l10n) {
    switch (providerType) {
      case AccountProviderType.emailPassword:
        return l10n.accountProviderEmailPassword;
      case AccountProviderType.google:
        return l10n.accountProviderGoogle;
      case AccountProviderType.unknown:
        return l10n.accountProviderUnknown;
    }
  }
}
