# Tasks: Docs And Specs Alignment

**Input**: Design documents from `specs/046-docs-specs-alignment/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Build an evidence list before editing docs.

- [X] T001 Inspect `README.md` for starter-template or stale feature claims.
- [X] T002 Inspect `pubspec.yaml` description.
- [X] T003 Inspect `docs/project_analysis_and_ai_roadmap.md` for historical claims that now conflict with current code.
- [X] T004 Inspect `specs/043-guided-product-tour/spec.md` and `specs/043-guided-product-tour/tasks.md` status.
- [X] T005 Inspect `docs/implementation_plans/deferred-and-advanced-work.md` guided tour/Home verification entry.

## Phase 2: Foundational

**Purpose**: Decide how each stale item is categorized.

- [X] T006 Create a short local checklist in `specs/046-docs-specs-alignment/tasks.md` notes or commit message mapping each stale item to update, historical label, deferred, or no change.
- [X] T007 Confirm no production setup blocker is removed from `docs/implementation_plans/deferred-and-advanced-work.md`.

### Stale Item Mapping

- `README.md`: update. Replaced old lightweight project overview, roadmap, screenshot, and clone instructions with current app scope, architecture, setup, verification guidance, and production boundaries.
- `pubspec.yaml`: update. Replaced default Flutter description with app-specific package metadata.
- `docs/project_analysis_and_ai_roadmap.md`: historical label. Added notice and annotations around stale current-state, verification, and testing sections without deleting historical analysis.
- `specs/043-guided-product-tour/spec.md`: update. Changed status from Draft to implemented with manual real-device QA deferred.
- `specs/043-guided-product-tour/tasks.md`: no change. Tasks already show implementation and verification complete.
- `docs/implementation_plans/deferred-and-advanced-work.md`: update. Marked Plan 041 guided-tour/Home failures as superseded by the Plan 043 verification baseline.
- `specs/README.md`: no change. Existing historical task-status guidance already tells workers to classify old unchecked tasks through cleanup notes and the deferred backlog.
- Production setup blockers: deferred. Keystore, release-device QA, Firebase smoke, AdMob, purchase verification, observability, and Play Store readiness items remain in the deferred backlog.

## Phase 3: User Story 1 - Make Public Project Docs Match The Current App (Priority: P1)

**Goal**: README and package metadata describe the current app.

**Independent Test**: Searches for starter-template text return no results in entry-point docs.

- [X] T008 [US1] Replace generic README overview in `README.md` with the current expense tracker scope.
- [X] T009 [US1] Add or update README setup commands for Flutter, functions tests, rules tests, and AI gateway tests.
- [X] T010 [US1] Add README notes for Firebase/AI/AdMob production configuration boundaries without secrets.
- [X] T011 [US1] Replace `pubspec.yaml` description `"A new Flutter project."` with an app-specific description.

## Phase 4: User Story 2 - Reconcile Historical Specs And Deferred Backlog (Priority: P1)

**Goal**: Guided tour and verification docs stop contradicting each other.

**Independent Test**: Guided tour status in spec/deferred files has one clear state.

- [X] T012 [US2] Update `specs/043-guided-product-tour/spec.md` status from Draft to the correct current state or a specific follow-up status.
- [X] T013 [US2] Update `docs/implementation_plans/deferred-and-advanced-work.md` guided tour/Home verification entry as confirmed open, superseded, or moved to `specs/045-flutter-verification-baseline`.
- [X] T014 [US2] Update `specs/README.md` only if needed to clarify how historical unchecked tasks are interpreted. No edit needed; existing guidance already covers this.

## Phase 5: User Story 3 - Preserve Useful Historical Analysis Without Mislabeling It Current (Priority: P2)

**Goal**: Historical analysis remains readable but not misleading.

**Independent Test**: Opening the roadmap shows an explicit historical-status notice.

- [X] T015 [US3] Add a historical notice at the top of `docs/project_analysis_and_ai_roadmap.md`.
- [X] T016 [US3] Point readers from `docs/project_analysis_and_ai_roadmap.md` to `.specify/memory/constitution.md`, `specs/README.md`, and `docs/implementation_plans/deferred-and-advanced-work.md` for current status.
- [X] T017 [US3] Update or annotate the most misleading stale sections about Auth, static stats, and default counter tests.

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T018 Run `rg -n "A new Flutter project|default counter test|no Auth|static stats|Status: Draft" README.md pubspec.yaml docs specs/043-guided-product-tour`.
- [X] T019 Run `flutter analyze --no-pub` if `pubspec.yaml` was changed.
- [X] T020 Update `specs/046-docs-specs-alignment/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T005 before edits.
- US1 and US2 are P1 and can be done in parallel if files do not overlap.
- US3 follows once current-state docs are accurate.

## Implementation Strategy

MVP is README/pubspec cleanup plus resolving the guided tour/deferred contradiction. Historical roadmap annotation is the next increment.
