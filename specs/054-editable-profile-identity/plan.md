# Implementation Plan: Editable Profile Identity

**Branch**: `054-editable-profile-identity` | **Date**: 2026-05-19 | **Spec**: `specs/054-editable-profile-identity/spec.md`  
**Input**: Settings profile section currently shows Firebase UID and has no edit-name flow.

## Summary

Move the visible account identity in Settings from raw `UserSettings.userId` to authenticated `AppUser` profile data, then add a Settings edit flow that updates Firebase Auth display name through `AuthRepository` and refreshes `AuthBloc` so Home and Settings stay aligned.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Firebase Auth, Flutter Bloc, existing `AuthRepository`, `AuthBloc`, `SettingsCubit`, l10n  
**Storage**: Firebase Auth display name; no Firestore schema change required for visible name  
**Testing**: Flutter unit/widget tests for AuthBloc, SettingsCubit/UI profile section  
**Target Platform**: Android release APK and existing Flutter targets  
**Project Type**: Mobile app  
**Performance Goals**: Profile update completes promptly and does not reload the whole app  
**Constraints**: Widgets must not import Firebase Auth directly; UID remains immutable; no email/password management in this plan  
**Scale/Scope**: Auth repository interface, AuthBloc event/state, Settings profile UI, l10n, focused tests

## Constitution Check

- Spec Kit artifacts created before implementation.
- Auth state remains owned by `AuthRepository` and `AuthBloc`.
- Widgets do not import Firebase Auth or provider-specific auth APIs.
- Settings remains Bloc-based and localized.

**Gate Status**: PASS.

## Current Code Findings

- `SettingsScreen` profile card displays `settings.userId` as the account subtitle.
- `UserSettings` is a preferences document and should not own user-visible auth identity.
- `AppUser` already contains `displayName`, `email`, `photoUrl`, and `userId`.
- `AuthRepository` does not yet expose a display-name update method.
- `AuthAuthenticated.props` currently omits `displayName`, so profile-only state refreshes may not rebuild reliably.

## Project Structure

```text
specs/054-editable-profile-identity/
|-- spec.md
|-- plan.md
|-- tasks.md
`-- checklists/requirements.md

packages/expense_repository/lib/src/models/app_user.dart
packages/expense_repository/lib/src/auth/auth_repository.dart
packages/expense_repository/lib/src/auth/firebase_auth_repository.dart
lib/screens/auth/blocs/auth_bloc/
lib/screens/settings/views/settings_screen.dart
lib/screens/settings/widgets/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
test/auth/
test/settings/
```

**Structure Decision**: Keep profile persistence in auth repository code and keep Settings UI as a consumer of `AuthBloc` plus `SettingsCubit`.

## Implementation Notes

- Add `AuthRepository.updateDisplayName(String displayName)` returning refreshed `AppUser`.
- Add `AuthDisplayNameUpdateRequested` event and a profile-saving state or reuse `AuthLoading` carefully without logging the user out visually.
- Include `displayName` and `photoUrl` in `AuthAuthenticated.props`.
- Refactor profile card into a small widget to keep `settings_screen.dart` readable.
- Show UID as `Account ID` in a secondary row/copy affordance, not as the profile title.
- Keep avatar upload, email edit, and account deletion deferred.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/auth test/settings --reporter expanded --concurrency=1 --timeout 45s
flutter analyze --no-pub
```

## Deferred Items To Keep In Mind

Production Firebase provider setup and Google sign-in smoke testing remain in `docs/implementation_plans/deferred-and-advanced-work.md`. Full account management beyond display name should be handled later.

## Complexity Tracking

No constitution violations. The plan deliberately avoids adding a second profile source in Firestore to prevent Home and Settings identity drift.
