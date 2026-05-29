# Feature Specification: Expense Editing And Adjustments

**Feature Branch**: `087-expense-editing-adjustments`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User wants to edit saved expenses, including increasing or decreasing the amount, after they were created by manual or AI flows.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Edit Any Saved Expense From Transaction Lists (Priority: P1)

As a user, I want to open any saved expense from Home or Expenses and edit its amount, category, currency, date, payment method, merchant, tags, or description.

**Why this priority**: Users commonly make mistakes or need to correct AI-created entries.

**Independent Test**: Create an expense, open it from Home, change the amount, save, and verify lists and totals update.

**Acceptance Scenarios**:

1. **Given** a saved expense appears on Home, **When** the user taps edit, **Then** a full edit form opens with current values.
2. **Given** the user changes amount from 300 to 350, **When** they save, **Then** the expense and all totals reflect 350.
3. **Given** the user cancels, **When** they return to the list, **Then** no fields change.

---

### User Story 2 - Money Edits Preserve Financial Correctness (Priority: P1)

As a user, I want amount/currency edits to update conversion snapshots and reports correctly, so corrections do not leave stale totals.

**Why this priority**: Editing and immutable conversion snapshots must work together.

**Independent Test**: Edit a USD expense amount and verify the base-currency snapshot updates according to Plan 084 rules.

**Acceptance Scenarios**:

1. **Given** a converted expense has a snapshot, **When** amount or currency changes, **Then** conversion is recomputed or blocked with a missing-rate message.
2. **Given** only description changes, **When** the user saves, **Then** conversion snapshot is preserved.

---

### User Story 3 - Adjust Amount Quickly (Priority: P2)

As a user, I want a quick adjustment affordance for adding/subtracting money from an existing expense, so small corrections are faster than editing the whole form.

**Why this priority**: It supports the user's specific "add money or remove money" request.

**Independent Test**: Use quick adjustment to add 25 to an expense and verify the final amount, audit metadata, and totals update.

**Acceptance Scenarios**:

1. **Given** an expense amount is 300, **When** the user adds 25 through quick adjustment, **Then** the saved amount becomes 325.
2. **Given** the user subtracts more than the amount, **When** they confirm, **Then** validation blocks non-positive final amount.

### Edge Cases

- AI-created expenses must be editable like manual expenses.
- Pending sync expenses may be edited only if the queue can merge/update safely.
- Editing category should preserve historical category snapshot rules or update intentionally based on product decision.
- Edits must be localized and RTL-safe.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to edit existing expenses from Home and Expenses list entry points.
- **FR-002**: Edit form MUST expose all supported expense fields.
- **FR-003**: Amount adjustments MUST validate final amount is greater than zero.
- **FR-004**: Updates MUST go through repository update flows and sync queue in VPS mode.
- **FR-005**: Money field edits MUST follow conversion snapshot rules from Plan 084.
- **FR-006**: Edit and adjustment actions MUST show localized success/failure messages.
- **FR-007**: Pending/offline edits MUST remain retry-safe and not duplicate expenses.

### Key Entities

- **ExpenseEditDraft**: Editable copy of an expense before save.
- **AmountAdjustment**: User-intended delta or replacement amount.
- **ExpenseUpdateResult**: Save outcome including sync state and validation errors.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can edit amount and save from Home in under 15 seconds.
- **SC-002**: Edited amount is reflected in Home and Reports after refresh in 100% of tests.
- **SC-003**: AI-created and manual expenses use the same edit flow.
- **SC-004**: Invalid amount adjustments are blocked before repository update.

## Assumptions

- Existing delete/edit foundations from previous plans can be reused if present.
- This plan coordinates with Plan 084 for snapshot recalculation.
