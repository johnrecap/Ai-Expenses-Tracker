# Implementation Plan: Google Sign-In Authentication

**Branch**: `025-google-sign-in-auth` | **Date**: 2026-05-17 | **Spec**: `specs/025-google-sign-in-auth/spec.md`  
**Input**: Add direct Google Sign-In while preserving the current AuthRepository/AuthBloc architecture.

## Summary

Add Google Sign-In as a first-class auth provider through the existing auth repository and Bloc flow. The UI gains a Google button, but all user data continues to use the Firebase Auth UID and existing user-scoped repository creation.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Firebase Auth, likely `google_sign_in`, existing `flutter_bloc` auth flow  
**Storage**: Firestore user subcollections remain unchanged  
**Testing**: Auth repository tests with fakes, AuthBloc tests, login widget tests, Android device smoke test  
**Target Platform**: Android first, with iOS/web guarded or documented  
**Project Type**: Flutter mobile app with multi-platform folders  
**Performance Goals**: Sign-in completes within 30 seconds under normal network conditions  
**Constraints**: No OAuth secrets in Flutter code; no direct Firebase Auth imports in widgets; no data outside `users/{uid}`  
**Scale/Scope**: Login/register UI, auth repository package, AuthBloc, Firebase setup docs

## Constitution Check

- Widgets must not import `firebase_auth` directly.
- Auth state remains owned by `lib/screens/auth/blocs/auth_bloc/`.
- Repositories must be created only after authenticated UID exists.
- No provider secrets may be stored in source.
- Google Sign-In does not change Firestore data ownership rules.

## Project Structure

```text
lib/screens/auth/
|-- blocs/auth_bloc/
|-- views/login_screen.dart
`-- widgets/

packages/expense_repository/lib/src/auth/
|-- auth_repository.dart
`-- firebase_auth_repository.dart

android/app/
|-- google-services.json
`-- build.gradle.kts or build.gradle
```

**Structure Decision**: Provider logic belongs in the auth repository package, Bloc dispatches the action, and UI only triggers Bloc events.

## Implementation Notes

- Add the dependency only if it is not already present.
- Use the existing package style for auth exceptions and user model mapping.
- Do not auto-link accounts unless a spec explicitly defines linking UX.
- The first implementation can support Android only if other platforms are documented as pending.

## External Setup Checklist

- Enable Google provider in Firebase Authentication.
- Set public app name and support email in Firebase provider settings.
- Add Android SHA-1 and SHA-256 for the debug/release keystore being used.
- Download the updated `google-services.json`.
- Rebuild and reinstall the app after config changes.
