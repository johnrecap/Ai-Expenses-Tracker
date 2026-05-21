import 'package:expenses_tracker/security/biometric_service.dart';
import 'package:expenses_tracker/security/pin_service.dart';

class AppLockSettings {
  static const defaultLockTimeoutSeconds = 0;

  final bool appLockEnabled;
  final bool biometricEnabled;
  final int lockTimeoutSeconds;

  const AppLockSettings({
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.lockTimeoutSeconds,
  });

  const AppLockSettings.defaults()
      : appLockEnabled = false,
        biometricEnabled = false,
        lockTimeoutSeconds = defaultLockTimeoutSeconds;

  AppLockSettings copyWith({
    bool? appLockEnabled,
    bool? biometricEnabled,
    int? lockTimeoutSeconds,
  }) {
    return AppLockSettings(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
    );
  }
}

class AppLockService {
  static const _lockEnabledKey = 'app_lock.enabled';
  static const _biometricEnabledKey = 'app_lock.biometric_enabled';
  static const _lockTimeoutSecondsKey = 'app_lock.timeout_seconds';

  final AppLockStorage _storage;
  final PinService pinService;
  final BiometricAuthenticator biometricService;
  DateTime? _lastUnlockedAt;

  AppLockService({
    AppLockStorage? storage,
    PinService? pinService,
    BiometricAuthenticator? biometricService,
  })  : _storage = storage ?? const SecureAppLockStorage(),
        pinService = pinService ?? PinService(storage: storage),
        biometricService = biometricService ?? BiometricService();

  Future<AppLockSettings> getSettings() async {
    final enabled = await _readBool(_lockEnabledKey);
    final biometricEnabled = await _readBool(_biometricEnabledKey);
    final timeoutSeconds = await _readInt(_lockTimeoutSecondsKey) ??
        AppLockSettings.defaultLockTimeoutSeconds;

    return AppLockSettings(
      appLockEnabled: enabled,
      biometricEnabled: biometricEnabled,
      lockTimeoutSeconds: timeoutSeconds < 0
          ? AppLockSettings.defaultLockTimeoutSeconds
          : timeoutSeconds,
    );
  }

  Future<void> setLockEnabled(bool enabled) async {
    if (enabled && !await pinService.hasPin()) {
      throw StateError('A PIN is required before app lock can be enabled.');
    }

    await _writeBool(_lockEnabledKey, enabled);
    if (!enabled) {
      await _writeBool(_biometricEnabledKey, false);
      markUnlocked();
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled && !await biometricService.isSupported()) {
      throw StateError('Biometric authentication is not available.');
    }
    await _writeBool(_biometricEnabledKey, enabled);
  }

  Future<void> setLockTimeoutSeconds(int seconds) {
    final normalized = seconds < 0 ? 0 : seconds;
    return _storage.write(
      key: _lockTimeoutSecondsKey,
      value: normalized.toString(),
    );
  }

  Future<void> setupPin(String pin) async {
    await pinService.setPin(pin);
    await setLockEnabled(true);
  }

  Future<bool> shouldLock({DateTime? now}) async {
    final settings = await getSettings();
    if (!settings.appLockEnabled || !await pinService.hasPin()) return false;

    final unlockedAt = _lastUnlockedAt;
    if (unlockedAt == null) return true;
    if (settings.lockTimeoutSeconds <= 0) return true;

    final currentTime = now ?? DateTime.now();
    final elapsedSeconds = currentTime.difference(unlockedAt).inSeconds;
    return elapsedSeconds >= settings.lockTimeoutSeconds;
  }

  Future<bool> unlockWithPin(String pin) async {
    final unlocked = await pinService.verifyPin(pin);
    if (unlocked) markUnlocked();
    return unlocked;
  }

  Future<bool> unlockWithBiometrics() async {
    final settings = await getSettings();
    if (!settings.appLockEnabled || !settings.biometricEnabled) return false;
    final unlocked = await biometricService.authenticate();
    if (unlocked) markUnlocked();
    return unlocked;
  }

  void markUnlocked({DateTime? now}) {
    _lastUnlockedAt = now ?? DateTime.now();
  }

  Future<bool> _readBool(String key) async {
    return (await _storage.read(key: key)) == 'true';
  }

  Future<void> _writeBool(String key, bool value) {
    return _storage.write(key: key, value: value.toString());
  }

  Future<int?> _readInt(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }
}
