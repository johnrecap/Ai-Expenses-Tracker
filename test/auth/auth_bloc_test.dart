import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  bool signOutCalled = false;
  AppUser? googleUser;
  Object? googleError;
  bool googleSignInCalled = false;
  bool displayNameUpdateFails = false;
  bool displayNameUpdateThrowsAfterApplying = false;
  int updateDisplayNameCalls = 0;

  void emitUser(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> dispose() => _controller.close();

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<String?> getIdToken() async => _currentUser?.userId;

  @override
  Stream<AppUser?> get user => _controller.stream;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AuthActionResult> requestPasswordReset(String email) async {
    return const AuthActionResult.success();
  }

  @override
  Future<AuthActionResult> updateEmail(String newEmail) async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> reauthenticateWithGoogle() async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> deleteCurrentUser() async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      userId: 'user-1',
      email: email,
      displayName: null,
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );
    emitUser(user);
    return user;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    googleSignInCalled = true;
    final error = googleError;
    if (error != null) throw error;
    final user = googleUser;
    if (user != null) emitUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    emitUser(null);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = AppUser(
      userId: 'user-2',
      email: email,
      displayName: displayName,
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );
    emitUser(user);
    return user;
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    updateDisplayNameCalls += 1;
    if (displayNameUpdateFails) {
      throw const AuthRepositoryException(
        'profile-update-failed',
        'Profile update failed.',
      );
    }
    final user = _currentUser;
    if (user == null || user.isEmpty) {
      throw const AuthRepositoryException(
        'missing-user',
        'No signed-in user is available.',
      );
    }
    final updatedUser = user.copyWith(displayName: displayName.trim());
    emitUser(updatedUser);
    if (displayNameUpdateThrowsAfterApplying) {
      throw const AuthRepositoryException(
        'permission-denied',
        'Profile update failed after convergence.',
      );
    }
    return updatedUser;
  }
}

void main() {
  test('emits authenticated when repository stream emits a user', () async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(repository);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    final authenticated = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthAuthenticated>()),
    );

    repository.emitUser(
      AppUser(
        userId: 'user-1',
        email: 'user@example.com',
        displayName: 'Test User',
        photoUrl: null,
        createdAt: DateTime(2026, 5, 15),
      ),
    );

    await authenticated;

    await subscription.cancel();
    await bloc.close();
    await repository.dispose();

    expect(states.whereType<AuthAuthenticated>(), isNotEmpty);
  });

  test('sign out calls repository and emits unauthenticated', () async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(repository);
    final unauthenticated = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthUnauthenticated>()),
    );

    bloc.add(AuthSignOutRequested());

    await unauthenticated;

    expect(repository.signOutCalled, isTrue);

    await bloc.close();
    await repository.dispose();
  });

  test('google sign in emits loading then authenticated on success', () async {
    final repository = FakeAuthRepository()
      ..googleUser = AppUser(
        userId: 'google-user-1',
        email: 'google@example.com',
        displayName: 'Google User',
        photoUrl: 'https://example.test/photo.png',
        createdAt: DateTime(2026, 5, 17),
      );
    final bloc = AuthBloc(repository);
    final googleSignIn = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ]),
    );

    bloc.add(AuthGoogleSignInRequested());
    await googleSignIn;

    expect(repository.googleSignInCalled, isTrue);

    await bloc.close();
    await repository.dispose();
  });

  test('google sign in cancellation emits unauthenticated without failure',
      () async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(repository);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    final canceled = expectLater(
      bloc.stream,
      emitsThrough(isA<AuthUnauthenticated>()),
    );

    bloc.add(AuthGoogleSignInRequested());
    await canceled;

    await subscription.cancel();
    await bloc.close();
    await repository.dispose();

    expect(repository.googleSignInCalled, isTrue);
    expect(states.whereType<AuthFailure>(), isEmpty);
  });

  test('google sign in failure emits friendly setup error', () async {
    final repository = FakeAuthRepository()
      ..googleError = const AuthRepositoryException(
        'missing-google-token',
        'Token missing.',
      );
    final bloc = AuthBloc(repository);
    final failed = expectLater(
      bloc.stream,
      emitsThrough(
        isA<AuthFailure>().having(
          (state) => state.message,
          'message',
          contains('Google sign-in is not configured correctly'),
        ),
      ),
    );

    bloc.add(AuthGoogleSignInRequested());
    await failed;

    await bloc.close();
    await repository.dispose();
  });

  test('stale null auth event does not override a current signed-in user',
      () async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(repository);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    final user = AppUser(
      userId: 'user-1',
      email: 'user@example.com',
      displayName: 'Test User',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );

    repository._currentUser = user;
    repository._controller.add(null);
    await Future<void>.delayed(Duration.zero);

    await subscription.cancel();
    await bloc.close();
    await repository.dispose();

    expect(states.whereType<AuthUnauthenticated>(), isEmpty);
    expect(states.whereType<AuthAuthenticated>(), isNotEmpty);
  });

  test('display name update emits updating then updated user', () async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(repository);
    final user = AppUser(
      userId: 'user-1',
      email: 'user@example.com',
      displayName: 'Old Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );
    repository.emitUser(user);
    await Future<void>.delayed(Duration.zero);

    final updated = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthProfileUpdating>().having(
          (state) => state.user.displayName,
          'displayName',
          'Old Name',
        ),
        isA<AuthProfileUpdated>().having(
          (state) => state.user.displayName,
          'displayName',
          'New Name',
        ),
      ]),
    );

    bloc.add(const AuthDisplayNameUpdateRequested(' New Name '));
    await updated;

    expect(repository.updateDisplayNameCalls, 1);
    expect(repository.currentUser?.displayName, 'New Name');

    await bloc.close();
    await repository.dispose();
  });

  test('display name update failure keeps authenticated user', () async {
    final repository = FakeAuthRepository()..displayNameUpdateFails = true;
    final bloc = AuthBloc(repository);
    final user = AppUser(
      userId: 'user-1',
      email: 'user@example.com',
      displayName: 'Current Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );
    repository.emitUser(user);
    await Future<void>.delayed(Duration.zero);

    final failed = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthProfileUpdating>(),
        isA<AuthProfileUpdateFailure>()
            .having(
              (state) => state.user.displayName,
              'displayName',
              'Current Name',
            )
            .having(
              (state) => state.message,
              'message',
              contains('profile-update-failed'),
            ),
      ]),
    );

    bloc.add(const AuthDisplayNameUpdateRequested('New Name'));
    await failed;

    expect(repository.updateDisplayNameCalls, 1);
    expect(repository.currentUser?.displayName, 'Current Name');

    await bloc.close();
    await repository.dispose();
  });

  test('display name update converges when repository throws after applying',
      () async {
    final repository = FakeAuthRepository()
      ..displayNameUpdateThrowsAfterApplying = true;
    final bloc = AuthBloc(repository);
    final user = AppUser(
      userId: 'user-1',
      email: 'user@example.com',
      displayName: 'Current Name',
      photoUrl: null,
      createdAt: DateTime(2026, 5, 15),
    );
    repository.emitUser(user);
    await Future<void>.delayed(Duration.zero);

    final updated = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthProfileUpdating>(),
        isA<AuthProfileUpdated>().having(
          (state) => state.user.displayName,
          'displayName',
          'Converged Name',
        ),
      ]),
    );

    bloc.add(const AuthDisplayNameUpdateRequested('Converged Name'));
    await updated;

    expect(repository.updateDisplayNameCalls, 1);
    expect(repository.currentUser?.displayName, 'Converged Name');

    await bloc.close();
    await repository.dispose();
  });
}
