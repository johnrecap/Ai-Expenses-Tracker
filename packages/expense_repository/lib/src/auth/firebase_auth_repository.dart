import 'dart:async';
import 'dart:developer';

import 'package:expense_repository/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AppUser?> get user {
    return _firebaseAuth.userChanges().map((user) {
      if (user == null) return null;
      return AppUser.fromFirebaseUser(user);
    });
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }

  @override
  Future<String?> getIdToken() async {
    return _firebaseAuth.currentUser?.getIdToken();
  }

  @override
  Future<void> resetPassword(String email) {
    return _firebaseAuth
        .sendPasswordResetEmail(email: email.trim())
        .onError<FirebaseAuthException>((error, stackTrace) {
      throw AuthRepositoryException(
        error.code,
        error.message ?? 'Password reset failed.',
      );
    });
  }

  @override
  Future<AuthActionResult> requestPasswordReset(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return const AuthActionResult.failure(
        code: 'invalid-email',
        message: 'Email is required.',
      );
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: trimmedEmail);
      return const AuthActionResult.success();
    } on FirebaseAuthException catch (error) {
      return _authActionResultFromFirebase(error);
    }
  }

  @override
  Future<AuthActionResult> updateEmail(String newEmail) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const AuthActionResult.failure(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    if (!_hasPasswordProvider(user)) {
      return const AuthActionResult.unavailable(
        code: 'provider-unavailable',
        message: 'Email update is only available for email/password accounts.',
      );
    }

    final trimmedEmail = newEmail.trim();
    if (trimmedEmail.isEmpty) {
      return const AuthActionResult.failure(
        code: 'invalid-email',
        message: 'Email is required.',
      );
    }

    try {
      await user.updateEmail(trimmedEmail);
      await user.reload();
      return const AuthActionResult.success();
    } on FirebaseAuthException catch (error) {
      return _authActionResultFromFirebase(error);
    }
  }

  @override
  Future<AuthActionResult> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const AuthActionResult.failure(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    if (!_hasPasswordProvider(user)) {
      return const AuthActionResult.unavailable(
        code: 'provider-unavailable',
        message:
            'Password reauthentication is only available for email/password accounts.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return const AuthActionResult.success();
    } on FirebaseAuthException catch (error) {
      return _authActionResultFromFirebase(error);
    }
  }

  @override
  Future<AuthActionResult> reauthenticateWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const AuthActionResult.failure(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    if (!_hasGoogleProvider(user)) {
      return const AuthActionResult.unavailable(
        code: 'provider-unavailable',
        message:
            'Google reauthentication is only available for Google accounts.',
      );
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthActionResult.canceled(
          code: 'canceled',
          message: 'Google sign-in was canceled.',
        );
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        return const AuthActionResult.failure(
          code: 'missing-google-token',
          message: 'Google did not return an authentication token.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return const AuthActionResult.success();
    } on FirebaseAuthException catch (error) {
      return _authActionResultFromFirebase(error);
    } on PlatformException catch (error) {
      if (_isGoogleCancelCode(error.code)) {
        return AuthActionResult.canceled(
          code: error.code,
          message: error.message ?? 'Google sign-in was canceled.',
        );
      }
      return AuthActionResult.failure(
        code: error.code,
        message: error.message ?? _googleAuthFallbackMessage(error.code),
      );
    }
  }

  @override
  Future<AuthActionResult> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const AuthActionResult.failure(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }

    try {
      await user.delete();
      return const AuthActionResult.success();
    } on FirebaseAuthException catch (error) {
      return _authActionResultFromFirebase(error);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'missing-user',
          'No user returned from Firebase Auth.',
        );
      }
      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        error.code,
        error.message ?? 'Sign in failed.',
      );
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw const AuthRepositoryException(
          'missing-google-token',
          'Google sign-in did not return an authentication token. Check Firebase and platform OAuth setup.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'missing-user',
          'No user returned from Firebase Auth.',
        );
      }

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        unawaited(_ensureDefaultSettings(user.uid, source: 'Google sign in'));
      }

      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      final code = error.code == 'invalid-credential'
          ? 'google-invalid-credential'
          : error.code;
      throw AuthRepositoryException(
        code,
        error.message ?? _googleAuthFallbackMessage(code),
      );
    } on PlatformException catch (error) {
      if (_isGoogleCancelCode(error.code)) return null;
      throw AuthRepositoryException(
        error.code,
        error.message ?? _googleAuthFallbackMessage(error.code),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      log(
        'Google sign out failed: $error',
        name: 'FirebaseAuthRepository',
      );
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      var user = credential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'missing-user',
          'No user returned from Firebase Auth.',
        );
      }
      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await user.updateDisplayName(trimmedDisplayName);
        await user.reload();
        user = _firebaseAuth.currentUser ?? user;
      }
      try {
        await FirebaseSettingsRepository(userId: user.uid)
            .ensureDefaultSettings();
      } catch (error) {
        log(
          'Default settings creation failed after sign up: $error',
          name: 'FirebaseAuthRepository',
        );
      }
      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        error.code,
        error.message ?? 'Sign up failed.',
      );
    }
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    final trimmedDisplayName = displayName.trim();
    if (trimmedDisplayName.isEmpty) {
      throw const AuthRepositoryException(
        'invalid-display-name',
        'Display name is required.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthRepositoryException(
        'missing-user',
        'No signed-in user is available.',
      );
    }

    try {
      await user.updateDisplayName(trimmedDisplayName);
      await user.reload();
      return AppUser.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        error.code,
        error.message ?? 'Display name update failed.',
      );
    }
  }

  bool _isGoogleCancelCode(String code) {
    return code == 'sign_in_canceled' ||
        code == 'canceled' ||
        code == 'popup_closed_by_user';
  }

  bool _hasPasswordProvider(User user) {
    return user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }

  bool _hasGoogleProvider(User user) {
    return user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
  }

  AuthActionResult _authActionResultFromFirebase(FirebaseAuthException error) {
    final message = error.message;
    switch (error.code) {
      case 'requires-recent-login':
        return AuthActionResult.requiresRecentLogin(
          code: error.code,
          message: message ?? 'Recent sign-in is required.',
        );
      case 'network-request-failed':
      case 'network_error':
        return AuthActionResult.networkError(
          code: error.code,
          message: message ?? 'Network error. Try again.',
        );
      case 'operation-not-allowed':
      case 'provider-already-linked':
        return AuthActionResult.unavailable(
          code: error.code,
          message: message ?? 'This account action is not available.',
        );
      case 'user-cancelled':
      case 'canceled':
        return AuthActionResult.canceled(
          code: error.code,
          message: message ?? 'Account action was canceled.',
        );
      default:
        return AuthActionResult.failure(
          code: error.code,
          message: message ?? 'Account action failed.',
        );
    }
  }

  Future<void> _ensureDefaultSettings(
    String userId, {
    required String source,
  }) async {
    try {
      await FirebaseSettingsRepository(userId: userId).ensureDefaultSettings();
    } catch (error) {
      log(
        'Default settings creation failed after $source: $error',
        name: 'FirebaseAuthRepository',
      );
    }
  }

  String _googleAuthFallbackMessage(String code) {
    switch (code) {
      case 'network_error':
      case 'network-request-failed':
        return 'Network error while signing in with Google.';
      case 'operation-not-allowed':
      case 'provider-already-linked':
        return 'Google sign-in is not enabled for this Firebase project.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign-in method.';
      case 'google-invalid-credential':
      case 'sign_in_failed':
        return 'Google sign-in failed. Check Firebase package name, SHA fingerprints, and provider setup.';
      default:
        return 'Google sign-in failed.';
    }
  }
}
