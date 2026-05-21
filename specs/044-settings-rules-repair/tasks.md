# Tasks: Settings Rules Repair

**Input**: Design documents from `specs/044-settings-rules-repair/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Confirm the existing mismatch and capture the current settings shape.

- [X] T001 Inspect `packages/expense_repository/lib/src/entities/user_settings_entity.dart` and list every key emitted by `UserSettingsEntity.toDocument()`.
- [X] T002 Inspect `firestore.rules` `validSettings(data, userId)` and compare allowed/required fields against T001.
- [X] T003 Inspect `functions/test/firestoreRules.rules.ts` and identify all existing settings allow/deny assertions.

## Phase 2: Foundational

**Purpose**: Update tests before changing the rules.

- [X] T004 [P] Update `functions/test/firestoreRules.rules.ts` `validSettings()` fixture to include `languagePreference`, `onboardingCompleted`, `onboardingVersion`, `guidedTourCompletedVersion`, `guidedTourSkippedVersion`, and `guidedTourLastStepId`.
- [X] T005 [P] Add rules deny test in `functions/test/firestoreRules.rules.ts` for unsupported `languagePreference`.
- [X] T006 [P] Add rules deny test in `functions/test/firestoreRules.rules.ts` for negative `onboardingVersion`.
- [X] T007 [P] Add rules deny test in `functions/test/firestoreRules.rules.ts` for negative `guidedTourCompletedVersion` or `guidedTourSkippedVersion`.
- [X] T008 [P] Add rules deny test in `functions/test/firestoreRules.rules.ts` for writing `users/user-a/settings/not-profile`.
- [ ] T009 Run `cd functions; npm run test:rules` and confirm the updated valid settings fixture fails before the rules are fixed.

## Phase 3: User Story 1 - Save Current Settings Shape (Priority: P1)

**Goal**: Current app settings writes succeed for the authenticated owner.

**Independent Test**: Rules emulator accepts the updated `validSettings()` fixture for `users/user-a/settings/profile`.

- [X] T010 [US1] Add `validLanguagePreference(value)` helper to `firestore.rules`.
- [X] T011 [US1] Expand `firestore.rules` `validSettings` `hasOnly` list with current settings fields.
- [X] T012 [US1] Expand `firestore.rules` `validSettings` `hasAll` list with required current settings fields except nullable optional fields.
- [X] T013 [US1] Add `languagePreference`, `onboardingCompleted`, onboarding version, guided tour version, and nullable last-step validation to `firestore.rules`.
- [ ] T014 [US1] Run `cd functions; npm run test:rules` and confirm the valid current settings write passes.

## Phase 4: User Story 2 - Reject Malformed Settings Fields (Priority: P1)

**Goal**: New fields are accepted only in the valid app-owned format.

**Independent Test**: Each malformed mutation added in T005-T008 is denied.

- [X] T015 [US2] Review every malformed settings test in `functions/test/firestoreRules.rules.ts` and ensure it asserts `assertFails`.
- [X] T016 [US2] Add a deny assertion in `functions/test/firestoreRules.rules.ts` for `guidedTourLastStepId` with a non-string non-null value.
- [ ] T017 [US2] Run `cd functions; npm run test:rules` and confirm all settings allow/deny cases pass.

## Phase 5: User Story 3 - Make Rules Verification Part Of The Baseline (Priority: P2)

**Goal**: Rules verification is visible and hard to skip accidentally.

**Independent Test**: A developer can find and run the rules-specific command without confusing it with `npm test`.

- [X] T018 [US3] Update `functions/package.json` with a clear aggregate or documented script only if it preserves the current fast `npm test` behavior.
- [X] T019 [US3] Update `README.md` or `docs/firebase/` with the exact rules command: `cd functions; npm run test:rules`.
- [X] T020 [US3] Mention emulator prerequisites and the difference between `npm test` and `npm run test:rules` in the same doc section.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T021 Run `cd functions; npm test`.
- [ ] T022 Run `cd functions; npm run test:rules`.
- [X] T023 Run `flutter analyze --no-pub`.
- [X] T024 Update `specs/044-settings-rules-repair/tasks.md` checkboxes as tasks complete.

Note: Verification tasks T009, T014, T017, T021, T022, and T023 were intentionally left unchecked because this worker was instructed not to run build, test, emulator, Flutter, npm, Firebase, or verification commands.

## Dependencies & Execution Order

- T001-T003 before test edits.
- T004-T009 before rules implementation.
- US1 and US2 are both P1 and must land together.
- US3 can follow after the rules behavior is stable.

## Implementation Strategy

MVP is US1 plus US2: current valid settings writes pass and malformed settings writes fail. US3 is a verification visibility improvement and can be completed immediately after the behavior fix.
