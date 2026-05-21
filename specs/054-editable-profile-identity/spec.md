# Feature Specification: Editable Profile Identity

**Feature Branch**: `054-editable-profile-identity`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User report that Settings shows the Firebase UID at the top of the profile section and provides no way to edit the visible user name.

## User Scenarios & Testing

### User Story 1 - See Human Profile Identity (Priority: P1)

As a signed-in user, I want Settings and Home to show my readable name or email instead of exposing the Firebase UID as the main account label.

**Why this priority**: The current Settings screen shows a technical identifier, which looks broken and is not useful for normal users.

**Independent Test**: Open Settings with an authenticated user that has display name, email, and UID values; verify the name is primary, email is secondary, and UID is not the prominent label.

**Acceptance Scenarios**:

1. **Given** a signed-in user with display name `movie test`, **When** Settings opens, **Then** the profile section shows `movie test` as the primary identity.
2. **Given** a signed-in user with no display name but with email, **When** Settings opens, **Then** the profile section shows the email as the primary identity.
3. **Given** a signed-in user with only a UID, **When** Settings opens, **Then** the profile section shows a friendly fallback and only exposes the UID as a secondary account ID detail.

---

### User Story 2 - Edit Display Name From Settings (Priority: P1)

As a signed-in user, I want to edit my display name from Settings and see the new name on Home without signing out.

**Why this priority**: Users should be able to personalize the app identity after Google sign-in or email sign-up.

**Independent Test**: Use a fake auth repository, submit a new display name from Settings, and verify Auth state and Settings UI update.

**Acceptance Scenarios**:

1. **Given** Settings is open, **When** the user taps Edit profile and saves a valid name, **Then** the app persists the display name and refreshes visible identity.
2. **Given** the user enters a blank name, **When** they try to save, **Then** the app shows validation and does not persist the blank name.
3. **Given** profile update fails, **When** the user saves, **Then** the app restores the previous profile state and shows a clear error.

---

### User Story 3 - Keep Technical Account Data Accessible But Secondary (Priority: P2)

As a support/debug user, I may still need the account ID, but it should not dominate the normal profile UI.

**Why this priority**: UID can help support, but normal users should not see it as their name.

**Independent Test**: Verify the profile section includes a secondary account ID row or copy action without replacing the visible profile name.

**Acceptance Scenarios**:

1. **Given** Settings profile section is visible, **When** the user expands or taps account details, **Then** the UID can be copied or read as account ID.

### Edge Cases

- Very long names must not overflow cards or buttons on small Android screens.
- Updating display name must not alter email, UID, settings, currency, language, or onboarding state.
- Google accounts may already have a display name; the app should preserve it until the user edits it.
- Offline/profile update failures must not leave Home and Settings disagreeing about the user name.

## Requirements

### Functional Requirements

- **FR-001**: Settings MUST use authenticated user profile data for the profile section instead of showing `UserSettings.userId` as the primary label.
- **FR-002**: Home and Settings MUST use the same display-name fallback order: display name, email, then a generic localized user label.
- **FR-003**: Users MUST be able to update their display name from Settings.
- **FR-004**: Display name updates MUST go through the existing auth/repository boundary, not direct widget access to Firebase APIs.
- **FR-005**: Display name validation MUST reject blank names and names longer than a defined UI-safe limit.
- **FR-006**: The account UID MAY remain available as a secondary account ID for support, but it MUST NOT be the main profile text.
- **FR-007**: Profile labels, edit actions, validation messages, and success/failure messages MUST be localized in English and Arabic.

### Key Entities

- **AppUser**: Authenticated profile identity containing UID, email, display name, photo URL, and creation time.
- **AuthRepository**: Profile update boundary that persists display name changes.
- **AuthBloc**: App-level auth state that must refresh after a display name update.
- **Settings Profile Section**: The UI section that presents and edits user-visible identity.

## Success Criteria

### Measurable Outcomes

- **SC-001**: In Settings, the Firebase UID no longer appears as the primary profile label in any authenticated state.
- **SC-002**: A user can update display name from Settings in under 30 seconds.
- **SC-003**: Home reflects the updated display name without sign-out/sign-in.
- **SC-004**: Profile update tests cover success, blank-name validation, and repository failure.

## Assumptions

- The app should update Firebase Auth display name as the source of visible account identity.
- Full account management such as email change, password change, avatar upload, and account deletion is out of scope for this plan.
- Existing Firebase Auth provider configuration remains unchanged.
