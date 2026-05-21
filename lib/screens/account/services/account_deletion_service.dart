import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/account/services/account_profile_service.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.code, this.message);

  final String code;
  final String message;

  bool get requiresRecentLogin => code == 'requires-recent-login';

  @override
  String toString() => message;
}

class AccountDeletionService {
  const AccountDeletionService({
    required AccountProfileService accountProfileService,
    UserDataDeletionPlan deletionPlan = UserDataDeletionPlan.standard,
  })  : _accountProfileService = accountProfileService,
        _deletionPlan = deletionPlan;

  final AccountProfileService _accountProfileService;
  final UserDataDeletionPlan _deletionPlan;

  Future<void> deleteAccount({
    required AppUser user,
    required bool warningConfirmed,
  }) async {
    if (!warningConfirmed) {
      throw const AccountDeletionException(
        'confirmation-required',
        'Account deletion requires explicit confirmation.',
      );
    }
    try {
      await _accountProfileService.deleteUserData(user, _deletionPlan);
    } on AccountActionException catch (error) {
      throw AccountDeletionException(
        error.code == 'requires-recent-login'
            ? error.code
            : 'data-delete-failed',
        error.message,
      );
    } catch (_) {
      throw const AccountDeletionException(
        'data-delete-failed',
        'Account data could not be deleted.',
      );
    }

    try {
      await _accountProfileService.deleteAuthAccount(user);
    } on AccountActionException catch (error) {
      throw AccountDeletionException(
        error.code == 'requires-recent-login'
            ? error.code
            : 'auth-delete-failed',
        error.message,
      );
    } catch (_) {
      throw const AccountDeletionException(
        'auth-delete-failed',
        'Account sign-in record could not be deleted.',
      );
    }
  }
}
