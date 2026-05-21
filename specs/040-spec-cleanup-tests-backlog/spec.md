# Feature Specification: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

**Feature Branch**: `040-spec-cleanup-tests-backlog`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User asked to create a Speckit plan for three proposed follow-up items: clean/update old open specs, add Home navigation and Settings widget smoke tests as near-term work, and update deferred/backlog documentation so PDF Arabic font status and visual QA are clear.

## User Scenarios & Testing

### User Story 1 - Trust The Project Plan State (Priority: P1)

As the project owner or a future AI worker, I want old Speckit task files to clearly show what is truly still open versus what was completed by newer plans, so I do not waste time redoing completed work or miss real blockers.

**Why this priority**: The repository has many historical specs with unchecked tasks. Some are genuinely pending, while others were superseded by later plans. This creates planning noise and makes new work harder to prioritize.

**Independent Test**: Review the generated status audit and confirm that each updated old task is either marked completed, marked superseded by a newer plan, or left open with a specific blocker.

**Acceptance Scenarios**:

1. **Given** a historical spec has unchecked tasks for functionality now covered by plans 037, 038, or 039, **When** the cleanup is performed, **Then** the task file records the newer plan that completed or superseded it.
2. **Given** a task still requires a real device, Firebase deploy, Play Store setup, keystore, or production credential, **When** the cleanup is performed, **Then** the task remains unchecked and references the deferred backlog item instead of appearing forgotten.
3. **Given** a future worker opens `specs/README.md` or a cleaned task file, **When** they scan open work, **Then** they can distinguish current actionable work from external/manual QA.

---

### User Story 2 - Prevent Home And Settings Regressions (Priority: P2)

As a maintainer, I want widget smoke tests for Home navigation and Settings controls, so high-traffic app entry points do not silently break after future feature work.

**Why this priority**: Home and Settings now connect many features: budgets, categories, expenses, monetization, support, AI usage, and retention prompts. Navigation or button regressions are user-visible and currently under-covered.

**Independent Test**: Run targeted Home and Settings widget tests and confirm shortcuts, menus, dialogs, and critical controls render or navigate without using real Firebase.

**Acceptance Scenarios**:

1. **Given** a user is on Home, **When** they use visible shortcuts or menu entries, **Then** the intended screen, dialog, or action surface opens without missing providers or crashes.
2. **Given** a user opens Settings, **When** currency, payment method, notifications, security, AI, monetization, privacy, and support sections render, **Then** each section either exposes a working control or an honest unavailable/support message.
3. **Given** logout is requested from Home/menu flow, **When** the user taps the logout action, **Then** a confirmation dialog appears before sign-out is dispatched.

---

### User Story 3 - Keep Deferred Work Accurate (Priority: P3)

As the project owner, I want the persistent deferred work file to be updated with the current state after each review, so later phases remember what is blocked, what is advanced, and what no longer needs to be done.

**Why this priority**: The project now relies on `docs/implementation_plans/deferred-and-advanced-work.md` as the persistent memory for future work. It must stay accurate whenever plans reveal deferred or advanced items.

**Independent Test**: Inspect the deferred file and confirm it records the three current clarifications: old specs cleanup, Home/Settings test priorities, and Arabic PDF font status with visual QA still pending.

**Acceptance Scenarios**:

1. **Given** the Arabic PDF font asset has been added, **When** the deferred backlog is reviewed, **Then** it no longer says the font asset itself is missing and instead lists visual/manual PDF QA as deferred.
2. **Given** Home navigation and Settings widget tests are still near-term work, **When** the deferred backlog is reviewed, **Then** those items are listed as actionable test coverage, not vague product ideas.
3. **Given** old Speckit tasks may be outdated, **When** the deferred backlog is reviewed, **Then** it includes a reminder to keep historical spec status aligned with newer plans.

### Edge Cases

- Historical task files may contain unchecked tasks that overlap partially with newer work. These should be annotated carefully rather than blindly checked.
- A task may be automated in newer tests but still need device QA. In that case, mark automated verification complete and leave manual/device QA open.
- Some old specs may be intentionally superseded by newer plans. Record the superseding plan rather than deleting historical context.
- Widget tests may require fake repositories or providers to avoid Firebase/plugin initialization.
- Deferred backlog updates must avoid duplicate bullets and should preserve concise grouping.

## Requirements

### Functional Requirements

- **FR-001**: The plan MUST define a repeatable audit process for old unchecked Speckit tasks.
- **FR-002**: The plan MUST identify which old task categories can be updated now and which must remain open because they require external setup or manual device QA.
- **FR-003**: The plan MUST include Home widget/navigation test coverage as an executable task group.
- **FR-004**: The plan MUST include Settings widget smoke test coverage as an executable task group.
- **FR-005**: The plan MUST include updating `docs/implementation_plans/deferred-and-advanced-work.md` with the current backlog corrections.
- **FR-006**: The plan MUST keep build/release/device QA tasks separate from local code/test tasks.
- **FR-007**: The plan MUST avoid changing app behavior except where tests reveal a real broken UI route or missing provider.
- **FR-008**: The plan MUST require verification using analyzer and targeted Flutter tests, then full Flutter tests if the touched files can affect shared UI behavior.
- **FR-009**: The plan MUST preserve existing architecture: Bloc/Cubit, repositories, localization, and no direct Firebase/plugin calls from widgets.

### Key Entities

- **Spec Task Status**: A historical task entry, its current checkbox state, completion evidence, superseding plan, and blocker note.
- **Deferred Work Item**: A persistent backlog bullet grouped by production setup, Firebase, AI, monetization, localization, observability, product retention, or store readiness.
- **Home Navigation Surface**: A Home action, shortcut, menu entry, or dialog that routes to a feature or confirms a sensitive action.
- **Settings Control Surface**: A Settings section or control that persists a preference, opens a subflow, or shows an honest unavailable/support state.
- **Verification Result**: Evidence from analyzer, targeted tests, full tests, or documented manual blockers.

## Success Criteria

### Measurable Outcomes

- **SC-001**: At least 90% of previously unchecked historical tasks reviewed by this plan are either updated, marked superseded, or explicitly left open with a blocker note.
- **SC-002**: Home navigation tests cover at least five user-visible Home actions or menu entries.
- **SC-003**: Settings smoke tests cover at least five critical Settings sections or controls.
- **SC-004**: Deferred backlog updates contain no duplicate items for the three addressed topics.
- **SC-005**: Future workers can identify the next actionable work from the updated files in under 5 minutes.
- **SC-006**: Targeted tests for the new Home/Settings coverage pass before the plan is marked complete.

## Assumptions

- Historical task files should remain as project history; this plan annotates and updates status but does not delete old specs.
- Device QA, release builds, Firebase deploys, AdMob production setup, and Play Store work remain deferred unless the user explicitly requests them.
- The Arabic PDF font file already exists in `assets/fonts/NotoSansArabic-Regular.ttf`; remaining PDF work is visual/manual QA and warning cleanup if needed.
- Widget tests should use fake repositories/providers and must not require live Firebase, Cloudflare, AdMob, speech recognition, camera, local auth, or device notifications.
