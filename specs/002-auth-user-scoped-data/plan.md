# Implementation Plan: Authentication And User-Scoped Data

## Technical Context

Firebase Auth is already a dependency in the repository package but is not integrated. Firestore currently uses global `expenses` and `categories` collections.

## Architecture

Add `AuthRepository` and `AuthBloc`. Introduce `AuthGate` at app entry. Refactor Firestore repository paths to `users/{userId}/...`.

## Files

- Create: `packages/expense_repository/lib/src/auth/auth_repository.dart`
- Create: `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart`
- Create: `packages/expense_repository/lib/src/models/app_user.dart`
- Create: `lib/screens/auth/blocs/auth_bloc/*`
- Create: `lib/screens/auth/views/login_screen.dart`
- Create: `lib/screens/auth/views/register_screen.dart`
- Create: `lib/screens/auth/views/auth_gate.dart`
- Modify: `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- Modify: `lib/app_view.dart`
- Modify: `lib/screens/splash_screen.dart`

## Data Model

Add `AppUser`. Add or infer `userId` for expenses and categories. Preferred Firestore layout: user subcollections.

## Risks

- Existing global Firestore data may need migration.
- Auth routing must avoid using context after async navigation from splash.

## Verification

- Auth bloc tests.
- Repository path tests with fake user id.
- Manual login/register/logout flow.

## Detailed Execution Guidance

- Build repository and Bloc before UI so screens do not depend on Firebase directly.
- AuthGate should replace timer-based splash navigation as the route authority.
- User-scoped repository construction should happen only after authenticated user state exists.
- Firestore path migration must be treated as a data ownership change, not a UI tweak.
- Keep global collections read-only/legacy unless an explicit migration is approved.
