# Feature Specification: Transaction Rate Snapshots

**Feature Branch**: `084-transaction-rate-snapshots`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User reported that previously saved USD expenses change their base-currency value when the daily exchange rate changes. Saved financial history must not move with future exchange-rate refreshes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Saved Expenses Keep Their Original Converted Value (Priority: P1)

As a user with EGP as base currency, I want a USD expense recorded today to keep today's converted EGP value forever unless I edit the expense, so reports and Home totals do not rewrite history.

**Why this priority**: This is a financial trust bug. If old totals change, users cannot trust the app.

**Independent Test**: Save a 10 USD expense when USD-to-EGP is 50, refresh settings so USD-to-EGP becomes 51, and verify the old expense still contributes 500 EGP.

**Acceptance Scenarios**:

1. **Given** base currency is EGP and saved rate is 50 for USD, **When** the user saves a 10 USD expense, **Then** the expense stores 10 USD and a 500 EGP conversion snapshot.
2. **Given** that expense exists, **When** the saved daily rate later changes to 51, **Then** Home, Reports, budgets, AI summaries, and export totals continue using 500 EGP for that expense.
3. **Given** the expense has no snapshot because it is legacy data, **When** the app displays it, **Then** the app uses a clearly marked migration fallback and never silently overwrites the expense without a save/migration step.

---

### User Story 2 - Editing Recomputes Only When Money Inputs Change (Priority: P1)

As a user editing a saved expense, I want the conversion snapshot to update only when I change amount, currency, base currency target, or date/rate-relevant fields, so simple description edits do not alter financial totals.

**Why this priority**: Editing must be predictable and must not create hidden accounting changes.

**Independent Test**: Edit only the description of a converted expense and verify the converted amount is unchanged; then edit the amount and verify the converted amount updates from the current selected rate.

**Acceptance Scenarios**:

1. **Given** a 10 USD expense has a 500 EGP snapshot, **When** the user changes only description or tags, **Then** the snapshot remains 500 EGP.
2. **Given** the same expense, **When** the user changes amount to 12 USD, **Then** the app recomputes and stores a new snapshot using the selected rate policy shown to the user.
3. **Given** no valid rate exists for the changed currency, **When** the user tries to save, **Then** the app blocks converted totals or asks for an explicit rate instead of guessing.

---

### User Story 3 - Financial Surfaces Use One Snapshot Rule (Priority: P2)

As a user, I want Home, Reports, budget progress, exports, AI summaries, and weekly digest to agree on the same converted totals, so I do not see different answers across screens.

**Why this priority**: Cross-screen mismatches make the app look broken even if one screen is correct.

**Independent Test**: Use a fixture with EGP, USD, and missing-rate expenses and verify every financial surface reports the same included, excluded, and converted metadata.

**Acceptance Scenarios**:

1. **Given** expenses contain conversion snapshots, **When** any summary surface aggregates them, **Then** it uses the snapshot rather than the latest settings rate.
2. **Given** an expense snapshot target does not match the current base currency, **When** the app cannot prove a historical conversion, **Then** it marks the expense as unconverted instead of recalculating with today's rate.
3. **Given** an export is generated, **When** rows contain mixed currencies, **Then** exported totals and per-row snapshot metadata match the app display.

### Edge Cases

- Expenses saved while offline must use the last available saved rate and store that rate timestamp/source.
- Expenses saved with base currency equal to expense currency must store a rate of 1 and the original amount as converted amount.
- Legacy expenses with no snapshot must be displayed conservatively and migrated only through an explicit migration task.
- Changing the user's base currency must not mutate existing expense snapshots.
- AI-created, receipt-created, recurring, and manual expenses must all follow the same snapshot creation rule.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST persist an immutable conversion snapshot on every new non-base-currency expense.
- **FR-002**: The snapshot MUST include source amount, source currency, target/base currency, conversion rate, converted amount, rate timestamp/date, and rate source/freshness metadata.
- **FR-003**: Financial aggregation MUST prefer expense-level snapshots over current user settings rates.
- **FR-004**: The system MUST not recalculate historical converted values merely because daily exchange rates refresh.
- **FR-005**: Editing non-money fields MUST preserve the existing conversion snapshot.
- **FR-006**: Editing amount, currency, or rate-relevant fields MUST recompute or explicitly re-confirm the conversion snapshot.
- **FR-007**: Legacy expenses without snapshots MUST be handled with visible fallback metadata and migration tests.
- **FR-008**: The app MUST never hardcode exchange rates.
- **FR-009**: All user-visible missing-rate, converted, stale-rate, and fallback messages MUST be localized.
- **FR-010**: Server/PostgreSQL sync, local storage, and Firestore legacy paths MUST preserve snapshot fields without data loss.

### Key Entities

- **MoneySnapshot**: Immutable conversion evidence captured when an expense is saved or money fields are edited.
- **Expense**: User transaction containing original source amount/currency plus optional conversion snapshot.
- **Rate Evidence**: Metadata describing where the rate came from and when it was valid or captured.
- **Financial Breakdown**: Aggregation result showing included converted amounts, excluded missing-rate amounts, and currencies involved.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A saved converted expense keeps the same base-currency contribution after at least two simulated daily rate changes.
- **SC-002**: Home and Reports totals match for the same fixture in 100% of snapshot-covered test cases.
- **SC-003**: Editing only description/tags causes zero conversion snapshot changes.
- **SC-004**: 100% of new manual, AI, receipt, and recurring expense creation paths store snapshot metadata when conversion is needed and a rate is available.
- **SC-005**: No user-facing financial screen silently sums an expense with a missing or incompatible snapshot.

## Assumptions

- The first implementation uses the rate available at save time, not a remote historical-rate lookup for arbitrary past dates.
- Exact historical rate lookup can be added later if product scope requires it.
- Existing daily exchange-rate cache remains the source of rates, but no longer rewrites old expense values.
- Firestore remains legacy/rollback storage while VPS local-first sync remains under pilot.
