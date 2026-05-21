import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final user = AppUser(
    userId: 'user-1',
    email: 'person@example.com',
    displayName: 'Google Name',
    photoUrl: null,
    createdAt: DateTime(2026, 5, 19),
  );

  test('saves app-local display name without changing auth display name',
      () async {
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.google,
      ),
    );
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.saveDisplayName('Local Name');

    expect(cubit.state.localDisplayName, 'Local Name');
    expect(user.displayName, 'Google Name');
    expect(service.savedDisplayNames, ['Local Name']);

    await cubit.close();
  });

  test('maps reauth-needed email update to safe UI state', () async {
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canUpdateEmail: true,
      ),
    )..emailUpdateError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.updateEmail('new@example.com');

    expect(cubit.state.status, AccountProfileStatus.ready);
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthRequired);

    await cubit.close();
  });

  test('requests user data deletion before auth account deletion', () async {
    final service = _FakeAccountProfileService();
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.deleteAccount(warningConfirmed: true);

    expect(service.deletionCalls, ['data:user-1', 'auth:user-1']);
    expect(cubit.state.status, AccountProfileStatus.deleted);
  });

  test('password reauth retries pending email update', () async {
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canUpdateEmail: true,
      ),
    )..emailUpdateError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.updateEmail('new@example.com');
    service.emailUpdateError = null;
    await cubit.completeReauthentication(password: 'secret');

    expect(service.reauthenticatedPasswords, ['secret']);
    expect(service.updatedEmails, ['new@example.com', 'new@example.com']);
    expect(cubit.state.status, AccountProfileStatus.ready);

    await cubit.close();
  });

  test('password reauth handles wrong password and network failure', () async {
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canUpdateEmail: true,
      ),
    )..emailUpdateError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.updateEmail('new@example.com');
    service.passwordReauthError = const AccountActionException(
      'wrong-password',
      'Wrong password.',
    );
    await cubit.completeReauthentication(password: 'bad');
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthFailed);

    service.passwordReauthError = const AccountActionException(
      'network-request-failed',
      'Network failed.',
    );
    await cubit.completeReauthentication(password: 'secret');
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthFailed);

    await cubit.close();
  });

  test('password reauth can be canceled without retrying action', () async {
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canUpdateEmail: true,
      ),
    )..emailUpdateError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: user,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.updateEmail('new@example.com');
    cubit.cancelReauthentication();

    expect(cubit.state.reauthRequest, isNull);
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthCanceled);
    expect(service.updatedEmails, ['new@example.com']);

    await cubit.close();
  });

  test('Google reauth retries pending account deletion', () async {
    final googleUser = user.copyWith(
      providers: const [AuthProviderMetadata(providerId: 'google.com')],
    );
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.google,
      ),
    )..authDeleteError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: googleUser,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.deleteAccount(warningConfirmed: true);
    service.authDeleteError = null;
    await cubit.completeReauthentication();

    expect(service.googleReauthCalls, 1);
    expect(service.deletionCalls, [
      'data:user-1',
      'auth:user-1',
      'data:user-1',
      'auth:user-1',
    ]);
    expect(cubit.state.status, AccountProfileStatus.deleted);

    await cubit.close();
  });

  test('Google reauth handles cancel, provider unavailable, and network failure',
      () async {
    final googleUser = user.copyWith(
      providers: const [AuthProviderMetadata(providerId: 'google.com')],
    );
    final service = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.google,
      ),
    )..authDeleteError = const AccountActionException(
        'requires-recent-login',
        'Recent sign-in required.',
      );
    final cubit = AccountProfileCubit(
      user: googleUser,
      accountProfileService: service,
      accountDeletionService: AccountDeletionService(
        accountProfileService: service,
      ),
    );

    await cubit.load();
    await cubit.deleteAccount(warningConfirmed: true);
    service.googleReauthError = const AccountActionException(
      'canceled',
      'Canceled.',
    );
    await cubit.completeReauthentication();
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthCanceled);
    expect(cubit.state.reauthRequest, isNull);

    await cubit.deleteAccount(warningConfirmed: true);
    service.googleReauthError = const AccountActionException(
      'provider-unavailable',
      'Unavailable.',
    );
    await cubit.completeReauthentication();
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthUnavailable);
    expect(cubit.state.reauthRequest, isNull);

    await cubit.deleteAccount(warningConfirmed: true);
    service.googleReauthError = const AccountActionException(
      'network-request-failed',
      'Network failed.',
    );
    await cubit.completeReauthentication();
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthFailed);

    await cubit.close();
  });
}

class _FakeAccountProfileService implements AccountProfileService {
  _FakeAccountProfileService({
    this.capabilities = const AccountProfileCapabilities(
      providerType: AccountProviderType.emailPassword,
      canSendPasswordReset: true,
      canUpdateEmail: true,
    ),
  });

  final AccountProfileCapabilities capabilities;
  final savedDisplayNames = <String>[];
  final deletionCalls = <String>[];
  final updatedEmails = <String>[];
  final reauthenticatedPasswords = <String>[];
  int googleReauthCalls = 0;
  AccountActionException? emailUpdateError;
  AccountActionException? authDeleteError;
  AccountActionException? passwordReauthError;
  AccountActionException? googleReauthError;

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    deletionCalls.add('auth:${user.userId}');
    final error = authDeleteError;
    if (error != null) throw error;
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    deletionCalls.add('data:${user.userId}');
    expect(plan.resolve(user.userId), contains('users/user-1/expenses'));
    expect(
        plan.resolve(user.userId), contains('users/user-1/settings/profile'));
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    return capabilities;
  }

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => null;

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {
    reauthenticatedPasswords.add(password);
    final error = passwordReauthError;
    if (error != null) throw error;
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {
    googleReauthCalls += 1;
    final error = googleReauthError;
    if (error != null) throw error;
  }

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    savedDisplayNames.add(displayName);
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {}

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {
    updatedEmails.add(newEmail);
    final error = emailUpdateError;
    if (error != null) throw error;
  }

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) {
    return const Stream.empty();
  }
}
