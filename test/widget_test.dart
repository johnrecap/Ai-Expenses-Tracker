import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => null;

  @override
  Future<String?> getIdToken() async => null;

  @override
  Stream<AppUser?> get user => _controller.stream;

  Future<void> dispose() => _controller.close();

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('renders the splash screen title', (WidgetTester tester) async {
    final authRepository = FakeAuthRepository();

    await tester.pumpWidget(MyApp(authRepository: authRepository));
    await tester.pump();

    expect(find.text('Expense Tracker'), findsOneWidget);

    await tester.pumpWidget(Container());
    await authRepository.dispose();
  });
}
