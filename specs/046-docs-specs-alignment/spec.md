# Feature Specification: Docs And Specs Alignment

**Feature Branch**: `046-docs-specs-alignment`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Review finding that README, `pubspec.yaml`, historical roadmap docs, guided tour spec status, and deferred backlog contain stale or conflicting project state.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Make Public Project Docs Match The Current App (Priority: P1)

A developer or reviewer must be able to open the README and package metadata and understand the current app capabilities without being misled by starter-template text.

**Why this priority**: Stale entry-point documentation causes wrong setup assumptions and hides implemented features.

**Independent Test**: README and `pubspec.yaml` no longer describe the app as a generic starter project and list the current architecture and verification commands accurately.

**Acceptance Scenarios**:

1. **Given** a new developer reads the README, **When** they look for setup and test commands, **Then** they see current Flutter, Firebase, AI gateway, and rules verification notes.
2. **Given** package metadata is inspected, **When** `pubspec.yaml` is read, **Then** the description reflects the expense tracker app.

---

### User Story 2 - Reconcile Historical Specs And Deferred Backlog (Priority: P1)

Historical specs and deferred work must clearly distinguish completed, superseded, blocked, and still-open work.

**Why this priority**: The current docs conflict on guided tour test status and can send future work into already-fixed areas.

**Independent Test**: Guided tour spec/tasks/deferred references align with the latest known verification baseline and no longer contradict each other.

**Acceptance Scenarios**:

1. **Given** `specs/043-guided-product-tour/spec.md` is opened, **When** implementation has completed, **Then** the status is not left as unexplained Draft.
2. **Given** deferred backlog is opened, **When** guided tour/Home failures are referenced, **Then** the entry is either confirmed open, superseded, or moved to a verification baseline plan.

---

### User Story 3 - Preserve Useful Historical Analysis Without Mislabeling It Current (Priority: P2)

Older analysis documents must remain available but be labeled as historical when claims no longer match the current codebase.

**Why this priority**: Historical context is useful, but stale claims about missing Auth or static stats are harmful if treated as current.

**Independent Test**: `docs/project_analysis_and_ai_roadmap.md` clearly states which sections are historical and points readers to current specs/constitution.

**Acceptance Scenarios**:

1. **Given** a reader opens the old roadmap, **When** they encounter outdated findings, **Then** a header warns that the document is historical.
2. **Given** a current plan is needed, **When** a reader follows the docs, **Then** they are directed to `specs/` and the deferred backlog.

## Edge Cases

- Some unchecked tasks are manual QA or external setup and should remain unchecked, not silently marked complete.
- Historical docs should not be deleted if they still explain project evolution.
- Verification claims must not be updated unless fresh evidence exists or an existing authoritative plan already recorded it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: README must summarize current app features, architecture, setup, and verification commands.
- **FR-002**: `pubspec.yaml` must have an app-specific description.
- **FR-003**: `docs/project_analysis_and_ai_roadmap.md` must be marked as historical or updated to avoid stale current-state claims.
- **FR-004**: `specs/043-guided-product-tour/spec.md` must have a status that matches its implementation state or remaining follow-up.
- **FR-005**: `docs/implementation_plans/deferred-and-advanced-work.md` must resolve the guided tour/Home test status contradiction.
- **FR-006**: Any historical unchecked task updates must use clear labels: completed, superseded, blocked, or deferred.
- **FR-007**: No production/deployment deferred item may be removed unless it has concrete completion evidence.

### Key Entities

- **Entry-Point Documentation**: README and package metadata.
- **Historical Analysis**: Older roadmap and audit documents that may no longer represent current state.
- **Deferred Backlog**: Persistent list of blocked or later-stage tasks.
- **Spec Status**: Status fields and task checkboxes in `specs/`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Starter-template text is removed from README and `pubspec.yaml`.
- **SC-002**: The guided tour Draft/completed contradiction is resolved in the relevant spec/deferred files.
- **SC-003**: Historical docs explicitly tell readers where to find current state.
- **SC-004**: At least one docs-only review command verifies no placeholder markers remain in changed docs.

## Assumptions

- This plan updates documentation and status only; code fixes stay in separate feature specs.
- Deferred production setup, billing, AdMob, real-device QA, and Firebase smoke tests remain open unless independently completed.
