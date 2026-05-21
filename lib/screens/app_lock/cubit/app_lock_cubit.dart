import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/security/security.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  final AppLockService _appLockService;

  AppLockCubit({
    AppLockService? appLockService,
  })  : _appLockService = appLockService ?? AppLockService(),
        super(const AppLockState.initial());

  Future<void> initialize() async {
    emit(state.copyWith(status: AppLockStatus.loading));
    await _loadLockState(lockIfRequired: true);
  }

  Future<void> refreshSettings() async {
    await _loadLockState(lockIfRequired: state.isLocked);
  }

  Future<void> checkOnResume() async {
    await _loadLockState(lockIfRequired: true);
  }

  Future<bool> enableLockWithPin(String pin) async {
    emit(state.copyWith(status: AppLockStatus.saving, clearMessage: true));
    try {
      await _appLockService.setupPin(pin);
      final biometricAvailable =
          await _appLockService.biometricService.isSupported();
      _appLockService.markUnlocked();
      emit(
        AppLockState(
          status: AppLockStatus.unlocked,
          appLockEnabled: true,
          biometricEnabled: state.biometricEnabled && biometricAvailable,
          biometricAvailable: biometricAvailable,
          hasPin: true,
        ),
      );
      return true;
    } on FormatException catch (error) {
      emit(
        state.copyWith(
          status: AppLockStatus.setupRequired,
          message: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.setupRequired,
          message: 'Failed to save PIN.',
        ),
      );
      return false;
    }
  }

  Future<bool> changePin(String pin) async {
    emit(state.copyWith(status: AppLockStatus.saving, clearMessage: true));
    try {
      await _appLockService.pinService.setPin(pin);
      _appLockService.markUnlocked();
      await _loadLockState(lockIfRequired: false);
      return true;
    } on FormatException catch (error) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          message: error.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          message: 'Failed to change PIN.',
        ),
      );
      return false;
    }
  }

  Future<void> disableLock() async {
    emit(state.copyWith(status: AppLockStatus.saving, clearMessage: true));
    try {
      await _appLockService.setLockEnabled(false);
      await _loadLockState(lockIfRequired: false);
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          message: 'Failed to disable app lock.',
        ),
      );
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    emit(state.copyWith(status: AppLockStatus.saving, clearMessage: true));
    try {
      await _appLockService.setBiometricEnabled(enabled);
      await _loadLockState(lockIfRequired: false);
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          message: enabled
              ? 'Biometric authentication is not available.'
              : 'Failed to update biometric setting.',
        ),
      );
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    emit(state.copyWith(status: AppLockStatus.unlocking, clearMessage: true));
    try {
      final unlocked = await _appLockService.unlockWithPin(pin);
      if (!unlocked) {
        emit(
          state.copyWith(
            status: AppLockStatus.locked,
            message: 'Incorrect PIN.',
          ),
        );
        return false;
      }
      await _loadLockState(lockIfRequired: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.locked,
          message: 'Failed to unlock.',
        ),
      );
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    emit(state.copyWith(status: AppLockStatus.unlocking, clearMessage: true));
    try {
      final unlocked = await _appLockService.unlockWithBiometrics();
      if (!unlocked) {
        emit(
          state.copyWith(
            status: AppLockStatus.locked,
            message: 'Use PIN to unlock.',
          ),
        );
        return false;
      }
      await _loadLockState(lockIfRequired: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.locked,
          message: 'Use PIN to unlock.',
        ),
      );
      return false;
    }
  }

  Future<void> _loadLockState({required bool lockIfRequired}) async {
    try {
      final settings = await _appLockService.getSettings();
      final hasPin = await _appLockService.pinService.hasPin();
      final biometricAvailable =
          await _appLockService.biometricService.isSupported();

      if (settings.appLockEnabled && !hasPin) {
        emit(
          AppLockState(
            status: AppLockStatus.setupRequired,
            appLockEnabled: true,
            biometricEnabled: false,
            biometricAvailable: biometricAvailable,
            hasPin: false,
          ),
        );
        return;
      }

      final shouldLock = lockIfRequired && await _appLockService.shouldLock();
      emit(
        AppLockState(
          status: shouldLock ? AppLockStatus.locked : AppLockStatus.unlocked,
          appLockEnabled: settings.appLockEnabled,
          biometricEnabled:
              settings.biometricEnabled && biometricAvailable && hasPin,
          biometricAvailable: biometricAvailable,
          hasPin: hasPin,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          message: 'Failed to load app lock settings.',
        ),
      );
    }
  }
}
