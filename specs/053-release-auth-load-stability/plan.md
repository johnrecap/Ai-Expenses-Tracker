# Implementation Plan: Release Auth Load Stability

**Branch**: `053-release-auth-load-stability` | **Date**: 2026-05-18 | **Spec**: `specs/053-release-auth-load-stability/spec.md`  
**Input**: Release bug report after Google sign-in and first-run reminder setup.

## Summary

Add runtime resilience for the release app when Firebase production indexes lag behind local code, and make onboarding notification scheduling bounded so permission/plugin issues cannot leave the user on an infinite loading button.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, Cloud Firestore, flutter_local_notifications  
**Storage**: Existing user-scoped Firestore paths under `users/{userId}`  
**Testing**: Flutter unit/widget tests, `flutter analyze --no-pub`, release APK build after verification  
**Target Platform**: Android release APK, with existing cross-platform Flutter code preserved  
**Project Type**: Mobile app  
**Performance Goals**: Home should reach success/error state promptly; onboarding notification setup should stop waiting within 6 seconds  
**Constraints**: No Firebase production mutation from code; no data migration; keep fallback read-only and user-scoped  
**Scale/Scope**: Expense repository reads, Home expense Bloc state, onboarding reminder finish path

## Constitution Check

- Spec Kit artifacts created before implementation.
- Repository pattern remains the boundary for Firestore reads.
- Notification scheduling stays behind `NotificationScheduler`.
- No widget directly imports Firestore or notification plugin APIs.

**Gate Status**: PASS.

## Root Cause Evidence

- User-provided deployed rules are broad `users/{userId}/{document=**}` rules, so the Home failure is unlikely to be a current production rules rejection.
- `FirebaseExpenseRepo.watchRecentExpensePage()` orders by `date` and `expenseId`; `firestore.indexes.json` declares the matching composite index, which implies production must deploy indexes separately.
- A missing deployed index can fail both old and new accounts before data volume matters, matching the user's follow-up that the same connection message appears on the new account.
- `OnboardingCubit.finish()` waits for `_syncOptionalReminders()` without timeout; a plugin permission/schedule Future that never returns keeps `isSaving` true.

## Project Structure

```text
specs/053-release-auth-load-stability/
|-- spec.md
|-- plan.md
|-- tasks.md
`-- checklists/requirements.md

packages/expense_repository/lib/src/firebase_expense_repo.dart
lib/screens/onboarding/blocs/onboarding_cubit.dart
test/repository/expense_repository_operations_test.dart
test/onboarding/onboarding_cubit_test.dart
docs/implementation_plans/deferred-and-advanced-work.md
```

**Structure Decision**: Keep the Firestore fallback in the repository package and keep onboarding timeout logic in the existing Cubit/service boundary.

## Implementation Notes

- Prefer the composite indexed query first to preserve the Plan 051 scaling path when indexes are deployed.
- If the composite query fails with a Firestore failed-precondition/missing-index style error, fall back to a conservative `date`-ordered user-scoped read and local page construction.
- The fallback is a release safety net and may read more documents than the indexed path; it should not replace the deferred production deployment task.
- Add a small timeout around optional reminder sync and treat timeout like permission denial: disable reminders and complete onboarding with warning.

## Verification

```text
flutter test --no-pub test/onboarding/onboarding_cubit_test.dart --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/home test/repository --reporter expanded --concurrency=1 --timeout 45s
flutter analyze --no-pub
flutter build apk --release
```

## Deferred Items To Keep In Mind

The existing production blocker remains relevant: deploy Firestore rules/indexes and run a Firebase smoke test with a real user. This plan adds app-side resilience but does not deploy Firebase configuration.

## Complexity Tracking

No constitution violations. The fallback intentionally trades read efficiency for release survivability only when the primary indexed query fails.
