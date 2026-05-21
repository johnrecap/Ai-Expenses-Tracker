# Feature Specification: Google Sign-In Authentication

**Feature Branch**: `025-google-sign-in-auth`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found that email/password auth exists, but direct Google Sign-In is missing from the app UI and repository layer.

## User Scenarios & Testing

### User Story 1 - Sign In With Google (Priority: P1)

A user taps a Google button on the login screen and enters the app using their Google account.

**Why this priority**: The Firebase console has Google provider enabled and users expect direct Google sign-in without creating a separate password.

**Independent Test**: On Android with Firebase configured, tap Google sign-in and confirm authenticated home state appears.

**Acceptance Scenarios**:

1. **Given** Google provider is enabled in Firebase and SHA fingerprints are configured, **When** the user taps "Continue with Google" and selects an account, **Then** the app signs them in and shows their own data.
2. **Given** the user cancels account selection, **When** the flow returns to the app, **Then** no account is created and the login screen remains usable.

---

### User Story 2 - Same User Data Ownership (Priority: P2)

A Google-authenticated user sees the same user-scoped Firestore structure as email/password users.

**Why this priority**: Data isolation is a core project rule. Auth provider must not affect where expenses, categories, settings, budgets, or AI logs are stored.

**Independent Test**: Sign in with Google and create an expense; confirm it is written under `users/{uid}/expenses`.

**Acceptance Scenarios**:

1. **Given** a Google user is authenticated, **When** repositories are created, **Then** they use the Firebase Auth UID exactly like email/password users.
2. **Given** two Google users sign in on the same device at different times, **When** each views Home, **Then** each only sees their own Firestore subcollections.

---

### User Story 3 - Clear Auth Errors (Priority: P3)

Users see meaningful messages for setup or provider failures instead of generic "try again later".

**Why this priority**: During Firebase setup, the most common failures are missing SHA fingerprints, disabled provider, wrong package name, or network errors.

**Independent Test**: Force common failure codes and confirm the UI shows actionable messages.

**Acceptance Scenarios**:

1. **Given** Firebase Google provider is not correctly configured, **When** Google sign-in fails, **Then** the app shows a setup-related error message and does not leave the user on a blank/loading state.
2. **Given** network is unavailable, **When** Google sign-in fails, **Then** the app shows a network-specific message and keeps email/password login available.

### Edge Cases

- A user may have the same email registered with email/password and Google; account linking behavior must be explicit.
- Android SHA-1/SHA-256 fingerprints must match the installed build.
- Web/iOS sign-in may need additional client IDs and should fail gracefully until configured.

## Requirements

### Functional Requirements

- **FR-001**: Login screen MUST include a visible Google sign-in action.
- **FR-002**: Auth repository MUST expose a provider-level Google sign-in method behind its interface.
- **FR-003**: Auth Bloc/Cubit MUST represent Google sign-in loading, success, cancellation, and failure states.
- **FR-004**: Google sign-in MUST use Firebase Auth UID for all user-scoped repositories.
- **FR-005**: The app MUST not write auth provider secrets or OAuth client secrets into source code.
- **FR-006**: Error handling MUST distinguish cancellation, network failure, provider misconfiguration, disabled account, and generic unknown errors where possible.
- **FR-007**: Documentation MUST list Firebase setup requirements: package name, `google-services.json`, SHA-1/SHA-256, enabled Google provider, support email, and platform caveats.

### Key Entities

- **Auth Provider Result**: The authenticated user or a cancellation/failure result from Google sign-in.
- **User Identity**: Firebase Auth UID, display name, email, and optional photo URL.
- **Firebase Setup Requirement**: External console configuration needed before Google sign-in works on a device.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A correctly configured Android build signs in with Google in under 30 seconds.
- **SC-002**: Cancellation returns to login without creating or modifying user data.
- **SC-003**: New Google users can create and view expenses under their own `users/{uid}` path.
- **SC-004**: Setup-related auth failures display a specific message instead of only a generic failure toast.

## Assumptions

- Firebase Authentication remains the auth backend.
- Android package name remains `com.saeeddevstudio.ai_expenses_tracker`.
- Existing email/password auth remains available.
- Store release signing fingerprints will be configured separately from debug fingerprints.
