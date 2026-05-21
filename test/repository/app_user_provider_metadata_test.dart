import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives password account capabilities from provider metadata', () {
    final user = AppUser(
      userId: 'user-1',
      email: 'person@example.com',
      displayName: 'Auth Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 19),
      providers: const [
        AuthProviderMetadata(
          providerId: 'password',
          email: 'person@example.com',
        ),
      ],
    );

    expect(user.providerIds, ['password']);
    expect(user.hasPasswordProvider, isTrue);
    expect(user.hasGoogleProvider, isFalse);
    expect(user.accountCapabilities.canRequestPasswordReset, isTrue);
    expect(user.accountCapabilities.canUpdateEmail, isTrue);
    expect(user.accountCapabilities.canReauthenticateWithPassword, isTrue);
    expect(user.accountCapabilities.canDeleteAccount, isTrue);
  });

  test('derives Google account capabilities without password actions', () {
    final user = AppUser(
      userId: 'google-1',
      email: 'person@example.com',
      displayName: 'Google Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 19),
      providers: const [
        AuthProviderMetadata(
          providerId: 'google.com',
          email: 'person@example.com',
          displayName: 'Google Name',
        ),
      ],
    );

    expect(user.providerIds, ['google.com']);
    expect(user.hasPasswordProvider, isFalse);
    expect(user.hasGoogleProvider, isTrue);
    expect(user.accountCapabilities.canRequestPasswordReset, isFalse);
    expect(user.accountCapabilities.canUpdateEmail, isFalse);
    expect(user.accountCapabilities.canReauthenticateWithPassword, isFalse);
    expect(user.accountCapabilities.canDeleteAccount, isTrue);
  });
}
