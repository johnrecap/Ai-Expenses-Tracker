import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _userSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthDisplayNameUpdateRequested>(_onDisplayNameUpdateRequested);

    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user ?? _authRepository.currentUser;
    if (user == null || user.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(user));
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null && currentUser.isNotEmpty) {
        emit(AuthAuthenticated(currentUser));
        return;
      }
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user == null) {
        final currentUser = _authRepository.currentUser;
        if (currentUser != null && currentUser.isNotEmpty) {
          emit(AuthAuthenticated(currentUser));
          return;
        }
        emit(AuthUnauthenticated());
        return;
      }
      emit(AuthAuthenticated(user));
    } catch (error) {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null && currentUser.isNotEmpty) {
        emit(AuthAuthenticated(currentUser));
        return;
      }
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null && currentUser.isNotEmpty) {
        emit(AuthAuthenticated(currentUser));
        return;
      }
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthPasswordResetSent());
      final currentUser = _authRepository.currentUser;
      if (currentUser == null || currentUser.isEmpty) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(currentUser));
      }
    } catch (error) {
      final currentUser = _authRepository.currentUser;
      emit(AuthFailure(_friendlyError(error)));
      if (currentUser != null && currentUser.isNotEmpty) return;
    }
  }

  Future<void> _onDisplayNameUpdateRequested(
    AuthDisplayNameUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null || currentUser.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthProfileUpdating(currentUser));
    try {
      final updatedUser = await _authRepository.updateDisplayName(
        event.displayName,
      );
      emit(AuthProfileUpdated(updatedUser));
    } catch (error) {
      final requestedDisplayName = event.displayName.trim();
      final convergedUser = _authRepository.currentUser;
      if (convergedUser != null &&
          convergedUser.isNotEmpty &&
          convergedUser.displayName?.trim() == requestedDisplayName) {
        emit(AuthProfileUpdated(convergedUser));
        return;
      }
      final streamConvergedUser = await _waitForDisplayNameConvergence(
        requestedDisplayName,
      );
      if (streamConvergedUser != null) {
        emit(AuthProfileUpdated(streamConvergedUser));
        return;
      }
      emit(
        AuthProfileUpdateFailure(
          user: convergedUser ?? currentUser,
          message: _friendlyError(error),
        ),
      );
    }
  }

  String _friendlyError(Object error) {
    if (error is AuthRepositoryException) {
      final message = error.message.trim();
      switch (error.code) {
        case 'invalid-display-name':
          return _withCode('Enter a valid display name.', error.code);
        case 'invalid-email':
          return _withCode('Enter a valid email address.', error.code);
        case 'user-disabled':
          return _withCode('This account has been disabled.', error.code);
        case 'network-request-failed':
        case 'network_error':
          return _withCode(
            'Check your internet connection and try again.',
            error.code,
          );
        case 'operation-not-allowed':
          return _withCode(
            'Google sign-in is not enabled for this Firebase project.',
            error.code,
          );
        case 'account-exists-with-different-credential':
          return _withCode(
            'An account already exists for this email. Sign in with the original method.',
            error.code,
          );
        case 'missing-google-token':
        case 'google-invalid-credential':
        case 'sign_in_failed':
          return _withCode(
            'Google sign-in is not configured correctly. Check Firebase package name, SHA fingerprints, and provider setup.',
            error.code,
          );
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return _withCode('Email or password is incorrect.', error.code);
        case 'email-already-in-use':
          return _withCode(
            'An account already exists for this email.',
            error.code,
          );
        case 'weak-password':
          return _withCode('Password is too weak.', error.code);
        default:
          if (message.isEmpty) return 'Authentication failed (${error.code}).';
          return '$message (${error.code})';
      }
    }
    final message = error.toString().trim();
    if (message.isEmpty) return 'Authentication failed. Please try again.';
    return 'Authentication failed: $message';
  }

  String _withCode(String message, String code) => '$message ($code)';

  Future<AppUser?> _waitForDisplayNameConvergence(
    String requestedDisplayName,
  ) async {
    if (requestedDisplayName.isEmpty) return null;
    try {
      return await _authRepository.user
          .where(
            (user) =>
                user != null &&
                user.isNotEmpty &&
                user.displayName?.trim() == requestedDisplayName,
          )
          .cast<AppUser>()
          .first
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }
}
