import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefers app-local display name over auth profile and email', () {
    final user = AppUser(
      userId: 'user-1',
      email: 'person@example.com',
      displayName: 'Google Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 19),
    );

    expect(
      AccountIdentity.displayName(
        user: user,
        localDisplayName: 'Local Name',
        fallbackUserLabel: 'User',
      ),
      'Local Name',
    );
  });

  test('falls back to auth display name, email, then localized user label', () {
    final namedUser = AppUser(
      userId: 'user-1',
      email: 'person@example.com',
      displayName: 'Auth Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 19),
    );
    final emailUser = namedUser.copyWith(displayName: '');
    final emptyUser = AppUser(
      userId: 'user-2',
      email: null,
      displayName: null,
      photoUrl: null,
      createdAt: DateTime(2026, 5, 19),
    );

    expect(
      AccountIdentity.displayName(
        user: namedUser,
        fallbackUserLabel: 'User',
      ),
      'Auth Name',
    );
    expect(
      AccountIdentity.displayName(
        user: emailUser,
        fallbackUserLabel: 'User',
      ),
      'person@example.com',
    );
    expect(
      AccountIdentity.displayName(
        user: emptyUser,
        fallbackUserLabel: 'User',
      ),
      'User',
    );
  });
}
