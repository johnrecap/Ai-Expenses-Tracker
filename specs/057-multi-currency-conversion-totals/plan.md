# Implementation Plan: Multi-Currency Conversion Totals

**Branch**: `057-multi-currency-conversion-totals` | **Date**: 2026-05-19 | **Spec**: `specs/057-multi-currency-conversion-totals/spec.md`

## Summary

Introduce user-managed exchange rates and use them in Home dashboard totals so supported non-base currency expenses can be converted into the base currency instead of being ignored with `+ other`.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, `expense_repository`, SettingsRepository, HomeSummaryCalculator  
**Storage**: Extend `UserSettings` / `UserSettingsEntity` with conversion rate data under `users/{userId}/settings/profile`  
**Testing**: Repository entity tests, SettingsCubit tests, HomeSummaryCalculator tests, Settings widget tests, Home widget/navigation tests as needed  
**Primary Files**:

- `packages/expense_repository/lib/src/models/user_settings.dart`
- `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
- `packages/expense_repository/lib/src/settings_repo.dart`
- `packages/expense_repository/lib/src/firebase_settings_repo.dart`
- `firestore.rules`
- `functions/test/firestoreRules.rules.ts`
- `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart`
- `lib/screens/settings/widgets/currency_settings_section.dart`
- `lib/screens/home/models/home_summary.dart`
- `lib/screens/home/services/home_summary_calculator.dart`
- `lib/screens/home/views/main_screen.dart`
- `test/home/home_summary_calculator_test.dart`
- `test/settings/settings_cubit_test.dart`
- `test/repository/user_settings_entity_test.dart`

## Implementation Approach

1. Add a small money conversion model/service owned by the app layer, not the UI.
2. Persist rates in user settings as a normalized map keyed by uppercase currency code.
3. Treat base currency as rate `1.0`; never require the user to enter it.
4. Use conversion in `HomeSummaryCalculator` for spending, top category, and budget remaining.
5. Keep original expense rows unchanged so users still see the actual entered currency.
6. Update Home labels from vague `+ other` to converted/unconverted breakdown.
7. Update Firestore rules/tests to allow the new settings field.

## UX Rules

- Settings should show exchange rates only for supported non-base currencies.
- The copy must explain rates as "1 [currency] = X [base]".
- Invalid or missing rates should not block saving unrelated settings, but missing rates should be visible and should not be used for math.
- Home should prefer a clean total first and a small status line/badge for unconverted currencies.

## Risks

- A user-entered stale rate can produce stale totals. This is acceptable for MVP and must be made visible with "last updated" where practical.
- Firestore rules must be updated with the new settings field or settings saves may fail.
- Changing UserSettings serialization must preserve older users with no rate data.

## Verification

```text
flutter test --no-pub test/home/home_summary_calculator_test.dart test/settings/settings_cubit_test.dart test/repository/user_settings_entity_test.dart --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

If Firestore rules are changed:

```text
cd functions && npm run test:rules
```

## Deferred Items To Keep In Mind

Live exchange-rate sync, provider selection, historical conversion rates, and applying conversion across reports/export/category budgets remain deferred until a dedicated production-ready currency plan is approved.
