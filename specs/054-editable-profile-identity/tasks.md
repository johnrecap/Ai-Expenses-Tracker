# Tasks: Editable Profile Identity

**Input**: Design documents from `specs/054-editable-profile-identity/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

- [X] T001 Inspect current Settings profile usage in `lib/screens/settings/views/settings_screen.dart`.
- [X] T002 [P] Inspect auth identity model and repository files in `packages/expense_repository/lib/src/models/app_user.dart` and `packages/expense_repository/lib/src/auth/`.
- [X] T003 [P] Inspect Home display-name fallback in `lib/screens/home/views/home_screen.dart`.

---

## Phase 2: Foundational

- [X] T004 Add `updateDisplayName(String displayName)` to `packages/expense_repository/lib/src/auth/auth_repository.dart`.
- [X] T005 Implement Firebase Auth display-name update and reload in `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart`.
- [X] T006 Include `displayName` and `photoUrl` in `AuthAuthenticated.props` in `lib/screens/auth/blocs/auth_bloc/auth_state.dart`.
- [X] T007 Add localized strings for profile name, edit action, account ID, copy action, validation, save success, and save failure in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

---

## Phase 3: User Story 1 - See Human Profile Identity (Priority: P1)

**Goal**: Settings and Home show a readable profile identity instead of the Firebase UID.

**Independent Test**: Widget test Settings with a fake authenticated user and verify display name/email are primary while UID is secondary.

- [X] T008 [P] [US1] Create a shared profile display helper or widget model in `lib/screens/settings/widgets/profile_identity_section.dart`.
- [X] T009 [US1] Replace the current Settings profile `ListTile` in `lib/screens/settings/views/settings_screen.dart` with the new profile section that reads `AuthBloc`.
- [X] T010 [US1] Keep UID visible only as secondary `Account ID` detail in `lib/screens/settings/widgets/profile_identity_section.dart`.
- [X] T011 [P] [US1] Add Settings widget tests for display name, email fallback, and UID fallback in `test/settings/settings_screen_widget_test.dart`.

---

## Phase 4: User Story 2 - Edit Display Name From Settings (Priority: P1)

**Goal**: User can edit display name and see it reflected without sign-out.

**Independent Test**: AuthBloc fake repository updates display name and Settings UI reflects the updated state.

- [X] T012 [US2] Add `AuthDisplayNameUpdateRequested` event in `lib/screens/auth/blocs/auth_bloc/auth_event.dart`.
- [X] T013 [US2] Handle display-name update in `lib/screens/auth/blocs/auth_bloc/auth_bloc.dart` using `AuthRepository.updateDisplayName`.
- [X] T014 [US2] Add edit-name dialog or bottom sheet in `lib/screens/settings/widgets/profile_identity_section.dart`.
- [X] T015 [US2] Validate blank and overlong names before dispatching the auth update in `lib/screens/settings/widgets/profile_identity_section.dart`.
- [X] T016 [P] [US2] Add AuthBloc tests for display-name update success and failure in `test/auth/auth_bloc_test.dart`.
- [X] T017 [P] [US2] Add Settings widget test for edit-name validation and save dispatch in `test/settings/settings_screen_widget_test.dart`.

---

## Phase 5: User Story 3 - Keep Technical Account Data Accessible But Secondary (Priority: P2)

**Goal**: UID remains available for support without looking like the user name.

**Independent Test**: Profile section exposes account ID secondary detail and optional copy feedback.

- [X] T018 [US3] Add account ID copy affordance using Flutter clipboard APIs in `lib/screens/settings/widgets/profile_identity_section.dart`.
- [X] T019 [P] [US3] Add widget test for account ID secondary display/copy feedback in `test/settings/settings_screen_widget_test.dart`.

---

## Phase 6: Verification

- [X] T020 Run `flutter gen-l10n`.
- [X] T021 Run targeted auth/settings tests.
- [X] T022 Run `flutter analyze --no-pub`.

## Dependencies & Execution Order

- T004-T007 block profile UI implementation.
- US1 and US2 can be developed in parallel after auth repository method exists.
- US3 depends on the profile section widget from US1.

## Notes

- Do not store display name in `UserSettings` unless implementation discovers Firebase Auth cannot refresh reliably.
- Do not implement email change, password change, photo upload, or account deletion in this plan.
