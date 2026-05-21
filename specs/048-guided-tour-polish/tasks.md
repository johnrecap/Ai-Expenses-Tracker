# Tasks: Guided Tour Polish

**Input**: Design documents from `specs/048-guided-tour-polish/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Map current guided tour metadata to runtime behavior.

- [X] T001 Inspect `lib/guided_tour/models/guided_tour_step.dart` fields and list runtime consumers.
- [X] T002 Inspect `lib/guided_tour/cubit/guided_tour_cubit.dart` target selection and persistence behavior.
- [X] T003 Inspect `lib/guided_tour/widgets/tour_overlay.dart` off-screen target handling and animations.
- [X] T004 Inspect `lib/guided_tour/guided_tour_steps.dart` for steps that require navigation, scrolling, or optional skipping.
- [X] T005 Inspect existing tests under `test/guided_tour`, `test/home`, and `test/settings`.

## Phase 2: Foundational

**Purpose**: Write failing tests for the identified gaps.

- [X] T006 [P] Add a widget/cubit test in `test/guided_tour/` proving an off-screen required target is prepared or skipped intentionally.
- [X] T007 [P] Add a test in `test/guided_tour/` proving every remaining `GuidedTourStep` metadata field is consumed by runtime behavior.
- [X] T008 [P] Add or update persistence tests for complete, skip, replay, and last-step settings fields.
- [X] T009 [P] Add reduced-motion overlay test to confirm pulse animation stops.

## Phase 3: User Story 1 - Tour Steps Reach Their Targets Reliably (Priority: P1)

**Goal**: Off-screen or route-dependent tour targets are visible or safely skipped.

**Independent Test**: The off-screen target test from T006 passes.

- [X] T010 [US1] Implement a target preparation mechanism in `lib/guided_tour/` for route or scroll readiness.
- [X] T011 [US1] Wire preparation from `GuidedTourHost` or target registry without putting overlay logic into feature widgets.
- [X] T012 [US1] Update affected Home/Settings target registrations to use the preparation mechanism. No Home/Settings registration changes were required.
- [X] T013 [US1] Ensure required missing targets do not leave the overlay in an unusable null-target state.

## Phase 4: User Story 2 - Tour Metadata Is Either Used Or Removed (Priority: P1)

**Goal**: No dead tour model fields remain.

**Independent Test**: Static/test coverage proves remaining fields are consumed.

- [X] T014 [US2] If `routeName` remains, implement and test its preparation behavior; otherwise remove it from `GuidedTourStep`, steps, docs, and tests.
- [X] T015 [US2] If `allowTargetTap` remains, implement and test safe hit testing; otherwise remove it from `GuidedTourStep`, steps, docs, and tests.
- [X] T016 [US2] Update `specs/043-guided-product-tour/tasks.md` or follow-up notes only if the old task status was misleading. No Plan 043 status update was required.

## Phase 5: User Story 3 - Tour UX Is Safe Across Accessibility And RTL (Priority: P2)

**Goal**: Accessibility and RTL behavior are covered.

**Independent Test**: Targeted tests cover reduced motion, persistence, and Arabic layout smoke.

- [X] T017 [US3] Add Arabic small-viewport smoke coverage for `TourOverlay`.
- [X] T018 [US3] Verify back button behavior skips or backs up according to current state.
- [X] T019 [US3] Verify Settings replay starts without resetting completion incorrectly.
- [X] T020 [US3] Confirm no tour step triggers AI, ads, purchases, permissions, camera, speech, or notifications.

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T021 Run `flutter analyze --no-pub`.
- [ ] T022 Run `flutter test --no-pub test/guided_tour --reporter expanded --concurrency=1 --timeout 45s`.
- [ ] T023 Run relevant Home/Settings targeted tests.
- [X] T024 Update `docs/implementation_plans/deferred-and-advanced-work.md` if real-device tour QA remains pending or if old failure notes are superseded.
- [X] T025 Update `specs/048-guided-tour-polish/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T005 before test writing.
- T006-T009 before implementation.
- US1 and US2 are both P1 and should complete together.
- US3 follows once target behavior is stable.

## Implementation Strategy

Prefer implementing the smallest preparation mechanism that makes current steps honest. Remove unused metadata if it does not serve a concrete current tour step.
