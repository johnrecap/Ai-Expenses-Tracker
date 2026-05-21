part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [
        user.userId,
        user.email,
        user.displayName,
        user.photoUrl,
      ];
}

class AuthProfileUpdating extends AuthAuthenticated {
  const AuthProfileUpdating(super.user);
}

class AuthProfileUpdated extends AuthAuthenticated {
  const AuthProfileUpdated(super.user);
}

class AuthProfileUpdateFailure extends AuthAuthenticated {
  final String message;

  const AuthProfileUpdateFailure({
    required AppUser user,
    required this.message,
  }) : super(user);

  @override
  List<Object?> get props => [...super.props, message];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
