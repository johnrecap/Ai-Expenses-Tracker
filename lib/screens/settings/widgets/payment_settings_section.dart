import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/blocs/settings_bloc/settings_cubit.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentSettingsSection extends StatelessWidget {
  const PaymentSettingsSection({
    required this.settings,
    required this.isSaving,
    super.key,
  });

  final UserSettings settings;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSection(
      title: l10n.paymentSettingsTitle,
      subtitle: l10n.paymentSettingsDescription,
      child: DropdownButtonFormField<PaymentMethod>(
        key: ValueKey('default-payment-${settings.defaultPaymentMethod.name}'),
        initialValue: settings.defaultPaymentMethod,
        decoration: InputDecoration(
          labelText: l10n.defaultPaymentMethod,
          border: const OutlineInputBorder(),
        ),
        items: PaymentMethod.values
            .map(
              (paymentMethod) => DropdownMenuItem(
                value: paymentMethod,
                child: Text(localizedPaymentMethod(l10n, paymentMethod)),
              ),
            )
            .toList(),
        onChanged: isSaving
            ? null
            : (value) {
                if (value == null) return;
                context.read<SettingsCubit>().saveDefaultPaymentMethod(value);
              },
      ),
    );
  }
}
