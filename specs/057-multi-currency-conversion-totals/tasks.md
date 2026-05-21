# Tasks: Multi-Currency Conversion Totals

**Input**: `specs/057-multi-currency-conversion-totals/spec.md` and `plan.md`

## Phase 1: Setup And Current Behavior

- [X] T001 Inspect `lib/screens/home/services/home_summary_calculator.dart` and confirm current same-currency-only aggregation behavior.
- [X] T002 Inspect `packages/expense_repository/lib/src/models/user_settings.dart` and `packages/expense_repository/lib/src/entities/user_settings_entity.dart` to identify backward-compatible settings extension points.
- [X] T003 Inspect `firestore.rules` and `functions/test/firestoreRules.rules.ts` for settings allowlist changes required by conversion rates.

## Phase 2: Tests First

- [X] T004 [P] Add `UserSettings` entity tests for missing rates, valid rates, uppercase normalization, and backward-compatible empty-map defaults in `test/repository/user_settings_entity_test.dart`.
- [X] T005 [P] Add SettingsCubit tests for saving/updating conversion rates without changing language or base currency in `test/settings/settings_cubit_test.dart`.
- [X] T006 [P] Add HomeSummaryCalculator tests for base USD + EGP converted total, unconverted missing rate warning, converted top category, and budget remaining in `test/home/home_summary_calculator_test.dart`.
- [X] T007 [P] Add Firestore rules test coverage for valid and invalid conversion-rate settings payloads in `functions/test/firestoreRules.rules.ts`.

## Phase 3: Settings Data Model

- [X] T008 Add a normalized conversion-rate field to `UserSettings` in `packages/expense_repository/lib/src/models/user_settings.dart`.
- [X] T009 Add serialization/deserialization for conversion rates in `packages/expense_repository/lib/src/entities/user_settings_entity.dart`.
- [X] T010 Extend `SettingsRepository` with conversion-rate update behavior in `packages/expense_repository/lib/src/settings_repo.dart`.
- [X] T011 Implement Firebase settings persistence for conversion rates in `packages/expense_repository/lib/src/firebase_settings_repo.dart`.
- [X] T012 Update `firestore.rules` to accept the new settings conversion-rate shape while rejecting non-numeric, zero, negative, or unexpected nested fields.

## Phase 4: Conversion Service And Home Summary

- [X] T013 Create a focused conversion helper/service for base-currency totals under `lib/screens/home/services/` or a shared `lib/services/money/` path.
- [X] T014 Update `HomeSummary` in `lib/screens/home/models/home_summary.dart` with converted/unconverted currency metadata.
- [X] T015 Update `HomeSummaryCalculator` to use conversion rates for monthly spending, top category, and budget remaining.
- [X] T016 Update `lib/screens/home/views/main_screen.dart` to remove vague `+ other` wording and show converted/unconverted status clearly.

## Phase 5: Settings UI

- [X] T017 Update `SettingsCubit` to validate and save conversion rates in `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart`.
- [X] T018 Update `CurrencySettingsSection` to display editable rates for supported non-base currencies in `lib/screens/settings/widgets/currency_settings_section.dart`.
- [X] T019 Add localized strings for exchange-rate labels, errors, and helper text in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- [X] T020 Run `flutter gen-l10n` after ARB changes.

## Phase 6: Verification

- [X] T021 Run targeted Flutter tests for repository/settings/home conversion behavior.
- [X] T022 Run Firestore rules tests if rules changed.
- [X] T023 Run `flutter analyze --no-pub`.
- [ ] T024 Manually inspect Home with base USD, EGP expense, and configured EGP rate on a small Android viewport.

## Done Criteria

- Home converted totals include non-base expenses only when a valid rate exists.
- Missing rates are explicit and never silently guessed.
- Original expense rows still show original amount and currency.
- Settings saves do not fail under Firestore rules after adding conversion rates.
