# Feature Specification: Report Drilldowns And Monthly Story

**Feature Branch**: `070-report-drilldowns-monthly-story`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested report drilldowns and a monthly financial story so reports become actionable.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Drill Into A Report (Priority: P1)

As a user reviewing reports, I need to tap a chart bar or category and see the matching expenses.

**Why this priority**: Reports should lead to action, not just display numbers.

**Independent Test**: Tapping a weekly bucket/category opens a filtered expense list matching the selected period/category.

**Acceptance Scenarios**:

1. **Given** a weekly chart bar, **When** the user taps it, **Then** matching expenses for that day/week bucket are shown.
2. **Given** a category breakdown row, **When** the user taps it, **Then** matching category expenses for the report period are shown.

---

### User Story 2 - Monthly Story Is Clear (Priority: P2)

As a normal user, I need a plain-language monthly summary explaining what changed and why.

**Why this priority**: Most users understand stories faster than raw charts.

**Independent Test**: Monthly story uses deterministic report data and identifies key drivers.

**Acceptance Scenarios**:

1. **Given** current month increased, **When** monthly story is shown, **Then** it lists primary category drivers and unusual large expenses.
2. **Given** spending decreased, **When** story is shown, **Then** it communicates improvement without misleading percentages.

## Edge Cases

- Empty period.
- Missing conversion rates.
- One large outlier dominates.
- No previous period data.
- Drilldown from converted category totals.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Report chart buckets and category rows MUST support drilldown to matching expenses.
- **FR-002**: Drilldowns MUST use the same filter semantics as the Expenses screen.
- **FR-003**: Monthly story MUST be based on deterministic report calculations.
- **FR-004**: Monthly story MUST disclose missing-rate limitations when totals exclude currencies.
- **FR-005**: Story copy MUST be localized.

### Key Entities

- **ReportDrilldownTarget**: Period, category, currency policy, and filter payload.
- **MonthlyFinancialStory**: Summary, drivers, outliers, previous comparison, and caveats.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of drilldown targets open an expense list matching report fixtures.
- **SC-002**: Monthly story identifies at least one driver when spending changes by more than 10%.
- **SC-003**: No monthly story contradicts report totals or missing-rate metadata.

## Assumptions

- Drilldown opens existing Expenses screen with preloaded filters.
- AI wording is optional and not required for MVP.

