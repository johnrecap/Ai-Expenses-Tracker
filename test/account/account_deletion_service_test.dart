import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final user = AppUser(
    userId: 'user-1',
    email: 'person@example.com',
    displayName: 'Person',
    photoUrl: null,
    createdAt: DateTime(2026, 5, 19),
  );

  test('does not delete user data before recent auth is confirmed', () async {
    final profileService = _FakeAccountProfileService();
    final service = AccountDeletionService(
      accountProfileService: profileService,
    );

    expect(
      service.deleteAccount(
        user: user,
        warningConfirmed: true,
        recentAuthConfirmed: false,
      ),
      throwsA(
        isA<AccountDeletionException>().having(
          (error) => error.requiresRecentLogin,
          'requiresRecentLogin',
          isTrue,
        ),
      ),
    );

    expect(profileService.calls, isEmpty);
  });

  test('deletes data then auth after confirmation and recent auth', () async {
    final profileService = _FakeAccountProfileService();
    final service = AccountDeletionService(
      accountProfileService: profileService,
    );

    await service.deleteAccount(
      user: user,
      warningConfirmed: true,
      recentAuthConfirmed: true,
    );

    expect(profileService.calls, ['data:user-1', 'auth:user-1']);
  });
}

class _FakeAccountProfileService implements AccountProfileService {
  final calls = <String>[];

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    calls.add('auth:${user.userId}');
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    calls.add('data:${user.userId}');
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    return const AccountProfileCapabilities(
      providerType: AccountProviderType.emailPassword,
    );
  }

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => null;

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {}

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {}

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {}

  @override
  Future<void> sendPasswordReset(AppUser user) async {}

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {}

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) {
    return const Stream.empty();
  }
}
