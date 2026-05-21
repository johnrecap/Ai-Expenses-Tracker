# Feature Specification: Financial Calculation Engine

**Feature Branch**: `065-financial-calculation-engine`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a complete Spec Kit plan for making every financial number and currency conversion trustworthy.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One Total Everywhere (Priority: P1)

As a user with multiple currencies, I need Home, Reports, Monthly Budget, Category Budgets, Subscription Center, Export, AI summaries, and weekly digest to agree whenever they describe the same money period.

**Why this priority**: Contradictory money totals destroy trust in a finance app.

**Independent Test**: Given the same mixed-currency expenses and saved rates, every visible surface either shows the same converted total or clearly explains why a surface is intentionally same-currency only.

**Acceptance Scenarios**:

1. **Given** base currency EGP and valid USD rate, **When** a USD expense appears in a monthly period, **Then** every conversion-aware surface includes it with the same converted value.
2. **Given** a missing EUR rate, **When** totals are calculated, **Then** EUR is excluded and surfaced as missing-rate metadata, not silently summed.

---

### User Story 2 - Money Metadata Is Explainable (Priority: P1)

As a user, I need to know which currencies were converted, which rates were used, and which rates were missing.

**Why this priority**: Users can accept conversion if the app explains the math.

**Independent Test**: Every total exposes original currency, base currency, rate value, rate timestamp, converted amount, and missing-rate status.

**Acceptance Scenarios**:

1. **Given** a converted total, **When** the user inspects the surface, **Then** the app can display converted currencies and last refresh date.
2. **Given** missing rates, **When** the user views the surface, **Then** the warning identifies the affected currencies.

---

### User Story 3 - Historical Rate Policy Is Stable (Priority: P2)

As a user reviewing old months, I need reports to avoid changing unexpectedly or clearly state that latest cached rates are used.

**Why this priority**: Historical reports changing over time can feel like data corruption.

**Independent Test**: The app either stores transaction-date conversion snapshots or shows consistent product copy explaining latest-rate calculations.

**Acceptance Scenarios**:

1. **Given** an old expense, **When** rates update today, **Then** the old report behavior follows the documented policy.
2. **Given** transaction-rate snapshots are deferred, **When** reports render, **Then** the app labels totals as based on latest saved rates.

## Edge Cases

- Rate is zero, negative, NaN, or not finite.
- Base currency changes after expenses exist.
- Provider does not support one selected currency.
- Offline for many days.
- Exported values need the same metadata as screen totals.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide one shared calculation boundary for visible financial totals.
- **FR-002**: System MUST never add different currencies without a valid saved rate and documented conversion policy.
- **FR-003**: Every converted total MUST expose converted currencies and unconverted/missing-rate currencies.
- **FR-004**: Every converted amount SHOULD expose the rate value and refresh timestamp when user-facing explanation is needed.
- **FR-005**: Category budgets and subscription summaries MUST be audited and either converted or clearly labelled as same-currency only.
- **FR-006**: Export and AI summaries MUST use the same calculation semantics as visible reports for the same period.
- **FR-007**: Historical reports MUST have an explicit policy: latest saved rates or stored transaction-date rates.

### Key Entities

- **MoneyBreakdown**: Total amount with base currency, converted rows, missing-rate currencies, and rate freshness.
- **ConvertedMoneyRow**: Source amount, source currency, base currency, rate, rate timestamp, converted amount.
- **FinancialCalculationPolicy**: Surface policy for latest-rate, transaction-rate, or same-currency-only behavior.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of user-visible finance totals are covered by calculation tests or documented as intentionally out of scope.
- **SC-002**: Home, Reports, AI summaries, and weekly digest agree for the same mixed-currency fixture.
- **SC-003**: No user-visible surface says "ignored" for a currency that was successfully converted.
- **SC-004**: Missing-rate warnings identify affected currencies in all conversion-aware surfaces.

## Assumptions

- This plan prioritizes shared calculation correctness over new charts.
- Historical transaction-date rates can be deferred if the UI clearly explains latest-rate behavior.

