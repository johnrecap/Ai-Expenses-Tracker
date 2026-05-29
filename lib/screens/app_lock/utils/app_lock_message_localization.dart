import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:flutter/widgets.dart';

String localizedAppLockMessage(
  BuildContext context,
  AppLockMessageKey messageKey,
) {
  final l10n = context.l10n;
  switch (messageKey) {
    case AppLockMessageKey.invalidPin:
      return l10n.pinDigitsValidation;
    case AppLockMessageKey.failedToSavePin:
      return l10n.failedToSavePin;
    case AppLockMessageKey.failedToChangePin:
      return l10n.failedToChangePin;
    case AppLockMessageKey.failedToDisableAppLock:
      return l10n.failedToDisableAppLock;
    case AppLockMessageKey.biometricUnavailable:
      return l10n.biometricAuthenticationUnavailable;
    case AppLockMessageKey.failedToUpdateBiometric:
      return l10n.failedToUpdateBiometricSetting;
    case AppLockMessageKey.incorrectPin:
      return l10n.incorrectPin;
    case AppLockMessageKey.failedToUnlock:
      return l10n.failedToUnlock;
    case AppLockMessageKey.usePinToUnlock:
      return l10n.usePinToUnlock;
    case AppLockMessageKey.failedToLoadSettings:
      return l10n.failedToLoadAppLockSettings;
  }
}
