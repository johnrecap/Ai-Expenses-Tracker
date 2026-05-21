# Feature Specification: Account Profile Management

**Feature Branch**: `062-account-profile-management`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User asked for account/profile management with Google and email/password support, no profile photos, in-app account deletion, warning-only deletion copy, and an app-local display name independent from Google profile data.

## Product Decisions Locked For This Plan

- **Provider scope**: The app supports both Google and email/password accounts.
- **Profile photo scope**: No profile photo upload, no gallery/camera permission, and no preset avatar selector.
- **Deletion policy**: Users can delete their account from inside the app after explicit warning/confirmation.
- **Support flow**: The deletion flow uses warning text only; no support-contact step is required.
- **Display name source**: The visible app name must be app-local and independent from Google profile display name.

## User Scenarios & Testing

### User Story 1 - View Complete Account Details Safely (Priority: P1)

Signed-in users must have a clear Account/Profile screen where app-local display name, email, sign-in provider, and secondary account ID are visible without exposing technical IDs as the main identity.

**Why this priority**: Plan 054 fixed Firebase UID prominence, but the app still lacks a full provider-aware account management surface.

**Independent Test**: Pump Account/Profile settings with fake Google and email/password users and verify the correct visible identity, provider labels, email, and account ID copy affordance.

**Acceptance Scenarios**:

1. **Given** a Google user with an app-local display name, **When** Account/Profile opens, **Then** the screen shows the app-local display name as primary and does not overwrite it with Google profile name.
2. **Given** an email/password user, **When** Account/Profile opens, **Then** the screen shows email identity and email/password account actions.
3. **Given** the user copies account ID, **When** the action completes, **Then** localized confirmation appears.

---

### User Story 2 - Manage App-Local Display Name (Priority: P1)

Users must be able to edit the app-visible name without changing or depending on their Google profile name.

**Why this priority**: The user explicitly wants the app name to be independent from Google profile data.

**Independent Test**: Fake settings/profile repository updates the app-local display name; Home, Settings, and Account/Profile refresh immediately while Firebase Auth display name remains unchanged.

**Acceptance Scenarios**:

1. **Given** the user saves a valid display name, **When** the update succeeds, **Then** Home and Account/Profile show the new app-local name immediately.
2. **Given** Firebase/Google profile has a different display name, **When** auth state refreshes, **Then** the app-local display name remains the primary name.
3. **Given** the update fails due to settings/Firestore permissions or network, **When** the user returns to the screen, **Then** the previous profile remains visible and a localized error appears.

---

### User Story 3 - Manage Email/Password Account Actions (Priority: P2)

Email/password users should be able to request password reset and update email when Firebase allows it.

**Why this priority**: Account management is incomplete if email users cannot recover or update credentials.

**Independent Test**: Fake auth repository supports password reset and email update outcomes; UI handles success, failure, unavailable-provider, and reauth-needed states.

**Acceptance Scenarios**:

1. **Given** an email/password user, **When** they request password reset, **Then** the app sends through `AuthRepository` and shows localized feedback.
2. **Given** an email update requires recent login, **When** Firebase returns reauth-needed, **Then** the app shows a safe reauthentication path instead of a raw error.
3. **Given** a Google-only user, **When** Account/Profile opens, **Then** email/password-only actions are hidden or disabled with clear copy.

---

### User Story 4 - Delete Account And User Data With Explicit Warning (Priority: P2)

Users must have a safe in-app path to delete their account and user-owned app data.

**Why this priority**: Public apps often require account/data deletion flows for store and privacy readiness.

**Independent Test**: Repository fakes verify delete flow requires warning confirmation, reauthentication when needed, and calls user-scoped data deletion before auth deletion.

**Acceptance Scenarios**:

1. **Given** the user starts account deletion, **When** they have not confirmed the warning, **Then** no data is deleted.
2. **Given** deletion is confirmed and reauth passes, **When** the flow completes, **Then** user-scoped Firestore data and auth account deletion are requested through service/repository boundaries.
3. **Given** deletion fails partway, **When** the app reports failure, **Then** it clearly tells the user what remains and does not pretend deletion succeeded.

## Edge Cases

- Firebase may require recent sign-in for email/password changes and account deletion.
- Google provider accounts may not allow email/password actions.
- Offline profile updates must fail safely and not show fake success.
- Deleting auth before deleting user data can orphan Firestore data; the sequence must be explicit.
- Account deletion must not delete shared/static app data or other users' data.
- Google profile refreshes must not overwrite the app-local display name.

## Requirements

### Functional Requirements

- **FR-001**: Account/Profile management MUST go through `AuthRepository`, `AuthBloc`, `SettingsRepository`, and dedicated service/repository boundaries; widgets must not call Firebase APIs directly.
- **FR-002**: Account details MUST show app-local readable identity first and technical account ID only as secondary support detail.
- **FR-003**: Display-name updates MUST persist as app-local profile data independent from Google profile display name.
- **FR-004**: Display-name updates MUST refresh Home, Settings, and Account/Profile without app restart.
- **FR-005**: If no app-local display name exists, UI MAY fall back to Firebase Auth display name, then email, then localized generic user label.
- **FR-006**: Password reset MUST be available for email/password users.
- **FR-007**: Email update MUST handle reauthentication-needed failures with clear UI if Firebase allows the provider action.
- **FR-008**: Provider-specific actions MUST be hidden or explained when unavailable.
- **FR-009**: Account deletion MUST require explicit warning/confirmation and reauthentication when required.
- **FR-010**: User data deletion MUST only target authenticated user-owned paths under `users/{userId}`.
- **FR-011**: Avatar/photo support MUST NOT be implemented in this plan.
- **FR-012**: All Account/Profile strings MUST be localized in English and Arabic.

### Key Entities

- **AppUser**: Authenticated account identity with UID, email, Firebase/Auth display name, provider metadata, photo URL, and creation time.
- **AppLocalProfile**: App-owned profile data containing the user's local display name independent from Google profile data.
- **SettingsRepository**: Existing app-owned user settings/profile boundary used to persist local display name unless implementation creates a narrower profile repository.
- **AuthRepository**: Boundary for Firebase Auth provider metadata, password reset, email update, reauthentication, and account deletion.
- **AccountProfileCubit/Bloc**: UI state coordinator for account/profile actions and failure handling.
- **AccountDeletionService**: Orchestrates user-scoped data deletion and auth deletion.
- **UserDataDeletionPlan**: List of Firestore user-owned collections/documents to delete.

## Success Criteria

- **SC-001**: Account/Profile screen shows provider-aware details and actions without exposing UID as primary identity.
- **SC-002**: App-local display-name changes reflect immediately in Home, Settings, and Account/Profile in tests.
- **SC-003**: Google profile refresh does not overwrite app-local display name.
- **SC-004**: Password reset and email-update failure states are covered by tests.
- **SC-005**: Account deletion flow cannot run without explicit confirmation and is covered by service tests.
- **SC-006**: `flutter analyze --no-pub` and targeted auth/account/settings tests pass.

## Assumptions

- Plan 054 completed Firebase display-name editing and account ID copy; this plan changes the source of visible display name to app-owned profile data.
- Firebase Auth remains the source of sign-in identity and provider metadata.
- Firestore user data stays under `users/{userId}/...`.
- Profile photo and avatar management are intentionally out of scope.

