import 'package:expense_repository/expense_repository.dart';

class AuthRepositoryException implements Exception {
  final String code;
  final String message;

  const AuthRepositoryException(this.code, this.message);

  @override
  String toString() => message;
}

enum AuthActionStatus {
  success,
  unavailable,
  requiresRecentLogin,
  networkError,
  canceled,
  failure,
}

class AuthActionResult {
  final AuthActionStatus status;
  final String? code;
  final String? message;

  const AuthActionResult._({
    required this.status,
    this.code,
    this.message,
  });

  const AuthActionResult.success() : this._(status: AuthActionStatus.success);

  const AuthActionResult.unavailable({
    String? code,
    String? message,
  }) : this._(
          status: AuthActionStatus.unavailable,
          code: code,
          message: message,
        );

  const AuthActionResult.requiresRecentLogin({
    String? code,
    String? message,
  }) : this._(
          status: AuthActionStatus.requiresRecentLogin,
          code: code,
          message: message,
        );

  const AuthActionResult.networkError({
    String? code,
    String? message,
  }) : this._(
          status: AuthActionStatus.networkError,
          code: code,
          message: message,
        );

  const AuthActionResult.canceled({
    String? code,
    String? message,
  }) : this._(
          status: AuthActionStatus.canceled,
          code: code,
          message: message,
        );

  const AuthActionResult.failure({
    String? code,
    String? message,
  }) : this._(
          status: AuthActionStatus.failure,
          code: code,
          message: message,
        );

  bool get isSuccess => status == AuthActionStatus.success;
  bool get requiresRecentLogin =>
      status == AuthActionStatus.requiresRecentLogin;
}

abstract class AuthRepository {
  Stream<AppUser?> get user;

  AppUser? get currentUser;

  Future<String?> getIdToken();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Starts provider sign-in and returns null when the user cancels.
  Future<AppUser?> signInWithGoogle();

  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AppUser> updateDisplayName(String displayName);

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<AuthActionResult> requestPasswordReset(String email) async {
    try {
      await resetPassword(email);
      return const AuthActionResult.success();
    } on AuthRepositoryException catch (error) {
      return AuthActionResult.failure(
        code: error.code,
        message: error.message,
      );
    }
  }

  Future<AuthActionResult> updateEmail(String newEmail) async {
    return const AuthActionResult.unavailable(
      code: 'unavailable',
      message: 'Email update is not available for this auth repository.',
    );
  }

  Future<AuthActionResult> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    return const AuthActionResult.unavailable(
      code: 'unavailable',
      message: 'Password reauthentication is not available for this account.',
    );
  }

  Future<AuthActionResult> reauthenticateWithGoogle() async {
    return const AuthActionResult.unavailable(
      code: 'unavailable',
      message: 'Google reauthentication is not available for this account.',
    );
  }

  Future<AuthActionResult> deleteCurrentUser() async {
    return const AuthActionResult.unavailable(
      code: 'unavailable',
      message: 'Account deletion is not available for this auth repository.',
    );
  }
}
