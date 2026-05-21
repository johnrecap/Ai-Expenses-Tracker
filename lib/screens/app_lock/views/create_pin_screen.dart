import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/app_lock/cubit/app_lock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePinScreen extends StatefulWidget {
  final bool changeExistingPin;
  final bool popOnSave;

  const CreatePinScreen({
    this.changeExistingPin = false,
    this.popOnSave = true,
    super.key,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.changeExistingPin ? l10n.changePin : l10n.createPin,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: BlocConsumer<AppLockCubit, AppLockState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  widget.changeExistingPin
                      ? l10n.changePinIntro
                      : l10n.createPinIntro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: l10n.pinLabel,
                          counterText: '',
                        ),
                        validator: _validatePin,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: l10n.confirmPinLabel,
                          counterText: '',
                        ),
                        validator: _validateConfirmation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: state.isBusy ? null : _savePin,
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
                      : Text(
                          widget.changeExistingPin
                              ? l10n.saveNewPin
                              : l10n.enableAppLock,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _validatePin(String? value) {
    final pin = value?.trim() ?? '';
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) {
      return context.l10n.pinDigitsValidation;
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    final confirmation = value?.trim() ?? '';
    if (confirmation != _pinController.text.trim()) {
      return context.l10n.pinConfirmationMismatch;
    }
    return null;
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AppLockCubit>();
    final pin = _pinController.text.trim();
    final saved = widget.changeExistingPin
        ? await cubit.changePin(pin)
        : await cubit.enableLockWithPin(pin);

    if (!mounted || !saved || !widget.popOnSave) return;
    Navigator.pop(context, true);
  }
}
