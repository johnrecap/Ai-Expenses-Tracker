import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/onboarding/blocs/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EssentialsStep extends StatelessWidget {
  const EssentialsStep({
    required this.state,
    super.key,
  });

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyOptions = {
      ...UserSettings.defaultSupportedCurrencies,
      if (state.selectedBaseCurrency != null) state.selectedBaseCurrency!,
    }.toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingEssentialsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingEssentialsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        _SectionLabel(text: l10n.onboardingLanguageLabel),
        Semantics(
          label: l10n.onboardingLanguageLabel,
          child: RadioGroup<LanguagePreference>(
            groupValue: state.selectedLanguagePreference,
            onChanged: (value) {
              if (state.isSaving || value == null) return;
              context.read<OnboardingCubit>().selectLanguage(value);
            },
            child: Column(
              children: [
                RadioListTile<LanguagePreference>(
                  key: const Key('onboarding-language-en'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.onboardingLanguageEnglish),
                  value: LanguagePreference.english,
                  enabled: !state.isSaving,
                ),
                RadioListTile<LanguagePreference>(
                  key: const Key('onboarding-language-ar'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.onboardingLanguageArabic),
                  value: LanguagePreference.arabic,
                  enabled: !state.isSaving,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: const Key('onboarding-currency'),
          isExpanded: true,
          initialValue: state.selectedBaseCurrency,
          decoration: InputDecoration(
            labelText: l10n.onboardingCurrencyLabel,
            border: const OutlineInputBorder(),
          ),
          hint: Text(l10n.onboardingCurrencyLabel),
          items: currencyOptions
              .map(
                (currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                ),
              )
              .toList(),
          onChanged: state.isSaving
              ? null
              : context.read<OnboardingCubit>().selectBaseCurrency,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<PaymentMethod>(
          key: const Key('onboarding-payment'),
          isExpanded: true,
          initialValue: state.selectedPaymentMethod,
          decoration: InputDecoration(
            labelText: l10n.onboardingPaymentLabel,
            border: const OutlineInputBorder(),
          ),
          hint: Text(l10n.onboardingPaymentLabel),
          items: PaymentMethod.values
              .map(
                (paymentMethod) => DropdownMenuItem(
                  value: paymentMethod,
                  child: Text(localizedPaymentMethod(l10n, paymentMethod)),
                ),
              )
              .toList(),
          onChanged: state.isSaving
              ? null
              : context.read<OnboardingCubit>().selectPaymentMethod,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
