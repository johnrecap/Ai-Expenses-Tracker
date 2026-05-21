# Implementation Plan: Settings Live Refresh Stability

**Branch**: `058-settings-live-refresh-stability` | **Date**: 2026-05-19 | **Spec**: `specs/058-settings-live-refresh-stability/spec.md`

## Summary

Fix the Settings experience regressions reported on device: remove excessive blank scroll area, make language changes update visible Settings text immediately, and make display-name updates reflect correctly without false permission errors or app restart.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, Firebase Auth repository abstraction, AppLocalizations  
**Storage**: No schema change expected  
**Testing**: Settings widget tests, AuthBloc tests, localization tests  
**Primary Files**:

- `lib/screens/settings/views/settings_screen.dart`
- `lib/screens/settings/widgets/*_settings_section.dart`
- `lib/screens/settings/widgets/profile_identity_section.dart`
- `lib/screens/auth/blocs/auth_bloc/auth_bloc.dart`
- `packages/expense_repository/lib/src/firebase_auth_repo.dart`
- `lib/app_view.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- `test/settings/settings_screen_widget_test.dart`
- `test/auth/auth_bloc_test.dart`
- `test/localization/app_language_preference_test.dart`

## Implementation Approach

1. Reproduce/inspect Settings layout and identify which section or placeholder creates bottom blank space.
2. Collapse invisible ad/loading/placeholder space when no visible Settings content is available.
3. Convert remaining Settings hardcoded strings in touched sections to ARB entries.
4. Ensure Settings listens to `AppLanguageCubit`/`SettingsCubit` in a way that rebuilds the current screen immediately after language selection.
5. Rework display-name update flow so success/failure reflects the final auth repository state, not a stale intermediate state.
6. Keep account id visible as support/copy metadata only.

## Known Suspects From Current Code

- `SettingsScreen` uses a `ListView` with many sections and external sections that may reserve invisible layout.
- `NotificationSettingsSection`, `AiSettingsSection`, and `MonetizationSettingsSection` still contain hardcoded English strings.
- `ProfileIdentitySection` listens for `AuthProfileUpdated` and `AuthProfileUpdateFailure`, but may show a failure even when the auth stream later provides the updated user.
- `AuthBloc` emits `AuthProfileUpdated` but must remain compatible with `AuthUserChanged` stream updates.

## UX Rules

- Language choice should feel instant in Settings.
- A UID should never be the top visible "name" if email or display name is available.
- Error snackbars should be localized and should not contradict the final visible state.
- Bottom padding should be enough for gesture navigation, not a screen-length blank area.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/settings/settings_screen_widget_test.dart test/auth/auth_bloc_test.dart test/localization/app_language_preference_test.dart --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

Manual device check:

```text
Build/open release APK, open Settings, scroll to bottom, switch EN/AR, update display name, return Home.
```

## Deferred Items To Keep In Mind

The broader localization pass for all screens remains deferred. This plan localizes Settings text touched by the fix and prevents restart-only language refresh for the Settings path.
