# Feature Specification: Decimal Amounts Support

**Feature Branch**: `050-decimal-amounts-support`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: UX review finding that expenses and related flows parse amounts as integers, preventing decimal values for currencies such as USD/EUR or cents/piasters.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Enter And Save Decimal Expenses (Priority: P1)

Users must be able to enter positive decimal expense amounts where the currency supports fractional values.

**Why this priority**: Integer-only entry blocks common real-world amounts such as 12.50.

**Independent Test**: Add Expense accepts `12.50`, saves it through the repository, and displays it consistently with currency formatting.

**Acceptance Scenarios**:

1. **Given** a user enters `12.50`, **When** they save a valid expense, **Then** the saved amount preserves the decimal value.
2. **Given** a user enters `0`, a negative amount, or invalid text, **When** they try to save, **Then** the app rejects the input with a localized validation message.

---

### User Story 2 - Existing Integer Data Remains Compatible (Priority: P1)

Existing Firestore documents and tests with integer `amount` values must continue to load, display, filter, export, and report correctly.

**Why this priority**: A decimal migration must not break current user data.

**Independent Test**: Repository entity tests load both integer and floating numeric amounts and map them to the app model correctly.

**Acceptance Scenarios**:

1. **Given** an old document with `amount: 120`, **When** it is loaded, **Then** it displays as the equivalent whole amount.
2. **Given** a new document with `amount: 120.75`, **When** it is loaded, **Then** the decimal value is preserved.

---

### User Story 3 - Calculations And Exports Handle Decimals (Priority: P2)

Reports, filters, budgets, AI previews, recurring expenses, and export rows must use decimal-safe parsing and formatting.

**Why this priority**: Saving decimals is not enough if totals, filters, and exports silently round or truncate values.

**Independent Test**: Report totals, amount filters, CSV/Excel/PDF exports, AI preview edit, and recurring expense creation preserve decimal amounts.

**Acceptance Scenarios**:

1. **Given** expenses with decimal amounts, **When** reports calculate totals, **Then** totals include decimals accurately enough for display.
2. **Given** a user filters by decimal min/max amount, **When** the list is filtered, **Then** matching expenses are included correctly.
3. **Given** a decimal expense is exported, **When** CSV/Excel/PDF is opened, **Then** the decimal amount is visible and not truncated.

## Edge Cases

- Existing integer amount data must remain valid.
- Firestore rules already allow integer or floating positive money values, but tests must confirm.
- Locale decimal separators may differ; initial support should accept standard numeric input and avoid accidental comma truncation.
- Floating-point display must avoid noisy precision artifacts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Expense amount models/entities must support decimal numeric values.
- **FR-002**: Existing integer amount documents must load without migration.
- **FR-003**: Add Expense must parse and validate decimal amounts.
- **FR-004**: Amount formatting must display decimals consistently and avoid precision noise.
- **FR-005**: Filters must parse decimal min/max amounts.
- **FR-006**: Reports and calculators must include decimal values without truncation.
- **FR-007**: AI action preview amount editing must accept decimals.
- **FR-008**: Recurring expense amount entry must accept decimals or explicitly remain integer with a documented reason.
- **FR-009**: Export formats must preserve decimal amounts.
- **FR-010**: Rules tests must confirm decimal `amount` writes are accepted and invalid money remains denied.

### Key Entities

- **Money Amount**: Positive numeric amount that may include fractional currency units.
- **Expense Amount**: Amount stored on expense documents and used across reports, filters, exports, AI, and recurring flows.
- **Backward-Compatible Amount Parser**: Entity parsing that accepts existing int values and new decimal values.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create an expense with a decimal amount.
- **SC-002**: Existing integer expense fixture tests still pass.
- **SC-003**: Report/export/filter tests include at least one decimal amount case.
- **SC-004**: No amount display shows floating-point artifacts such as `12.499999999`.

## Assumptions

- This plan keeps the existing Firestore `amount` field as a numeric value for backward compatibility.
- A future exact minor-unit storage migration can be planned separately if production accounting precision requires it.
- Currency conversion is out of scope.
