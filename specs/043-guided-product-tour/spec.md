# Feature Specification: Guided Product Tour

**Feature Branch**: `043-guided-product-tour`  
**Created**: 2026-05-18  
**Status**: Implemented; manual real-device QA remains deferred  
**Input**: User request for first-time in-app guidance using a darkened overlay, focused AI icon, subtle animation, and similar guidance for important app areas.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Spotlight The AI Assistant (Priority: P1)

After onboarding, the user sees a focused spotlight on the AI Assistant icon while the rest of the screen is softly dimmed. A subtle animation draws attention without blocking accessibility, and the explanation tells the user AI can write or speak expenses and always shows a preview before saving.

**Why this priority**: AI Assistant is the app's differentiating feature and needs clear first-use guidance.

**Independent Test**: Complete first-run setup, land on Home, and verify the first spotlight focuses the AI icon with dim overlay, short guidance, skip/next controls, and no AI provider call.

**Acceptance Scenarios**:

1. **Given** a user has completed setup and has not seen the tour, **When** Home appears, **Then** the AI icon is highlighted and other UI is dimmed.
2. **Given** the AI spotlight is visible, **When** the user taps Next, **Then** the tour advances without triggering AI parsing.
3. **Given** the user taps Skip, **When** Home remains visible, **Then** the tour is marked skipped for the current version.

---

### User Story 2 - Teach Core Finance Workflows (Priority: P2)

The tour guides users through manual Add Expense, AI Preview confirmation, Budget, Reports, Categories, and Settings using short spotlight steps.

**Why this priority**: The app has many features; users need to understand the core loop without reading long help pages.

**Independent Test**: Run the tour and verify every step can find its target or gracefully skip unavailable targets, and each step has clear localized text.

**Acceptance Scenarios**:

1. **Given** the user continues the tour, **When** the Add Expense step appears, **Then** the manual entry button is highlighted and explains manual entry works even when AI quota is exhausted.
2. **Given** the Budget step appears, **When** the user taps it, **Then** the app can navigate or point to the budget area without losing tour state.
3. **Given** a target is not available on the current screen, **When** the tour reaches that step, **Then** the app skips or defers the step instead of crashing.

---

### User Story 3 - Let Users Replay Or Dismiss Guidance (Priority: P3)

Users can skip, complete, or replay the tour later from Settings. Future tour versions can show new steps without annoying users who already completed older versions.

**Why this priority**: Guidance should help users, not trap them. Versioning lets later features introduce new guidance safely.

**Independent Test**: Complete the tour, restart the app, verify it does not show again, then open Settings and replay it.

**Acceptance Scenarios**:

1. **Given** the user completes all tour steps, **When** they restart the app, **Then** the same tour version does not auto-show.
2. **Given** the user skipped the tour, **When** they open Settings, **Then** they can replay it.
3. **Given** a future tour version is higher than the stored version, **When** the user opens Home, **Then** only new or changed guidance can be shown.

### Edge Cases

- Overlay must not hide system keyboard or trap focus permanently.
- Tour must be dismissible with Android back button.
- Tour must work in Arabic RTL and English LTR.
- Tour target discovery must tolerate scroll views and missing widgets.
- Tour must not consume AI quota, show ads, trigger purchases, or request permissions.
- Reduce-motion users should get minimal animation.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store guided-tour completion, skipped state, and version per user.
- **FR-002**: System MUST show the AI Assistant spotlight first after first-run setup is complete.
- **FR-003**: System MUST dim non-target UI with a subtle overlay while keeping the highlighted target readable and tappable only when safe.
- **FR-004**: System MUST provide Next, Back, Skip, and Done controls.
- **FR-005**: System MUST support replaying the tour from Settings.
- **FR-006**: System MUST localize all tour text.
- **FR-007**: System MUST not call AI, ads, purchases, camera, speech, or notifications from tour steps.
- **FR-008**: System MUST gracefully skip or defer steps whose target is unavailable.
- **FR-009**: System MUST support reduced-motion behavior.
- **FR-010**: Tests MUST cover first-run display, skip, completion persistence, replay, missing target behavior, and RTL layout.

### Key Entities

- **GuidedTourState**: Stores current tour version, completed version, skipped version, and active step.
- **GuidedTourStep**: Defines target id, title, body, placement, optional route, and whether missing targets can be skipped.
- **SpotlightTarget**: Runtime registration of a UI element that can be highlighted.
- **TourOverlay**: Presentation state for dim background, highlight bounds, animation, and controls.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: First-time users see the AI Assistant guidance within 2 seconds of reaching Home after setup.
- **SC-002**: Users can skip or complete the tour in under 60 seconds.
- **SC-003**: The tour never triggers AI quota usage, ad display, purchase flow, or permission prompt.
- **SC-004**: Automated tests cover at least six guided-tour behaviors: first show, next, back, skip, complete, replay, and missing target.
- **SC-005**: The overlay remains usable on a small Android viewport and in Arabic RTL.

## Assumptions

- This plan depends on Plan 042 onboarding completion state.
- The first tour version should focus on AI, manual entry, preview confirmation, budget, reports, categories, settings, and Free/Premium.
- A custom lightweight overlay is preferred unless an existing package is already present and matches project constraints.
- The tour should be local and deterministic; no backend is needed beyond persisted user settings.
