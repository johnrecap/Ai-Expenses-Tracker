import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login screen exposes Google sign-in action', () {
    final source = File(
      'lib/screens/auth/views/login_screen.dart',
    ).readAsStringSync();

    expect(source, contains('context.l10n.continueWithGoogle'));
    expect(source, contains('AuthGoogleSignInRequested'));
    expect(source, contains('_submitGoogleSignIn'));
  });
}
