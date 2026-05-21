# Tasks: Guided Product Tour

**Input**: Design documents from `specs/043-guided-product-tour/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`, completed Plans 041 and 042

**Tests**: Include tests because this plan changes first-run UX, persistence, overlays, and navigation guidance.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Locate existing UI targets and define stable target ids before adding overlay logic.

- [X] T001 Inspect Home AI/action icons in `lib/screens/home/views/main_screen.dart` to identify the exact AI Assistant target and avoid wrapping the wrong icon.
- [X] T002 Inspect Add Expense, Budget, Reports, Categories, Settings, and Free/Premium navigation targets in `lib/screens/` and `lib/monetization/` because every tour step needs a stable visible target or safe fallback.
- [X] T003 Inspect Settings screen structure in `lib/screens/settings/views/settings_screen.dart` because replay-tour control belongs there.
- [X] T004 [P] Add guided-tour localization keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` for every step title/body and controls: Next, Back, Skip, Done, Replay Tour.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add reusable tour state, persistence, and target registration.

- [X] T005 Add guided tour fields to `UserSettings` in `packages/expense_repository/lib/src/models/user_settings.dart` or create a focused settings sub-model if cleaner, because completion/skipped version must persist per user.
- [X] T006 Update `UserSettingsEntity` in `packages/expense_repository/lib/src/entities/user_settings_entity.dart` to parse and write tour completion/skipped version with safe defaults for legacy users.
- [X] T007 [P] Create `GuidedTourStep` and `GuidedTourState` models in `lib/guided_tour/models/` with stable ids and version constants because steps need deterministic definitions.
- [X] T008 [P] Create `GuidedTourController` or Cubit in `lib/guided_tour/cubit/` to own active step, next/back/skip/done, replay mode, missing target handling, and persistence calls.
- [X] T009 [P] Create `SpotlightTarget` registration widget in `lib/guided_tour/widgets/spotlight_target.dart` so feature screens can mark target widgets without embedding overlay code.
- [X] T010 [P] Add model/entity tests in `test/guided_tour/guided_tour_state_test.dart` and `test/repository/user_settings_entity_test.dart` for version logic, legacy defaults, skip, completion, and replay.

**Checkpoint**: Tour state can be persisted and targets can be registered.

---

## Phase 3: User Story 1 - Spotlight The AI Assistant (Priority: P1) MVP

**Goal**: Show the first spotlight on the AI Assistant icon after setup.

**Independent Test**: User reaches Home after setup and sees AI spotlight with dim overlay and no provider calls.

### Tests for User Story 1

- [X] T011 [P] [US1] Add overlay widget tests in `test/guided_tour/tour_overlay_test.dart` proving dim background, highlighted target, controls, and reduced-motion behavior render correctly.
- [X] T012 [P] [US1] Add Home guided-tour tests in `test/home/home_navigation_test.dart` or `test/guided_tour/home_tour_test.dart` proving AI spotlight auto-shows only after onboarding completion and not for completed/skipped tour versions.
- [X] T013 [P] [US1] Add no-provider-call test in `test/guided_tour/home_tour_test.dart` proving showing and advancing the AI spotlight does not call `AiService`, `AiGatewayClient`, ads, purchases, speech, camera, or notifications.

### Implementation for User Story 1

- [X] T014 [US1] Create `TourOverlay` in `lib/guided_tour/widgets/tour_overlay.dart` with dim layer, target cutout/highlight, subtle pulse animation, reduced-motion mode, localized card, and controls.
- [X] T015 [US1] Wrap the AI Assistant icon/button in `MainScreen` with `SpotlightTarget(targetId: ai_assistant)` so the controller can locate the correct UI element.
- [X] T016 [US1] Add a guided-tour host near authenticated app/Home scaffolding so overlay appears above content but below system navigation and does not require every screen to manage it.
- [X] T017 [US1] Configure the first `GuidedTourStep` for AI Assistant in `lib/guided_tour/guided_tour_steps.dart` with title/body explaining text, voice, preview, and confirmation.
- [X] T018 [US1] Persist skip/done for current tour version through `SettingsRepository` after user taps Skip or finishes the last step.

**Checkpoint**: The AI spotlight tour MVP works independently.

---

## Phase 4: User Story 2 - Teach Core Finance Workflows (Priority: P2)

**Goal**: Add spotlight steps for manual entry, AI preview confirmation, budget, reports, categories, settings, and Free/Premium.

**Independent Test**: Run full tour and verify each step either highlights a target or skips safely.

### Tests for User Story 2

- [X] T019 [P] [US2] Add guided-tour sequence tests in `test/guided_tour/guided_tour_cubit_test.dart` proving step order, next/back behavior, missing target skip, and route hints.
- [X] T020 [P] [US2] Add Home/settings integration tests in `test/guided_tour/home_tour_test.dart` proving manual entry, budget, reports, categories, settings, and Free/Premium target ids are registered.
- [X] T021 [P] [US2] Add RTL/small-screen overlay tests in `test/guided_tour/tour_overlay_test.dart` proving tooltip placement remains visible in Arabic.

### Implementation for User Story 2

- [X] T022 [US2] Register `SpotlightTarget` ids around manual Add Expense, budget, reports, categories, settings, and Free/Premium buttons/cards in their existing screen files.
- [X] T023 [US2] Add `GuidedTourStep` definitions for manual expense, AI preview confirmation, budget, reports, categories, settings, and Free/Premium in `lib/guided_tour/guided_tour_steps.dart`.
- [X] T024 [US2] Implement missing-target fallback in `GuidedTourController` so off-screen or unavailable targets are skipped or deferred with no crash.
- [X] T025 [US2] Add optional route/scroll preparation hooks where needed so a step can navigate to a target screen without losing tour state.
- [X] T026 [US2] Ensure step copy emphasizes product truths: manual entry works without AI, AI requires confirmation, budgets power alerts/advice, reports summarize real data, categories can be edited, and Free plan has limits.

**Checkpoint**: Core workflow tour teaches the main app loop.

---

## Phase 5: User Story 3 - Replay Or Dismiss Guidance (Priority: P3)

**Goal**: Let users replay the tour later and avoid annoying repeated auto-show.

**Independent Test**: Complete/skip tour, restart, verify no auto-show; replay from Settings works.

### Tests for User Story 3

- [X] T027 [P] [US3] Add persistence tests in `test/guided_tour/guided_tour_cubit_test.dart` proving completed/skipped versions suppress auto-show and replay overrides suppression for current session.
- [X] T028 [P] [US3] Add Settings widget test in `test/settings/settings_screen_widget_test.dart` proving Replay Tour is visible and starts the tour.

### Implementation for User Story 3

- [X] T029 [US3] Add Replay Tour action to Settings in `lib/screens/settings/views/settings_screen.dart` or a dedicated settings section using localized text.
- [X] T030 [US3] Add replay entry point in `GuidedTourController` so replay starts at first step without modifying completed/skipped state until user completes or skips again.
- [X] T031 [US3] Add Android back-button handling in `TourOverlay` so users can step back or dismiss safely without corrupting persisted state.
- [X] T032 [US3] Add tour version constant and comparison rules so future versions can show new guidance without replaying old completed steps unnecessarily.

**Checkpoint**: Guidance is helpful, replayable, and not repetitive.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T033 [P] Add accessibility semantics to `TourOverlay` and spotlight controls so screen readers announce title, body, step count, and controls.
- [X] T034 [P] Add golden/screenshot-friendly widget states if the existing test setup supports them; otherwise add layout assertions for small viewport and RTL.
- [X] T035 Run `flutter gen-l10n` after ARB changes.
- [X] T036 Run `flutter analyze` and targeted tests from `quickstart.md`.
- [X] T037 Run full `flutter test --reporter expanded --concurrency=1 --timeout 45s` if shared scaffolding changed.
- [X] T038 Update `.specify/memory/constitution.md` with guided-tour conventions, target registration rules, and verification baseline after implementation.
- [X] T039 Update `docs/implementation_plans/deferred-and-advanced-work.md` with any manual UX QA or future remote-config rollout items discovered during implementation.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup**: No dependencies.
- **Foundational**: Depends on setup and completed onboarding state from Plan 042.
- **US1**: MVP and should be implemented first.
- **US2**: Depends on overlay/controller from US1.
- **US3**: Depends on persistence from foundational and overlay/controller from US1.
- **Polish**: Depends on selected user stories.

### Parallel Opportunities

- T004, T007, T008, T009, T010, T011, T012, T013, T019, T020, T021, T027, T028, T033, and T034 can be parallelized with non-overlapping ownership.

## Implementation Strategy

1. Add persistent versioned tour state.
2. Deliver AI Assistant spotlight as MVP.
3. Add core workflow steps.
4. Add replay/suppression behavior.
5. Verify accessibility, RTL, and no-service-call guarantees.
