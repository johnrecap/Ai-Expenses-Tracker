import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/models/account_capabilities.dart';
import 'package:expenses_tracker/screens/account/models/reauth_request.dart';
import 'package:expenses_tracker/screens/account/services/account_deletion_service.dart';
import 'package:expenses_tracker/screens/account/services/account_profile_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_profile_state.dart';

class AccountProfileCubit extends Cubit<AccountProfileState> {
  AccountProfileCubit({
    required AppUser user,
    required AccountProfileService accountProfileService,
    required AccountDeletionService accountDeletionService,
  })  : _accountProfileService = accountProfileService,
        _accountDeletionService = accountDeletionService,
        super(AccountProfileState.initial(user));

  final AccountProfileService _accountProfileService;
  final AccountDeletionService _accountDeletionService;

  Future<void> load() async {
    emit(state.copyWith(status: AccountProfileStatus.loading));
    try {
      final localDisplayName =
          await _accountProfileService.loadLocalDisplayName(state.user);
      final capabilities =
          await _accountProfileService.loadCapabilities(state.user);
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          localDisplayName: localDisplayName,
          capabilities: capabilities,
          clearMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.failure,
          messageKey: AccountProfileMessageKey.loadFailed,
        ),
      );
    }
  }

  Future<void> saveDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(messageKey: AccountProfileMessageKey.displayNameInvalid),
      );
      return;
    }
    emit(state.copyWith(status: AccountProfileStatus.savingDisplayName));
    try {
      await _accountProfileService.saveLocalDisplayName(state.user, trimmed);
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          localDisplayName: trimmed,
          messageKey: AccountProfileMessageKey.displayNameUpdated,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.displayNameUpdateFailed,
        ),
      );
    }
  }

  Future<void> sendPasswordReset() async {
    emit(state.copyWith(status: AccountProfileStatus.sendingPasswordReset));
    try {
      await _accountProfileService.sendPasswordReset(state.user);
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.passwordResetSent,
        ),
      );
    } on AccountActionException catch (error) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: error.requiresRecentLogin
              ? AccountProfileMessageKey.reauthRequired
              : AccountProfileMessageKey.passwordResetFailed,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.passwordResetFailed,
        ),
      );
    }
  }

  Future<void> updateEmail(String email) async {
    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      emit(state.copyWith(messageKey: AccountProfileMessageKey.emailInvalid));
      return;
    }
    emit(state.copyWith(status: AccountProfileStatus.updatingEmail));
    try {
      await _accountProfileService.updateEmail(state.user, trimmed);
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.emailUpdated,
        ),
      );
    } on AccountActionException catch (error) {
      final reauthRequest = error.requiresRecentLogin
          ? _reauthRequestFor(
              AccountSensitiveAction.updateEmail,
              newEmail: trimmed,
            )
          : null;
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: error.requiresRecentLogin
              ? AccountProfileMessageKey.reauthRequired
              : AccountProfileMessageKey.emailUpdateFailed,
          reauthRequest: reauthRequest,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.emailUpdateFailed,
        ),
      );
    }
  }

  Future<void> deleteAccount({
    required bool warningConfirmed,
    bool recentAuthConfirmed = false,
  }) async {
    if (!warningConfirmed) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.deleteConfirmationRequired,
        ),
      );
      return;
    }
    if (!recentAuthConfirmed) {
      final reauthRequest =
          _reauthRequestFor(AccountSensitiveAction.deleteAccount);
      if (!reauthRequest.requiresPassword && !reauthRequest.usesGoogle) {
        emit(
          state.copyWith(
            status: AccountProfileStatus.ready,
            messageKey: AccountProfileMessageKey.reauthUnavailable,
            clearReauthRequest: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.reauthRequired,
          reauthRequest: reauthRequest,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AccountProfileStatus.deletingAccount));
    try {
      await _accountDeletionService.deleteAccount(
        user: state.user,
        warningConfirmed: warningConfirmed,
        recentAuthConfirmed: recentAuthConfirmed,
      );
      emit(
        state.copyWith(
          status: AccountProfileStatus.deleted,
          messageKey: AccountProfileMessageKey.accountDeleted,
        ),
      );
    } on AccountDeletionException catch (error) {
      final reauthRequest = error.requiresRecentLogin
          ? _reauthRequestFor(AccountSensitiveAction.deleteAccount)
          : null;
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: _deletionMessage(error),
          reauthRequest: reauthRequest,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.accountDeleteFailed,
        ),
      );
    }
  }

  Future<void> completeReauthentication({String? password}) async {
    final request = state.reauthRequest;
    if (request == null) return;
    emit(state.copyWith(status: AccountProfileStatus.reauthenticating));

    try {
      if (request.requiresPassword) {
        final trimmedPassword = password?.trim() ?? '';
        if (trimmedPassword.isEmpty) {
          emit(
            state.copyWith(
              status: AccountProfileStatus.ready,
              messageKey: AccountProfileMessageKey.reauthFailed,
            ),
          );
          return;
        }
        await _accountProfileService.reauthenticateWithPassword(
          state.user,
          trimmedPassword,
        );
      } else if (request.usesGoogle) {
        await _accountProfileService.reauthenticateWithGoogle(state.user);
      } else {
        emit(
          state.copyWith(
            status: AccountProfileStatus.ready,
            messageKey: AccountProfileMessageKey.reauthUnavailable,
            clearReauthRequest: true,
          ),
        );
        return;
      }

      final retryRequest = request;
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.reauthSucceeded,
          clearReauthRequest: true,
        ),
      );
      await _retryAfterReauth(retryRequest);
    } on AccountActionException catch (error) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: _reauthMessage(error),
          clearReauthRequest: _shouldClearReauthRequest(error),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          messageKey: AccountProfileMessageKey.reauthFailed,
        ),
      );
    }
  }

  void cancelReauthentication() {
    emit(
      state.copyWith(
        status: AccountProfileStatus.ready,
        messageKey: AccountProfileMessageKey.reauthCanceled,
        clearReauthRequest: true,
      ),
    );
  }

  AccountProfileMessageKey _deletionMessage(AccountDeletionException error) {
    if (error.requiresRecentLogin) {
      return AccountProfileMessageKey.reauthRequired;
    }
    switch (error.code) {
      case 'confirmation-required':
        return AccountProfileMessageKey.deleteConfirmationRequired;
      case 'data-delete-failed':
        return AccountProfileMessageKey.dataDeleteFailed;
      case 'auth-delete-failed':
        return AccountProfileMessageKey.authDeleteFailed;
      default:
        return AccountProfileMessageKey.accountDeleteFailed;
    }
  }

  ReauthRequest _reauthRequestFor(
    AccountSensitiveAction action, {
    String? newEmail,
  }) {
    return ReauthRequest(
      providerType: state.capabilities.providerType,
      action: action,
      newEmail: newEmail,
    );
  }

  AccountProfileMessageKey _reauthMessage(AccountActionException error) {
    switch (error.code) {
      case 'canceled':
      case 'user-cancelled':
      case 'user-canceled':
        return AccountProfileMessageKey.reauthCanceled;
      case 'provider-unavailable':
      case 'action-unavailable':
        return AccountProfileMessageKey.reauthUnavailable;
      default:
        return AccountProfileMessageKey.reauthFailed;
    }
  }

  bool _shouldClearReauthRequest(AccountActionException error) {
    switch (error.code) {
      case 'canceled':
      case 'user-cancelled':
      case 'user-canceled':
      case 'provider-unavailable':
      case 'action-unavailable':
        return true;
      default:
        return false;
    }
  }

  Future<void> _retryAfterReauth(ReauthRequest request) async {
    switch (request.action) {
      case AccountSensitiveAction.updateEmail:
        final newEmail = request.newEmail;
        if (newEmail == null || newEmail.trim().isEmpty) return;
        await updateEmail(newEmail);
        return;
      case AccountSensitiveAction.deleteAccount:
        await deleteAccount(
          warningConfirmed: true,
          recentAuthConfirmed: true,
        );
        return;
    }
  }
}
