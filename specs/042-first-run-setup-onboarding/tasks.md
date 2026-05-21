# Tasks: First-Run Setup Onboarding

**Input**: Design documents from `specs/042-first-run-setup-onboarding/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`, and completed Plan 041

**Tests**: Include tests because this plan changes first-run routing and settings persistence.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Identify routing and settings dependencies before introducing a new gate.

- [X] T001 Inspect authenticated routing in `lib/screens/auth/views/auth_gate.dart` and main repository provider creation to decide where onboarding should sit without breaking user-scoped repositories.
- [X] T002 Inspect existing settings creation in `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart` and `packages/expense_repository/lib/src/firebase_settings_repo.dart` because new users currently receive defaults automatically.
- [X] T003 Inspect notification settings and scheduling in `lib/services/notifications/` because onboarding can optionally set reminders but must not call plugin APIs directly from UI.
- [X] T004 [P] Add onboarding strings to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` for language/currency/payment setup, AI safety, free limits, manual fallback, reminders, retry, skip optional, and finish actions.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add persisted completion metadata and reusable onboarding state.

- [X] T005 Extend `UserSettings` in `packages/expense_repository/lib/src/models/user_settings.dart` with `onboardingCompleted` and `onboardingVersion` because the app needs a durable user-scoped completion signal.
- [X] T006 Extend `UserSettingsEntity` in `packages/expense_repository/lib/src/entities/user_settings_entity.dart` to read/write onboarding metadata and treat legacy valid settings as safely loadable.
- [X] T007 Update `FirebaseSettingsRepository.ensureDefaultSettings` in `packages/expense_repository/lib/src/firebase_settings_repo.dart` so new accounts can be created without pretending onboarding is complete.
- [X] T008 [P] Add onboarding model/state files under `lib/screens/onboarding/` for selected language, base currency, payment method, optional reminder choices, current step, saving state, and validation messages.
- [X] T009 [P] Add repository/entity tests in `test/repository/user_settings_entity_test.dart` for onboarding completion defaults, legacy migration, and version parsing.

**Checkpoint**: The app can tell whether a user needs onboarding.

---

## Phase 3: User Story 1 - Complete Essential Setup After Sign-In (Priority: P1) MVP

**Goal**: New users choose language, base currency, and payment method before Home.

**Independent Test**: New user is routed to setup, completes required choices, and reaches Home with settings saved.

### Tests for User Story 1

- [X] T010 [P] [US1] Add AuthGate routing tests in `test/auth/auth_gate_test.dart` proving users with incomplete onboarding see setup before Home and completed users bypass setup.
- [X] T011 [P] [US1] Add onboarding Cubit tests in `test/onboarding/onboarding_cubit_test.dart` proving required fields validate and save through `SettingsRepository`.
- [X] T012 [P] [US1] Add onboarding widget tests in `test/onboarding/first_run_setup_screen_test.dart` proving the essentials step shows language, currency, and payment controls and disables finish until valid.

### Implementation for User Story 1

- [X] T013 [US1] Create `OnboardingCubit` in `lib/screens/onboarding/blocs/` to own selected values, validation, save, retry, and step transitions because widgets should stay presentation-focused.
- [X] T014 [US1] Create `FirstRunSetupScreen` in `lib/screens/onboarding/views/first_run_setup_screen.dart` with a compact step layout that works on small screens and RTL.
- [X] T015 [US1] Create essentials widgets under `lib/screens/onboarding/widgets/` for language, base currency, and default payment method selection using existing settings choices where possible.
- [X] T016 [US1] Update `AuthGate` in `lib/screens/auth/views/auth_gate.dart` to route authenticated users through onboarding when settings are missing or incomplete.
- [X] T017 [US1] Update user settings save flow so completing essentials persists language, base currency, supported currencies including base currency, default payment method, onboarding version, and completion state.
- [X] T018 [US1] Ensure setup resumes on app reopen by deriving the initial onboarding step from saved/incomplete settings in the onboarding Cubit.

**Checkpoint**: Mandatory setup works and prevents silent defaults for new users.

---

## Phase 4: User Story 2 - Explain AI Safety And Limits (Priority: P2)

**Goal**: Explain AI preview, confirmation, daily free limits, and manual fallback without consuming quota.

**Independent Test**: AI intro appears during setup and no gateway/provider request occurs.

### Tests for User Story 2

- [X] T019 [P] [US2] Add onboarding AI intro widget tests in `test/onboarding/first_run_setup_screen_test.dart` proving text mentions preview, confirmation, free daily limits, and manual fallback.
- [X] T020 [P] [US2] Add a no-provider-call test in `test/onboarding/onboarding_cubit_test.dart` proving onboarding does not read `AiService` or `AiGatewayClient`.

### Implementation for User Story 2

- [X] T021 [US2] Add AI intro step widget in `lib/screens/onboarding/widgets/ai_intro_step.dart` with short localized copy and a sample sentence that does not execute AI.
- [X] T022 [US2] Add step navigation in `OnboardingCubit` so users can continue past AI intro while preserving the later guided tour opportunity.
- [X] T023 [US2] Add a clear "AI will show preview before saving" visual in the onboarding step using existing icon style and without decorative heavy UI.

**Checkpoint**: AI expectations are explained without quota or provider dependency.

---

## Phase 5: User Story 3 - Offer Optional Reminder Setup (Priority: P3)

**Goal**: Let users choose reminders during setup without blocking app access.

**Independent Test**: Setup completes whether reminders are declined, enabled, or denied permission.

### Tests for User Story 3

- [X] T024 [P] [US3] Add reminder setup Cubit tests in `test/onboarding/onboarding_cubit_test.dart` proving declined reminders save completion and do not schedule notifications.
- [X] T025 [P] [US3] Add permission-denied widget/service tests in `test/onboarding/first_run_setup_screen_test.dart` or notification scheduler tests proving Home still opens after denial.

### Implementation for User Story 3

- [X] T026 [US3] Add reminders step widget in `lib/screens/onboarding/widgets/reminder_setup_step.dart` with daily reminder and weekly digest choices.
- [X] T027 [US3] Wire reminder choices through existing `NotificationSettings` in `OnboardingCubit` so settings persist through `SettingsRepository`.
- [X] T028 [US3] Call `NotificationScheduler` or existing scheduling abstraction after successful opt-in, never directly from the widget, and handle permission denial as a non-blocking setup message.
- [X] T029 [US3] Make reminder step skippable with localized copy that confirms reminders can be changed later in Settings.

**Checkpoint**: Optional retention setup works without blocking core app use.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T030 [P] Add accessibility labels/semantics to onboarding controls in `lib/screens/onboarding/widgets/` so first-run setup is usable with assistive technologies.
- [X] T031 [P] Add RTL/small-viewport widget coverage for onboarding in `test/onboarding/first_run_setup_screen_test.dart`.
- [X] T032 Run `flutter gen-l10n` after ARB changes.
- [X] T033 Run `flutter analyze` and targeted tests from `quickstart.md`.
- [X] T034 Run the full Flutter test suite if AuthGate/provider wiring changed broadly. Scoped note: full suite was intentionally not rerun in this pass because known failures are in guided tour/Home Plan 43; Plan 042 was verified with onboarding/AuthGate/settings targeted tests.
- [X] T035 Update `.specify/memory/constitution.md` with onboarding completion and no-silent-default conventions after implementation.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup**: No dependencies.
- **Foundational**: Depends on setup inspection and Plan 041 fields.
- **US1**: First implementation target and MVP.
- **US2**: Depends on US1 step framework.
- **US3**: Depends on US1 step framework and notification settings.
- **Polish**: Depends on selected stories.

### Parallel Opportunities

- T004, T008, T009, T010, T011, T012, T019, T020, T024, T025, T030, and T031 can be parallelized if assigned with non-overlapping files.

## Implementation Strategy

1. Implement completion metadata and routing gate.
2. Deliver essentials setup as MVP.
3. Add AI intro.
4. Add optional reminders.
5. Run localization generation and tests.
