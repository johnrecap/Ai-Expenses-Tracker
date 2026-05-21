# Tasks: Localization And RTL Completion

**Input**: Design documents from `specs/047-localization-rtl-completion/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Audit strings and define the replacement scope.

- [X] T001 Run a hardcoded-string search across `lib/screens`, `lib/ai`, `lib/monetization`, and `lib/services/export`.
- [X] T002 Create or update `docs/localization/hardcoded-string-audit.md` with app-owned, user-generated, provider/debug, and test-only categories.
- [X] T003 Identify existing test localization helpers and reusable localized widget wrappers.
- [X] T004 Confirm current ARB naming conventions in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

## Phase 2: Foundational

**Purpose**: Prepare l10n keys and tests before replacing strings broadly.

- [ ] T005 Add missing English keys for P1 finance surfaces to `lib/l10n/app_en.arb`.
- [ ] T006 Add matching Arabic keys for P1 finance surfaces to `lib/l10n/app_ar.arb`.
- [ ] T007 Run `flutter gen-l10n` and confirm generated localization files update cleanly.
- [ ] T008 Add or update a reusable localized pump helper in `test/helpers/` if existing helpers are insufficient.

## Phase 3: User Story 1 - Core Finance Screens Are Localized (Priority: P1)

**Goal**: Core finance flows use l10n for app-owned copy.

**Independent Test**: Representative finance screens render in Arabic and English.

- [ ] T009 [US1] Replace app-owned strings in `lib/screens/add_expense/` with l10n lookups.
- [ ] T010 [US1] Replace app-owned strings in `lib/screens/expenses/` and filter widgets with l10n lookups.
- [ ] T011 [US1] Replace app-owned strings in `lib/screens/category` or category management screens with l10n lookups.
- [ ] T012 [US1] Replace app-owned strings in `lib/screens/recurring_expenses/` with l10n lookups.
- [ ] T013 [US1] Replace app-owned strings in `lib/screens/reports/` with l10n lookups.
- [ ] T014 [US1] Replace app-owned strings in `lib/screens/saving_goals/` with l10n lookups.
- [ ] T015 [US1] Replace app-owned strings in `lib/screens/export/` and export UI widgets with l10n lookups.
- [ ] T016 [US1] Add widget tests for at least two P1 screens in English and Arabic.

## Phase 4: User Story 2 - AI And Monetization Surfaces Are Localized (Priority: P2)

**Goal**: High-trust AI and monetization copy is localized.

**Independent Test**: AI Assistant and Free/Premium widgets render localized labels.

- [ ] T017 [US2] Add missing AI Assistant keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- [ ] T018 [US2] Replace app-owned strings in `lib/screens/ai_assistant/`, `lib/ai/widgets/`, or related AI UI files.
- [ ] T019 [US2] Add missing monetization keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- [ ] T020 [US2] Replace app-owned strings in `lib/monetization/` UI surfaces.
- [ ] T021 [US2] Add widget tests for AI Assistant and Free/Premium surfaces in English and Arabic.

## Phase 5: User Story 3 - Manual RTL QA Is Documented And Repeatable (Priority: P3)

**Goal**: Manual RTL QA can be executed consistently.

**Independent Test**: Checklist has concrete screens, setup, and expected observations.

- [X] T022 [US3] Create `docs/qa/arabic-rtl-checklist.md`.
- [X] T023 [US3] Add checks for Add Expense with keyboard open, AI input with long Arabic text, Expenses filters, Export PDF flow, Settings groups, Free/Premium cards, Saving Goals, Reports, and Recurring Expenses.
- [X] T024 [US3] Add sample mixed Arabic/English expense data to the checklist without embedding sensitive real data.
- [X] T025 [US3] Record Arabic PDF visual inspection as completed or deferred with reason.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T026 Run `flutter gen-l10n`.
- [ ] T027 Run `flutter analyze --no-pub`.
- [ ] T028 Run targeted localized widget tests.
- [X] T029 Update `docs/implementation_plans/deferred-and-advanced-work.md` if manual RTL or PDF visual QA remains blocked.
- [X] T030 Update `specs/047-localization-rtl-completion/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T004 before ARB edits.
- T005-T008 before broad widget edits.
- US1 is MVP and should be completed before US2 if time is limited.
- US3 can be documented in parallel with US1/US2 if no file conflicts.

## Implementation Strategy

Complete localization one surface at a time. Run `flutter gen-l10n` after each logical ARB batch to catch key mistakes early.
