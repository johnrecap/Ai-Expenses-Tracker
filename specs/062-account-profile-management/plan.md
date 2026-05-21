# Implementation Plan: Account Profile Management

**Branch**: `062-account-profile-management` | **Date**: 2026-05-19 | **Spec**: `specs/062-account-profile-management/spec.md`  
**Input**: Feature specification from `specs/062-account-profile-management/spec.md`

## Summary

Expand the current editable profile section into a full Account/Profile management surface. The app supports both Google and email/password accounts, stores the visible name as app-local profile data independent from Google profile data, excludes profile photos, and provides an in-app account deletion flow with explicit warning and confirmation.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Firebase Auth through existing `AuthRepository`, existing `SettingsRepository`, Flutter Bloc, `flutter/services` clipboard  
**Storage**: Firebase Auth identity metadata; app-local profile display name in user-owned app data; user-owned Firestore data under `users/{userId}`  
**Testing**: Auth repository fakes, settings/profile fakes, AuthBloc/AccountProfileCubit tests, Settings/Account widget tests  
**Target Platform**: Flutter mobile app, primarily Android  
**Project Type**: Mobile app  
**Performance Goals**: Account/Profile screen should load from existing auth/settings state without blocking app startup.  
**Constraints**: No widget-level Firebase Auth imports; no account deletion without explicit confirmation; no orphaning user data; no profile-photo/avatar work; Google profile data must not overwrite the app-local display name after user edit.  
**Scale/Scope**: One authenticated user's profile and user-scoped app data.

## Constitution Check

- Spec Kit artifacts live under `specs/062-account-profile-management/`: PASS.
- Auth work goes through `AuthRepository` and `AuthBloc`: PASS.
- App-local profile name goes through app-owned settings/profile repository boundary: PASS.
- User-owned data remains isolated under `users/{userId}`: PASS.
- Firestore/Firebase deletion behavior is explicit and testable: PASS.
- All user-facing strings use ARB localization: PASS.
- Premium, ads, AI, and finance calculations are not changed by this plan: PASS.

## Project Structure

### Documentation

```text
specs/062-account-profile-management/
|-- spec.md
|-- plan.md
`-- tasks.md

docs/implementation_plans/deferred-and-advanced-work.md
```

### Source Code

```text
packages/expense_repository/lib/src/models/app_user.dart
packages/expense_repository/lib/src/models/user_settings.dart
packages/expense_repository/lib/src/entities/user_settings_entity.dart
packages/expense_repository/lib/src/auth/auth_repository.dart
packages/expense_repository/lib/src/auth/firebase_auth_repository.dart
packages/expense_repository/lib/src/settings_repo.dart
packages/expense_repository/lib/src/firebase_settings_repo.dart

lib/screens/auth/blocs/auth_bloc/
lib/screens/settings/widgets/profile_identity_section.dart
lib/screens/settings/views/settings_screen.dart
lib/screens/account/
lib/screens/account/cubit/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
firestore.rules
functions/test/firestoreRules.rules.ts
```

### Tests

```text
test/auth/
test/settings/
test/account/
test/repository/
test/helpers/fake_repositories.dart
```

## Complexity Tracking

Account deletion is the highest-risk area. Deletion must be implemented behind a service with fake tests before any real Firebase delete calls. Avatar/photo work is explicitly out of scope. App-local display name storage may require `UserSettings` entity/model updates and Firestore rules/test updates.

