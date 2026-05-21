# Tasks: Settings Live Refresh Stability

**Input**: `specs/058-settings-live-refresh-stability/spec.md` and `plan.md`

## Phase 1: Reproduction And Inspection

- [X] T001 Inspect Settings widget tree and identify the source of excessive blank bottom scroll in `lib/screens/settings/views/settings_screen.dart`.
- [X] T002 Inspect Settings sections for invisible placeholders or reserved heights in `lib/screens/settings/widgets/`.
- [X] T003 Inspect `ProfileIdentitySection`, `AuthBloc`, and `FirebaseAuthRepository` display-name update flow.
- [X] T004 Inspect hardcoded Settings strings in `lib/screens/settings/widgets/` and map them to ARB keys.

## Phase 2: Tests First

- [X] T005 [P] Add a Settings widget test that scrolls to the bottom and verifies final content appears without excessive blank area in `test/settings/settings_screen_widget_test.dart`.
- [X] T006 [P] Add a Settings widget/localization test that switches language and verifies touched Settings labels update immediately in `test/settings/settings_screen_widget_test.dart`.
- [X] T007 [P] Add AuthBloc tests for successful display-name update, repository failure, and stream convergence after update in `test/auth/auth_bloc_test.dart`.
- [X] T008 [P] Add a profile Settings widget test that display name/email is primary and account id is secondary/copy-only in `test/settings/settings_screen_widget_test.dart`.

## Phase 3: Layout Fix

- [X] T009 Remove or collapse the Settings widget/section causing empty bottom scroll in `lib/screens/settings/views/settings_screen.dart` or the responsible child section.
- [X] T010 Add safe-area-aware bottom padding only where needed, without reserving a full blank screen.

## Phase 4: Localization Live Refresh

- [X] T011 Add missing Settings strings to `lib/l10n/app_en.arb`.
- [X] T012 Add Arabic translations for the same keys in `lib/l10n/app_ar.arb`.
- [X] T013 Replace hardcoded text in `NotificationSettingsSection` with `context.l10n` strings.
- [X] T014 Replace hardcoded text in `AiSettingsSection` with `context.l10n` strings.
- [X] T015 Replace hardcoded text in `MonetizationSettingsSection` with `context.l10n` strings.
- [X] T016 Run `flutter gen-l10n`.
- [X] T017 Ensure Settings language preference save triggers immediate `AppLanguageCubit` update and current Settings rebuild.

## Phase 5: Display Name Refresh

- [X] T018 Update `AuthBloc` display-name update handling so success emits an authenticated/updated user state that remains visible without restart.
- [X] T019 Update repository error handling in `FirebaseAuthRepository` if it returns a stale failure after Firebase accepted the display-name update.
- [X] T020 Update `ProfileIdentitySection` snackbar handling so it does not show a failure after state has converged to the requested display name.
- [X] T021 Ensure Home receives the updated auth user after name change without app restart.

## Phase 6: Verification

- [X] T022 Run `flutter gen-l10n`.
- [X] T023 Run targeted Settings/Auth/localization tests.
- [X] T024 Run `flutter analyze --no-pub`.
- [ ] T025 Manually verify release APK Settings scroll, language switch, and display-name update on Android.

## Done Criteria

- Settings does not scroll into a large blank grey area.
- Settings language changes apply immediately to touched Settings labels.
- Display-name update is visible immediately and does not show a false permission error.
