# Feature Specification: Guided Tour Polish

**Feature Branch**: `048-guided-tour-polish`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Review finding that guided tour route/scroll preparation fields exist but are not clearly implemented, off-screen targets can disappear, and Plan 043 status needs behavioral follow-up.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Tour Steps Reach Their Targets Reliably (Priority: P1)

Users must see each guided tour spotlight on the intended target, including targets that require navigation or scrolling.

**Why this priority**: A guided tour that highlights missing or off-screen elements teaches the wrong behavior.

**Independent Test**: Widget tests can start the tour, advance to steps with scrollable targets, and verify the target becomes visible or is skipped intentionally with a recorded reason.

**Acceptance Scenarios**:

1. **Given** a tour step targets an element below the visible viewport, **When** the step becomes active, **Then** the app scrolls or prepares the route so the spotlight target is visible.
2. **Given** a target cannot be registered, **When** the step allows missing targets, **Then** the tour skips it without blocking completion.

---

### User Story 2 - Tour Metadata Is Either Used Or Removed (Priority: P1)

Every field in `GuidedTourStep` must have a clear runtime purpose or be removed from the model and docs.

**Why this priority**: Unused fields such as `routeName` and `allowTargetTap` create false confidence and stale tasks.

**Independent Test**: Tests or static review show each remaining field is consumed by guided tour runtime behavior.

**Acceptance Scenarios**:

1. **Given** `routeName` remains on a step, **When** that step activates, **Then** the host uses it to navigate or prepare the screen.
2. **Given** `allowTargetTap` remains on a step, **When** that step is active, **Then** overlay hit testing respects that choice without accidental feature calls.

---

### User Story 3 - Tour UX Is Safe Across Accessibility And RTL (Priority: P2)

The tour must respect reduced motion, back button behavior, replay, skip, and Arabic small-screen layout without triggering provider actions.

**Why this priority**: Guided onboarding touches first impressions and must be safe for all users.

**Independent Test**: Targeted widget tests cover reduced-motion overlay, back/skip/complete persistence calls, replay from Settings, and Arabic layout smoke.

**Acceptance Scenarios**:

1. **Given** reduced animations are enabled, **When** the tour is active, **Then** pulse animations do not run.
2. **Given** Arabic locale and small viewport, **When** a tour card renders, **Then** controls remain reachable and text does not overlap.

## Edge Cases

- Some steps target widgets inside scroll views or tabs.
- Settings replay may start from a different route than first-run Home.
- `allowTargetTap` must never allow AI, purchase, ad, permission, camera, speech, or notification service calls during the tour unless a future spec explicitly changes that rule.
- Missing targets should not leave overlay animations running after disposal.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Tour steps requiring navigation or scrolling must have an implemented preparation path or be marked intentionally skip-only.
- **FR-002**: Every `GuidedTourStep` field must be used in runtime logic or removed from model, docs, and tasks.
- **FR-003**: Off-screen targets must be scrolled into view, prepared by route, or skipped safely.
- **FR-004**: Tour overlay must not trigger AI, ads, purchases, permission prompts, camera, speech, or notification services.
- **FR-005**: Reduced motion must stop pulse animations.
- **FR-006**: Back, skip, complete, and replay flows must persist settings through `SettingsRepository`.
- **FR-007**: Arabic small-screen tour layout must have at least smoke widget coverage and manual QA tracking.

### Key Entities

- **Guided Tour Step**: Versioned instructional step with target id, copy, and preparation behavior.
- **Spotlight Target**: Registered widget target for overlay positioning.
- **Tour Preparation**: Navigation or scroll behavior needed before spotlight calculation.
- **Tour Progress**: Versioned completion/skip state stored in user settings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All tour step model fields have a documented runtime use or are removed.
- **SC-002**: Widget tests cover at least one off-screen target preparation path.
- **SC-003**: Widget tests cover skip/complete persistence through fake settings.
- **SC-004**: Tour tests complete without lingering animation failures.

## Assumptions

- This plan builds on Plan 043 and does not redesign the guided tour from scratch.
- It remains acceptable to skip optional unavailable targets if the user can still complete the tour.
- Real-device guided tour QA remains deferred if no Android device is available.
