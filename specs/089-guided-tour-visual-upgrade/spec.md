# Feature Specification: Guided Tour Visual Upgrade

**Feature Branch**: `089-guided-tour-visual-upgrade`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User wants the guided tour/profile tutorial to look more attractive, with a visual element that points to the described part, like a watermark/liquid effect emerging from the box toward the target.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Tour Clearly Points To The Target (Priority: P1)

As a new user, I want each tour step to visually connect the explanation card to the highlighted app part, so I immediately know what the text refers to.

**Why this priority**: A tutorial that does not clearly point is ignored.

**Independent Test**: Run Home tour and verify each step highlights the correct target and draws a clear visual connector.

**Acceptance Scenarios**:

1. **Given** the AI button is the current target, **When** the tour step appears, **Then** a spotlight and connector visually point to the AI button.
2. **Given** the target is near screen edges, **When** the card is placed, **Then** the connector remains visible and does not cover critical buttons.

---

### User Story 2 - Tour Looks Premium But Remains Readable (Priority: P1)

As a user, I want the tour card to feel polished without making text hard to read.

**Why this priority**: Visual polish must not reduce clarity.

**Independent Test**: Arabic and English tour steps remain readable on small Android viewport.

**Acceptance Scenarios**:

1. **Given** Arabic RTL, **When** a tour step opens, **Then** title, body, and buttons are readable and aligned.
2. **Given** reduce-motion/accessibility settings are active, **When** the tour opens, **Then** animations reduce or disable without breaking layout.

---

### User Story 3 - Tour Supports Replay And Target Movement (Priority: P2)

As a returning user, I want replayed tour steps to still find targets after scrolling or layout changes.

**Why this priority**: Current tour polish must not regress replay/settings behavior.

**Independent Test**: Replay tour from Settings after language switch and verify targets and connectors remain correct.

**Acceptance Scenarios**:

1. **Given** the user replays the tour, **When** a target is below the fold, **Then** the app scrolls/positions so the target and explanation are visible.
2. **Given** device rotates or layout changes, **When** the tour advances, **Then** target geometry recalculates.

### Edge Cases

- Small screens with keyboard open.
- RTL target direction.
- Dark overlay contrast.
- Targets that temporarily do not exist due loading state.
- Older/low-end Android GPU performance.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each tour step MUST visibly connect the explanation to the highlighted target.
- **FR-002**: The visual effect MUST not block reading or essential actions.
- **FR-003**: Tour card, buttons, and connector MUST support Arabic RTL and English LTR.
- **FR-004**: Tour replay, skip, complete, back, and persistence behavior MUST remain unchanged.
- **FR-005**: Animations MUST be bounded and safe for low-end devices.
- **FR-006**: If third-party packages are evaluated, license, maintenance, and performance risks MUST be documented before adoption.

### Key Entities

- **TourStepVisualState**: Target rectangle, card rectangle, connector path, and animation state.
- **TourConnector**: Visual pointer between card and target.
- **TourSurfaceStyle**: Theme tokens for overlay, card, glass/liquid accent, and accessibility fallback.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of current tour steps show a visible target connector in Arabic and English.
- **SC-002**: No tour step blocks its own Next/Back/Skip buttons on a small Android viewport.
- **SC-003**: Replay from Settings completes without target-not-found failures in manual QA.
- **SC-004**: Tour rendering does not introduce frame drops severe enough to block interaction on a mid-range Android device.

## Assumptions

- Existing guided tour state and persistence stay in place.
- A custom painter/overlay is preferred unless a package clearly reduces risk.
