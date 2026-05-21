# Localization Conventions

This app uses Flutter gen-l10n with ARB files in `lib/l10n/`.

## Files

- `l10n.yaml` defines the generation settings.
- `lib/l10n/app_en.arb` is the English template.
- `lib/l10n/app_ar.arb` contains Arabic translations.
- Generated localization output is expected at `lib/l10n/app_localizations.dart`.
- `lib/l10n/l10n.dart` provides the `context.l10n` extension and small enum label helpers.

## String Rules

- Static user-facing UI text belongs in ARB files.
- Do not translate user-generated values such as category names, descriptions, notes, display names, or imported/exported data.
- Keep localization keys stable and descriptive. Prefer feature-neutral common keys such as `save`, `cancel`, and `retry` only when the same wording is correct everywhere.
- Add placeholders for dynamic values instead of building full user-facing sentences inline.
- Icon-only controls should include localized `tooltip` or `semanticLabel` text.

## Formatting

- Dates, numbers, and currencies should continue to use `intl`.
- Pass `Localizations.localeOf(context).toLanguageTag()` to date or number formatters where the visible output should follow the app locale.
- Do not translate stored enum storage values. Localize only the UI label shown to the user.

## Verification

After localization changes, the parent verification pass should run:

```text
flutter gen-l10n
flutter analyze
flutter test
```

Manual RTL review should include Home, Add Expense, Expenses, Reports, Categories, Settings, AI Assistant, and Free/Premium on a small phone viewport.
