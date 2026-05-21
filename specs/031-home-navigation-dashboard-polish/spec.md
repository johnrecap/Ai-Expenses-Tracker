# Feature Specification: Home Navigation And Dashboard Polish

**Feature Branch**: `031-home-navigation-dashboard-polish`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found Home has an inner settings icon that does not navigate, dense top actions, and dashboard values must remain tied to real app data.

## User Scenarios & Testing

### User Story 1 - Home Settings Entry Works (Priority: P1)

A user taps the Settings icon from Home and reaches the real Settings screen.

**Why this priority**: A visible no-op control breaks trust and makes app configuration hard to find.

**Independent Test**: Tap the Home settings icon and confirm Settings screen opens.

**Acceptance Scenarios**:

1. **Given** user is on Home, **When** they tap the Settings icon, **Then** Settings opens.
2. **Given** user returns from Settings, **When** Home is visible, **Then** dashboard state remains intact.

---

### User Story 2 - Home Dashboard Uses Only Real Data (Priority: P2)

The dashboard never shows fake balance, fake income, or hardcoded sample totals.

**Why this priority**: Expense tracking depends on trust in numbers.

**Independent Test**: Seed expenses/budget/settings fixtures and verify Home totals match `HomeSummaryCalculator`.

**Acceptance Scenarios**:

1. **Given** a user has 250 EGP in monthly expenses, **When** Home opens, **Then** monthly spending/remaining values match real data.
2. **Given** no budget exists, **When** Home opens, **Then** the app shows a clear budget setup state instead of fake balance.

---

### User Story 3 - Home Actions Are Clear And Not Crowded (Priority: P3)

Top actions such as AI, reports, categories, settings, export, logout, and add expense are discoverable without looking like random icons.

**Why this priority**: Crowded action rows are hard for non-technical users and Arabic labels/tooltips matter.

**Independent Test**: Review Home on small Android screen and confirm actions are reachable, labeled by tooltip/semantics, and not overlapping.

**Acceptance Scenarios**:

1. **Given** small phone width, **When** Home renders, **Then** top actions do not overlap each other or the welcome header.
2. **Given** user long-presses or screen reader focuses an icon action, **When** tooltip/semantics appears, **Then** the action purpose is clear.

### Edge Cases

- Home must handle no expenses, mixed currencies, missing budget, offline pending writes, and loading states.
- Logout must remain available but not be accidentally tapped.
- Settings navigation must work whether Settings is pushed or selected through an existing navigation scaffold.

## Requirements

### Functional Requirements

- **FR-001**: Every visible Home action icon MUST perform a real action or be removed.
- **FR-002**: Settings icon from Home MUST navigate to the actual Settings screen.
- **FR-003**: Home financial values MUST be calculated through `HomeSummaryCalculator` or equivalent prepared state, not hardcoded values.
- **FR-004**: Home MUST show clear states for no budget, no expenses, mixed currency, loading, offline pending writes, and errors.
- **FR-005**: Icon-only Home actions MUST have tooltips and semantic labels.
- **FR-006**: Action layout MUST not overlap on common small phone widths.

### Key Entities

- **Home Action**: A visible command from Home, including route target and tooltip.
- **Home Summary**: Prepared financial data from expenses, budget, settings, and category summaries.
- **Dashboard State**: Loading, empty, ready, mixed-currency warning, offline pending, or error.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of Home action icons have a working target or are removed.
- **SC-002**: Home values match calculator output in fixture tests.
- **SC-003**: Home renders without overlapping controls on a small phone viewport.
- **SC-004**: Users can reach Settings from Home in one tap.

## Assumptions

- Existing `HomeSummaryCalculator` is the source of truth for dashboard math.
- Existing navigation uses direct `Navigator`/`MaterialPageRoute`.
- Full navigation redesign is out of scope; this plan polishes current structure.
