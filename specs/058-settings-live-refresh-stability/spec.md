# Feature Specification: Settings Live Refresh Stability

**Feature Branch**: `058-settings-live-refresh-stability`
**Created**: 2026-05-19
**Status**: Draft
**Input**: User reports three Settings bugs: excessive blank scrolling at the bottom, language changes leave some text untranslated until restart, and display-name changes show a permission error even though the name appears after app restart.

## User Scenarios & Testing

### User Story 1 - Settings Scroll Ends At Real Content (Priority: P1)

As a user, I want Settings to stop scrolling after the last visible section, so I do not land on an empty grey area and think content failed to load.

**Independent Test**: Open Settings on a phone-sized viewport, scroll to the bottom, and verify the final visible section is Support/last content with normal bottom padding only.

### User Story 2 - Language Switch Refreshes Current UI Immediately (Priority: P1)

As a bilingual user, I want Settings text to switch immediately when I choose Arabic or English, so I do not need to close and reopen the app.

**Independent Test**: Open Settings in English, switch to Arabic, and verify all Settings sections visible after scrolling use Arabic labels without app restart.

### User Story 3 - Display Name Update Is Immediate And Honest (Priority: P1)

As a user, I want changing my display name to update the Settings and Home UI immediately or show a real failure, so I do not see a permission error for a change that actually saved.

**Independent Test**: Change display name from Settings, remain in the app, and verify Settings and Home show the new name without restart and without an incorrect permission toast.

## Requirements

### Functional Requirements

- **FR-001**: Settings MUST not reserve large invisible space below the final visible section.
- **FR-002**: Any ad, monetization, loading, or placeholder widget inside Settings MUST collapse when it has no visible content.
- **FR-003**: All Settings section titles, subtitles, tiles, errors, and snackbars touched by this plan MUST use `AppLocalizations`.
- **FR-004**: Changing language preference MUST update `AppLanguageCubit` and rebuild currently mounted Settings text immediately.
- **FR-005**: Settings MUST not rely on app restart to show the selected language.
- **FR-006**: Display-name update MUST emit a success state with the updated user when Firebase/AuthRepository confirms the change.
- **FR-007**: If Firebase emits the updated user after a transient repository error, the UI MUST converge to the updated name and avoid leaving a stale failure state.
- **FR-008**: Settings profile section MUST show display name or email as primary identity; raw UID should be secondary/copy-only, not the main human name.
- **FR-009**: Permission or auth errors MUST be mapped to actionable localized messages.

### Key Entities

- **Settings UI Section**: A visible grouped section on the Settings screen.
- **Language Preference State**: The app-wide selected language preference that drives `MaterialApp.locale`.
- **Auth Profile Update State**: The transient and final states for display-name changes.

## Success Criteria

- **SC-001**: On a 720x1600 phone viewport, Settings bottom scroll has no more than normal safe-area/bottom padding after the final section.
- **SC-002**: Switching English to Arabic changes all Settings labels covered by this plan within the same session.
- **SC-003**: A successful display-name update appears in Settings and Home without app restart.
- **SC-004**: Widget tests cover the scroll boundary, language refresh, and profile update state transition.

## Assumptions

- This plan fixes Settings-related live refresh bugs only.
- Broader full-app localization remains in the deferred localization backlog.
- Raw account id remains available for support/copy, but should not be presented as the user's name.

## Out of Scope

- Email change, password change, photo upload, account deletion, or provider linking.
- Full localization of every non-Settings screen.
- Redesigning the entire Settings page.
