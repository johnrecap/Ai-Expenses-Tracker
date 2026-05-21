# Feature Specification: Authentication And User-Scoped Data

**Feature Branch**: `002-auth-user-scoped-data`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Can Register And Login (P1)
As a new user, I can create an account and sign in so my expenses are private.

**Acceptance Criteria**
- Register creates a Firebase Auth user.
- Login authenticates with email and password.
- Logout returns the user to the auth screen.

### User Story 2 - User Sees Only Their Data (P1)
As an authenticated user, I only read and write my own expenses and categories.

**Acceptance Criteria**
- Expenses are stored under `users/{userId}/expenses`.
- Categories are stored under `users/{userId}/categories`.
- Repository calls require the current authenticated user.

### User Story 3 - Auth State Controls Routing (P1)
As a user, I should not enter the home screen when signed out.

**Acceptance Criteria**
- Signed-out users see login/register.
- Signed-in users see home.
- Auth state changes update the app route.

## Functional Requirements

- Add `AuthRepository` and Firebase implementation.
- Add `AuthBloc`.
- Add login, register, reset password, and auth gate screens.
- Add user-scoped Firestore paths.
- Add Firestore rules if rules are tracked in repo.
- Decide whether old global data needs migration.

## Out Of Scope

- Social login.
- Email verification requirement.
- Production migration script unless real data exists.

## Success Metrics

- Two users cannot see each other's data.
- Auth states are covered by tests.

## Detailed Requirements And Edge Cases

- The app must never create `FirebaseExpenseRepo` without an authenticated `userId` after this feature.
- Signed-out state must not briefly show Home after splash.
- Login/register screens must validate empty fields locally before calling Firebase.
- Firebase errors must be shown as user-readable messages, not raw stack traces.
- Existing global Firestore collections must not be extended for production user data.
- If migration is not implemented, the decision must be documented explicitly.
