enum LanguagePreference {
  system('system'),
  english('en'),
  arabic('ar');

  const LanguagePreference(this.storageValue);

  final String storageValue;

  static LanguagePreference fromStorageValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final preference in values) {
      if (preference.storageValue == normalized) return preference;
    }
    return LanguagePreference.system;
  }

  bool get followsSystem => this == LanguagePreference.system;

  String? get languageCode {
    switch (this) {
      case LanguagePreference.system:
        return null;
      case LanguagePreference.english:
        return 'en';
      case LanguagePreference.arabic:
        return 'ar';
    }
  }

  String get voiceLocaleHint {
    switch (this) {
      case LanguagePreference.system:
        return '';
      case LanguagePreference.english:
        return 'en_US';
      case LanguagePreference.arabic:
        return 'ar_EG';
    }
  }
}
