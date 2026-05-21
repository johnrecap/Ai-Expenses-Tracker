# Feature Specification: Account Deletion Reauth Hardening

**Feature Branch**: `067-account-deletion-reauth-hardening`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a full plan for account deletion, reauthentication, privacy trust, and store readiness.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sensitive Actions Reauthenticate (Priority: P1)

As a signed-in user, I need sensitive account actions to ask me to reauthenticate when Firebase requires it.

**Why this priority**: Firebase can reject delete/update actions if the login is not recent.

**Independent Test**: Fake repositories simulate recent-login-required for Google and email/password accounts.

**Acceptance Scenarios**:

1. **Given** an email/password user needs reauth, **When** they delete account, **Then** the app asks for password and retries safely.
2. **Given** a Google user needs reauth, **When** they delete account, **Then** the app uses the Google provider path and retries safely.

---

### User Story 2 - Account Deletion Is Clear And Final (Priority: P1)

As a user, I need account deletion to show a clear warning and remove my user-owned app data.

**Why this priority**: Deletion is a privacy and store-trust requirement.

**Independent Test**: A fake deletion service verifies warning, confirmation, data deletion, auth deletion, success, and failure states.

**Acceptance Scenarios**:

1. **Given** the user confirms deletion, **When** deletion succeeds, **Then** the app signs out and shows a clear completion state.
2. **Given** Firestore deletion fails, **When** the user tries to delete, **Then** Firebase Auth deletion is not silently completed while app data remains orphaned.

---

### User Story 3 - Provider-Specific Actions Are Honest (Priority: P2)

As a user with Google or email/password login, I need only supported account actions to appear.

**Why this priority**: Unsupported actions create confusion and support requests.

**Independent Test**: Provider fixtures render correct available/unavailable actions.

**Acceptance Scenarios**:

1. **Given** a Google-only user, **When** Account/Profile opens, **Then** password-only actions are hidden or explained.
2. **Given** an email/password user, **When** Account/Profile opens, **Then** password reset/update actions are available.

## Edge Cases

- User cancels Google reauth.
- Wrong password during reauth.
- Network failure during data deletion.
- Partial Firestore deletion failure.
- User signs out from another device mid-flow.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sensitive account actions MUST handle recent-login-required.
- **FR-002**: Account deletion MUST require explicit warning and confirmation.
- **FR-003**: Account deletion MUST attempt user-scoped app data removal before or atomically with Firebase Auth deletion according to the documented policy.
- **FR-004**: Provider-specific actions MUST be hidden or explained when unavailable.
- **FR-005**: No profile photo/avatar upload scope may be added.
- **FR-006**: Success and failure states MUST be localized and understandable.

### Key Entities

- **ReauthRequest**: Provider, required credential input, retry state, and result.
- **AccountDeletionResult**: App data deletion status, auth deletion status, error, and recovery guidance.
- **ProviderActionAvailability**: Supported account actions for the current provider.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of fake reauth outcomes are covered for Google and email/password providers.
- **SC-002**: User cannot delete account without seeing and confirming a destructive warning.
- **SC-003**: Partial deletion failures produce a clear recovery message.
- **SC-004**: Real-device Firebase deletion smoke is documented before public release.

## Assumptions

- Both Google and email/password accounts remain supported.
- Display name remains app-local and independent from Google profile.
- No profile photo feature is in scope.

