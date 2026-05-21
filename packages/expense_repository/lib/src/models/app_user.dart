import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

enum AppAuthProvider {
  password('password'),
  google('google.com'),
  unknown('unknown');

  const AppAuthProvider(this.providerId);

  final String providerId;

  static AppAuthProvider fromProviderId(String providerId) {
    switch (providerId) {
      case 'password':
        return AppAuthProvider.password;
      case 'google.com':
        return AppAuthProvider.google;
      default:
        return AppAuthProvider.unknown;
    }
  }
}

class AuthProviderMetadata {
  final String providerId;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;

  const AuthProviderMetadata({
    required this.providerId,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
  });

  AppAuthProvider get provider => AppAuthProvider.fromProviderId(providerId);

  factory AuthProviderMetadata.fromFirebaseProvider(
    firebase_auth.UserInfo info,
  ) {
    return AuthProviderMetadata(
      providerId: info.providerId,
      email: info.email,
      displayName: info.displayName,
      phoneNumber: info.phoneNumber,
      photoUrl: info.photoURL,
    );
  }
}

class AccountCapabilities {
  final bool canRequestPasswordReset;
  final bool canUpdateEmail;
  final bool canReauthenticateWithPassword;
  final bool canDeleteAccount;

  const AccountCapabilities({
    required this.canRequestPasswordReset,
    required this.canUpdateEmail,
    required this.canReauthenticateWithPassword,
    required this.canDeleteAccount,
  });

  const AccountCapabilities.none()
      : canRequestPasswordReset = false,
        canUpdateEmail = false,
        canReauthenticateWithPassword = false,
        canDeleteAccount = false;
}

class AppUser {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final List<AuthProviderMetadata> providers;

  const AppUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.createdAt,
    this.providers = const [],
  });

  static final empty = AppUser(
    userId: '',
    email: null,
    displayName: null,
    photoUrl: null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    providers: const [],
  );

  bool get isEmpty => userId.isEmpty;
  bool get isNotEmpty => !isEmpty;
  List<String> get providerIds =>
      providers.map((provider) => provider.providerId).toList(growable: false);
  bool get hasPasswordProvider => providerIds.contains('password');
  bool get hasGoogleProvider => providerIds.contains('google.com');
  AccountCapabilities get accountCapabilities {
    if (isEmpty) return const AccountCapabilities.none();
    return AccountCapabilities(
      canRequestPasswordReset: hasPasswordProvider,
      canUpdateEmail: hasPasswordProvider,
      canReauthenticateWithPassword: hasPasswordProvider,
      canDeleteAccount: true,
    );
  }

  AppUser copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    List<AuthProviderMetadata>? providers,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      providers: providers ?? this.providers,
    );
  }

  factory AppUser.fromFirebaseUser(firebase_auth.User user) {
    return AppUser(
      userId: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      providers: user.providerData
          .map(AuthProviderMetadata.fromFirebaseProvider)
          .toList(growable: false),
    );
  }
}
