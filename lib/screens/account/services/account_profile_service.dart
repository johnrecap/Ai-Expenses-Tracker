import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/models/account_capabilities.dart';

class AccountActionException implements Exception {
  const AccountActionException(this.code, this.message);

  final String code;
  final String message;

  bool get requiresRecentLogin => code == 'requires-recent-login';

  @override
  String toString() => message;
}

abstract class AccountProfileService {
  Future<String?> loadLocalDisplayName(AppUser user);

  Stream<String?> watchLocalDisplayName(AppUser user);

  Future<void> saveLocalDisplayName(AppUser user, String displayName);

  Future<AccountProfileCapabilities> loadCapabilities(AppUser user);

  Future<void> sendPasswordReset(AppUser user);

  Future<void> updateEmail(AppUser user, String newEmail);

  Future<void> reauthenticateWithPassword(AppUser user, String password);

  Future<void> reauthenticateWithGoogle(AppUser user);

  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan);

  Future<void> deleteAuthAccount(AppUser user);
}

class DefaultAccountProfileService implements AccountProfileService {
  DefaultAccountProfileService._();

  static final instance = DefaultAccountProfileService._();

  final Map<String, String> _localDisplayNames = {};
  final Map<String, StreamController<String?>> _controllers = {};

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async {
    return _localDisplayNames[user.userId];
  }

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) async* {
    yield _localDisplayNames[user.userId];
    yield* _controllerFor(user.userId).stream;
  }

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw const AccountActionException(
        'invalid-display-name',
        'Display name is required.',
      );
    }
    _localDisplayNames[user.userId] = trimmed;
    _controllerFor(user.userId).add(trimmed);
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    return AccountProfileCapabilities.unknown;
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {
    throw const AccountActionException(
      'action-unavailable',
      'Password reset is not available for this sign-in provider yet.',
    );
  }

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {
    throw const AccountActionException(
      'action-unavailable',
      'Email update is not available for this sign-in provider yet.',
    );
  }

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {
    throw const AccountActionException(
      'action-unavailable',
      'Reauthentication is not available for this sign-in provider yet.',
    );
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {
    throw const AccountActionException(
      'action-unavailable',
      'Google reauthentication is not available for this sign-in provider yet.',
    );
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    throw const AccountActionException(
      'action-unavailable',
      'Account deletion backend is not available yet.',
    );
  }

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    throw const AccountActionException(
      'action-unavailable',
      'Account deletion backend is not available yet.',
    );
  }

  StreamController<String?> _controllerFor(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<String?>.broadcast(),
    );
  }
}

class RepositoryBackedAccountProfileService implements AccountProfileService {
  RepositoryBackedAccountProfileService({
    required SettingsRepository settingsRepository,
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _settingsRepository = settingsRepository,
        _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final SettingsRepository _settingsRepository;
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async {
    final settings = await _settingsRepository.getSettings();
    return settings.appDisplayName;
  }

  @override
  Stream<String?> watchLocalDisplayName(AppUser user) {
    return _settingsRepository
        .watchSettings()
        .map((settings) => settings.appDisplayName)
        .distinct();
  }

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw const AccountActionException(
        'invalid-display-name',
        'Display name is required.',
      );
    }
    await _settingsRepository.updateAppDisplayName(trimmed);
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    if (user.hasPasswordProvider) {
      return const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canSendPasswordReset: true,
        canUpdateEmail: true,
        needsPasswordReauth: true,
      );
    }
    if (user.hasGoogleProvider) {
      return const AccountProfileCapabilities(
        providerType: AccountProviderType.google,
      );
    }
    return const AccountProfileCapabilities(
      providerType: AccountProviderType.unknown,
    );
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {
    final email = _requiredEmail(user);
    _throwIfFailed(await _authRepository.requestPasswordReset(email));
  }

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {
    _throwIfFailed(await _authRepository.updateEmail(newEmail.trim()));
  }

  @override
  Future<void> reauthenticateWithPassword(
    AppUser user,
    String password,
  ) async {
    final email = _requiredEmail(user);
    _throwIfFailed(
      await _authRepository.reauthenticateWithPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {
    _throwIfFailed(await _authRepository.reauthenticateWithGoogle());
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    for (final path in plan.resolve(user.userId)) {
      final segments = path.split('/').where((part) => part.isNotEmpty).length;
      if (segments.isEven) {
        await _firestore.doc(path).delete();
      } else {
        await _deleteCollection(path);
      }
    }
    await _firestore.doc('users/${user.userId}').delete();
  }

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    _throwIfFailed(await _authRepository.deleteCurrentUser());
  }

  String _requiredEmail(AppUser user) {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      throw const AccountActionException(
        'missing-email',
        'This account does not have an email address.',
      );
    }
    return email;
  }

  void _throwIfFailed(AuthActionResult result) {
    if (result.isSuccess) return;
    final message = result.message?.trim();
    throw AccountActionException(
      result.code ?? result.status.name,
      message == null || message.isEmpty ? 'Account action failed.' : message,
    );
  }

  Future<void> _deleteCollection(String path) async {
    while (true) {
      final snapshot = await _firestore.collection(path).limit(100).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

class UserDataDeletionPlan {
  const UserDataDeletionPlan(this.paths);

  final List<String> paths;

  static const standard = UserDataDeletionPlan([
    'users/{userId}/expenses',
    'users/{userId}/categories',
    'users/{userId}/budgets',
    'users/{userId}/wallets',
    'users/{userId}/transfers',
    'users/{userId}/category_budgets',
    'users/{userId}/recurring_expenses',
    'users/{userId}/saving_goals',
    'users/{userId}/ai_actions',
    'users/{userId}/category_aliases',
    'users/{userId}/settings/profile',
  ]);

  List<String> resolve(String userId) {
    return paths.map((path) => path.replaceAll('{userId}', userId)).toList();
  }
}
