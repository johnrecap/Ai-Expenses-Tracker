# Feature Specification: UI Design System Upgrade

**Feature Branch**: `090-ui-design-system-upgrade`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User wants better UI and asked to use GitHub/open-source repositories/tools as references because the current UI feels weak.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App Has a Coherent Financial Design System (Priority: P1)

As a user, I want the app to feel like one polished finance product, not separate screens with inconsistent cards, buttons, spacing, and icons.

**Why this priority**: Visual trust is critical in a finance app.

**Independent Test**: Compare Home, Add Expense, Reports, Settings, and Expenses after applying shared tokens/components and verify consistent spacing, typography, cards, and actions.

**Acceptance Scenarios**:

1. **Given** the user moves between Home, Add Expense, Reports, and Settings, **When** screens load, **Then** they use a consistent visual language.
2. **Given** Arabic RTL is active, **When** finance rows and cards render, **Then** alignment and hierarchy remain professional.

---

### User Story 2 - Add Expense Becomes Faster And Cleaner (Priority: P1)

As a daily user, I want Add Expense to be visually clean and fast, with AI first but manual controls still obvious.

**Why this priority**: Adding expenses is the highest-frequency action.

**Independent Test**: User can add a simple expense quickly and can use AI from the same screen without visual confusion.

**Acceptance Scenarios**:

1. **Given** the user taps `+`, **When** Add Expense opens, **Then** AI capture and manual form feel like one flow.
2. **Given** the keyboard is open, **When** the user reviews fields, **Then** important controls are not hidden or overlapped.

---

### User Story 3 - UI References Are Evaluated Safely (Priority: P2)

As the product owner, I want open-source UI repos/tools to inspire the redesign without copying incompatible code or licenses.

**Why this priority**: External inspiration can speed up design, but unsafe copy/paste creates legal and maintenance risk.

**Independent Test**: Produce a UI reference matrix with license, relevance, adoption risk, and selected patterns before importing any dependency.

**Acceptance Scenarios**:

1. **Given** a candidate GitHub repo or package, **When** it is evaluated, **Then** license, activity, compatibility, and relevance are documented.
2. **Given** a pattern is selected, **When** implementation starts, **Then** it is adapted into local components rather than blindly copied.

### Edge Cases

- Do not introduce a one-note palette or marketing hero layout into operational finance screens.
- Do not nest cards inside cards.
- Do not hide manual finance entry behind AI.
- Avoid heavy visual effects that hurt low-end Android performance.
- Ensure text fits in Arabic on small screens.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST define shared UI tokens for spacing, radius, typography, colors, shadows, and motion.
- **FR-002**: Core finance screens MUST migrate to shared components incrementally.
- **FR-003**: Add Expense MUST prioritize daily speed and keep AI/manual entry visually unified.
- **FR-004**: Any external UI repo/package MUST be evaluated for license, maintenance, compatibility, and performance before use.
- **FR-005**: UI changes MUST preserve all existing finance/auth/sync behavior.
- **FR-006**: Arabic/RTL and small-screen layouts MUST be included in QA.

### Key Entities

- **Design Token**: Shared visual value used across screens.
- **Finance Component**: Reusable UI component for money cards, transaction rows, input fields, action bars, charts, and status banners.
- **Reference Matrix**: Decision record for external UI repos/packages.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Home, Add Expense, Reports, Expenses, and Settings share the same card radius, spacing scale, typography roles, and button styles.
- **SC-002**: Add Expense simple-entry flow can be completed without scrolling through advanced fields on a small screen.
- **SC-003**: At least 5 external UI references are evaluated before dependency adoption.
- **SC-004**: No new UI dependency is added without documented license and rollback decision.

## Assumptions

- The first design pass improves existing screens rather than replacing the whole app.
- External repositories are inspiration unless explicitly approved as dependencies.
