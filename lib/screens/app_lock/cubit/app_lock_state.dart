part of 'app_lock_cubit.dart';

enum AppLockStatus {
  initial,
  loading,
  setupRequired,
  locked,
  unlocking,
  saving,
  unlocked,
}

enum AppLockMessageKey {
  invalidPin,
  failedToSavePin,
  failedToChangePin,
  failedToDisableAppLock,
  biometricUnavailable,
  failedToUpdateBiometric,
  incorrectPin,
  failedToUnlock,
  usePinToUnlock,
  failedToLoadSettings,
}

class AppLockState extends Equatable {
  final AppLockStatus status;
  final bool appLockEnabled;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final bool hasPin;
  final AppLockMessageKey? messageKey;

  const AppLockState({
    required this.status,
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.biometricAvailable,
    required this.hasPin,
    this.messageKey,
  });

  const AppLockState.initial()
    : status = AppLockStatus.initial,
      appLockEnabled = false,
      biometricEnabled = false,
      biometricAvailable = false,
      hasPin = false,
      messageKey = null;

  bool get isLocked => status == AppLockStatus.locked;

  bool get isBusy =>
      status == AppLockStatus.loading ||
      status == AppLockStatus.unlocking ||
      status == AppLockStatus.saving;

  AppLockState copyWith({
    AppLockStatus? status,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool? hasPin,
    AppLockMessageKey? messageKey,
    bool clearMessage = false,
  }) {
    return AppLockState(
      status: status ?? this.status,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      hasPin: hasPin ?? this.hasPin,
      messageKey: clearMessage ? null : messageKey ?? this.messageKey,
    );
  }

  @override
  List<Object?> get props => [
    status,
    appLockEnabled,
    biometricEnabled,
    biometricAvailable,
    hasPin,
    messageKey,
  ];
}
