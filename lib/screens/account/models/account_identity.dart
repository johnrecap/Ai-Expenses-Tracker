import 'package:expense_repository/expense_repository.dart';

class AccountIdentity {
  const AccountIdentity._();

  static String displayName({
    required AppUser user,
    required String fallbackUserLabel,
    String? localDisplayName,
  }) {
    final localName = localDisplayName?.trim();
    if (localName != null && localName.isNotEmpty) return localName;

    final authName = user.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return fallbackUserLabel;
  }

  static String? secondaryIdentity({
    required AppUser user,
    String? localDisplayName,
  }) {
    final primary = displayName(
      user: user,
      localDisplayName: localDisplayName,
      fallbackUserLabel: '',
    ).trim();
    final email = user.email?.trim();
    if (email == null || email.isEmpty || email == primary) return null;
    return email;
  }

  static String initials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
