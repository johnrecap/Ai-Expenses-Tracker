# Implementation Plan: Account Deletion Reauth Hardening

**Branch**: `067-account-deletion-reauth-hardening` | **Date**: 2026-05-20 | **Spec**: `specs/067-account-deletion-reauth-hardening/spec.md`

## Summary

Harden Account/Profile sensitive actions by adding provider-aware reauthentication UX, deletion sequencing, localized user feedback, fake coverage, and a real Firebase smoke checklist. This builds on Plan 062 instead of reworking profile identity.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing `AuthRepository`, `FirebaseAuthRepository`, `SettingsRepository`, `AccountProfileCubit`, account services  
**Storage**: Firebase Auth plus user-owned Firestore data under `users/{userId}`  
**Testing**: Fake repository/cubit/widget tests plus manual Firebase smoke  
**Target Platform**: Android primarily  
**Project Type**: Mobile account/privacy workflow  
**Performance Goals**: Reauth/delete flows should remain responsive and show progress  
**Constraints**: No direct Firebase Auth imports in widgets; no profile photo scope; no silent orphan data  
**Scale/Scope**: One authenticated user account

## Constitution Check

- Auth work goes through repository/bloc/service boundaries: PASS.
- User-owned data remains scoped under `users/{userId}`: PASS.
- Destructive deletion requires explicit confirmation: PASS.
- No avatar/photo scope: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/auth/
packages/expense_repository/lib/src/settings_repo.dart
lib/screens/account/
lib/screens/settings/widgets/profile_identity_section.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
test/account/
test/auth/
test/settings/
docs/qa/production-device-qa.md
docs/implementation_plans/deferred-and-advanced-work.md
```

## Implementation Strategy

1. Lock provider/action states with fake tests.
2. Add reauth service contracts and UI states.
3. Wire email/password and Google reauth paths through repository boundaries.
4. Harden deletion sequencing and error states.
5. Add real Firebase smoke instructions for final validation.

## Current Flow And Deletion Audit

- Account/Profile is owned by `AccountProfileCubit`, `AccountProfileService`,
  `AccountDeletionService`, and `AuthRepository`; widgets do not import Firebase
  Auth or Google Sign-In directly.
- Password reset, email update, password reauth, Google reauth, Firebase Auth
  deletion, and local display-name updates stay behind repository/service
  boundaries.
- `UserDataDeletionPlan.standard` deletes all current user-owned Firestore
  collections declared in `firestore.rules`: `expenses`, `categories`,
  `budgets`, `category_budgets`, `recurring_expenses`, `saving_goals`,
  `ai_actions`, `category_aliases`, and `settings/profile`, then attempts the
  parent `users/{userId}` document.
- Deletion sequencing remains data-first, then Firebase Auth account deletion.
  If user data deletion fails, Auth deletion is not attempted. If Auth deletion
  fails after data deletion, the user sees an auth-deletion failure and can
  reauthenticate/retry without a false success state.
- The client-side deletion loop deletes collection documents in batches of 100.
  It does not provide server-side recursive deletion guarantees for future
  nested subcollections; production release still needs real Firebase smoke
  validation and may need a trusted backend deletion function if nested data is
  added.

## Risks

- Recursive Firestore deletion from client can be limited or slow. Mitigation: document backend deletion requirement if client-only deletion is insufficient.
- Google reauth is provider/platform dependent. Mitigation: fake tests plus real-device QA.

## Deferred Items Considered

Relevant deferred items include Plan 062 backend hooks, account deletion end-to-end validation, Firebase Auth reauthentication, and user-scoped recursive data deletion.
