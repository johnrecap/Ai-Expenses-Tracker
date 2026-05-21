import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  test('fake auth repository records password reset outcomes', () async {
    final repository = FakeAuthRepository(AppUser.empty)
      ..passwordResetResult = const AuthActionResult.requiresRecentLogin(
        code: 'requires-recent-login',
      );

    final result =
        await repository.requestPasswordReset(' person@example.com ');

    expect(result.status, AuthActionStatus.requiresRecentLogin);
    expect(repository.passwordResetCalls, 1);
    expect(repository.lastPasswordResetEmail, 'person@example.com');
  });

  test('fake auth repository updates email on success', () async {
    final repository = FakeAuthRepository(
      AppUser(
        userId: 'user-1',
        email: 'old@example.com',
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5, 19),
        providers: const [AuthProviderMetadata(providerId: 'password')],
      ),
    );

    final result = await repository.updateEmail(' new@example.com ');

    expect(result.isSuccess, isTrue);
    expect(repository.emailUpdateCalls, 1);
    expect(repository.lastUpdatedEmail, 'new@example.com');
    expect(repository.currentUser?.email, 'new@example.com');
  });

  test('fake auth repository records reauth and delete outcomes', () async {
    final repository = FakeAuthRepository(
      AppUser(
        userId: 'user-1',
        email: 'person@example.com',
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5, 19),
      ),
    )..deleteCurrentUserResult = const AuthActionResult.networkError(
        code: 'network-request-failed',
      );

    final reauth = await repository.reauthenticateWithPassword(
      email: ' person@example.com ',
      password: 'secret',
    );
    final deleted = await repository.deleteCurrentUser();

    expect(reauth.isSuccess, isTrue);
    expect(repository.reauthenticateCalls, 1);
    expect(repository.lastReauthenticationEmail, 'person@example.com');
    expect(repository.lastReauthenticationPassword, 'secret');
    expect(deleted.status, AuthActionStatus.networkError);
    expect(repository.deleteCurrentUserCalls, 1);
    expect(repository.currentUser?.userId, 'user-1');
  });

  test('fake auth repository records Google reauth outcomes', () async {
    final repository = FakeAuthRepository(
      AppUser(
        userId: 'google-1',
        email: 'google@example.com',
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5, 19),
        providers: const [AuthProviderMetadata(providerId: 'google.com')],
      ),
    )..googleReauthenticateResult = const AuthActionResult.canceled(
        code: 'canceled',
      );

    final result = await repository.reauthenticateWithGoogle();

    expect(result.status, AuthActionStatus.canceled);
    expect(repository.googleReauthenticateCalls, 1);
  });
}
