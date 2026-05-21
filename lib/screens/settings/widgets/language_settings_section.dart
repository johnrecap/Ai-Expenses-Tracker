import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/blocs/settings_bloc/settings_cubit.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({
    required this.settings,
    required this.isSaving,
    super.key,
  });

  final UserSettings settings;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: context.l10n.appLanguage,
      subtitle: context.l10n.appLanguageDescription,
      child: RadioGroup<LanguagePreference>(
        groupValue: settings.languagePreference,
        onChanged: (value) {
          if (isSaving || value == null) return;
          try {
            context.read<AppLanguageCubit>().setPreference(value);
          } catch (_) {}
          context.read<SettingsCubit>().saveLanguagePreference(value);
        },
        child: Column(
          children: [
            _LanguageOption(
              preference: LanguagePreference.system,
              title: context.l10n.languageSystem,
              subtitle: context.l10n.languageSystemDescription,
              isSaving: isSaving,
            ),
            _LanguageOption(
              preference: LanguagePreference.arabic,
              title: context.l10n.languageArabic,
              subtitle: context.l10n.languageArabicDescription,
              isSaving: isSaving,
            ),
            _LanguageOption(
              preference: LanguagePreference.english,
              title: context.l10n.languageEnglish,
              subtitle: context.l10n.languageEnglishDescription,
              isSaving: isSaving,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.preference,
    required this.title,
    required this.subtitle,
    required this.isSaving,
  });

  final LanguagePreference preference;
  final String title;
  final String subtitle;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<LanguagePreference>(
      value: preference,
      enabled: !isSaving,
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
