import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/widgets.dart';

class AppLanguageCubit extends Cubit<LanguagePreference> {
  AppLanguageCubit() : super(LanguagePreference.system);

  void setPreference(LanguagePreference preference) {
    if (state == preference) return;
    emit(preference);
  }

  void reset() => setPreference(LanguagePreference.system);
}

extension LanguagePreferenceLocale on LanguagePreference {
  Locale? get forcedLocale {
    final code = languageCode;
    return code == null ? null : Locale(code);
  }
}

String localeTagForAppContext(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'ar' ? 'ar-EG' : 'en-US';
}

String voiceLocaleIdForAppContext(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';
}
