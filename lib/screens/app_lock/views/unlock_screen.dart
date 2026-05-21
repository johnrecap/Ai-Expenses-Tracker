import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocConsumer<AppLockCubit, AppLockState>(
          listener: (context, state) {
            if (state.message != null && state.message!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          },
          builder: (context, state) {
            final l10n = context.l10n;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(Icons.lock, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      l10n.expenseTrackerLocked,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enterPinToContinue,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      enabled: !state.isBusy,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: l10n.pinLabel,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _unlockWithPin(),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: state.isBusy ? null : _unlockWithPin,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: state.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.unlock),
                    ),
                    if (state.biometricEnabled) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: state.isBusy ? null : _unlockWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n.useBiometrics),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    final unlocked = await context.read<AppLockCubit>().unlockWithPin(pin);
    if (unlocked) _pinController.clear();
  }

  Future<void> _unlockWithBiometrics() async {
    await context.read<AppLockCubit>().unlockWithBiometrics();
  }
}
