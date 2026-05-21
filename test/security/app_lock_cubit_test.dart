import 'dart:math';

import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/security/security.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryAppLockStorage implements AppLockStorage {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

class FakeBiometricAuthenticator implements BiometricAuthenticator {
  bool supported;
  bool nextResult;

  FakeBiometricAuthenticator({
    this.supported = false,
    this.nextResult = false,
  });

  @override
  Future<bool> authenticate() async => nextResult;

  @override
  Future<bool> isSupported() async => supported;
}

AppLockCubit _cubit({
  MemoryAppLockStorage? storage,
  FakeBiometricAuthenticator? biometric,
}) {
  final resolvedStorage = storage ?? MemoryAppLockStorage();
  final pinService = PinService(
    storage: resolvedStorage,
    random: Random(7),
  );
  return AppLockCubit(
    appLockService: AppLockService(
      storage: resolvedStorage,
      pinService: pinService,
      biometricService: biometric ?? FakeBiometricAuthenticator(),
    ),
  );
}

void main() {
  test('initializes unlocked when app lock is disabled', () async {
    final cubit = _cubit();

    await cubit.initialize();

    expect(cubit.state.status, AppLockStatus.unlocked);
    expect(cubit.state.appLockEnabled, isFalse);

    await cubit.close();
  });

  test('enables lock with PIN and locks on resume', () async {
    final storage = MemoryAppLockStorage();
    final cubit = _cubit(storage: storage);

    final saved = await cubit.enableLockWithPin('1234');
    await cubit.checkOnResume();

    expect(saved, isTrue);
    expect(cubit.state.status, AppLockStatus.locked);
    expect(cubit.state.appLockEnabled, isTrue);
    expect(cubit.state.hasPin, isTrue);

    await cubit.close();
  });

  test('PIN unlock succeeds and wrong PIN keeps app locked', () async {
    final storage = MemoryAppLockStorage();
    final cubit = _cubit(storage: storage);

    await cubit.enableLockWithPin('1234');
    await cubit.checkOnResume();

    expect(await cubit.unlockWithPin('0000'), isFalse);
    expect(cubit.state.status, AppLockStatus.locked);
    expect(cubit.state.message, 'Incorrect PIN.');

    expect(await cubit.unlockWithPin('1234'), isTrue);
    expect(cubit.state.status, AppLockStatus.unlocked);

    await cubit.close();
  });

  test('biometric fallback leaves PIN unlock available when canceled',
      () async {
    final biometric = FakeBiometricAuthenticator(
      supported: true,
      nextResult: false,
    );
    final storage = MemoryAppLockStorage();
    final cubit = _cubit(storage: storage, biometric: biometric);

    await cubit.enableLockWithPin('1234');
    await cubit.setBiometricEnabled(true);
    await cubit.checkOnResume();

    expect(cubit.state.biometricEnabled, isTrue);
    expect(await cubit.unlockWithBiometrics(), isFalse);
    expect(cubit.state.status, AppLockStatus.locked);
    expect(await cubit.unlockWithPin('1234'), isTrue);

    await cubit.close();
  });
}
