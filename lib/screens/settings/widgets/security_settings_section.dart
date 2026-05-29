import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/screens/app_lock/views/create_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecuritySettingsSection extends StatelessWidget {
  const SecuritySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLockCubit? appLockCubit;
    try {
      appLockCubit = context.read<AppLockCubit>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AppLockCubit, AppLockState>(
      bloc: appLockCubit,
      builder: (context, state) {
        final l10n = context.l10n;
        final isSaving = state.isBusy;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appProtection,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.pinLock),
                  subtitle: Text(l10n.pinLockDescription),
                  value: state.appLockEnabled,
                  onChanged: isSaving
                      ? null
                      : (value) => _toggleAppLock(context, value),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: state.appLockEnabled && state.hasPin && !isSaving,
                  title: Text(l10n.changePin),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: state.appLockEnabled && state.hasPin && !isSaving
                      ? () => _openPinScreen(context, changeExistingPin: true)
                      : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.biometricUnlock),
                  subtitle: Text(
                    state.biometricAvailable
                        ? l10n.biometricUnlockAvailableDescription
                        : l10n.biometricUnlockUnavailableDescription,
                  ),
                  value: state.biometricEnabled,
                  onChanged:
                      isSaving ||
                          !state.appLockEnabled ||
                          !state.hasPin ||
                          !state.biometricAvailable
                      ? null
                      : (value) => context
                            .read<AppLockCubit>()
                            .setBiometricEnabled(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleAppLock(BuildContext context, bool enabled) async {
    if (enabled) {
      await _openPinScreen(context);
      return;
    }

    await context.read<AppLockCubit>().disableLock();
  }

  Future<void> _openPinScreen(
    BuildContext context, {
    bool changeExistingPin = false,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<AppLockCubit>(),
          child: CreatePinScreen(changeExistingPin: changeExistingPin),
        ),
      ),
    );
  }
}
