# Feature Specification: Category Budgets And Subscription Center

**Feature Branch**: `033-category-budgets-subscriptions`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Recommended retention/product improvements include category-level budgets and recurring subscription visibility.

## User Scenarios & Testing

### User Story 1 - Category Budgets (Priority: P1)

A user sets monthly limits for specific categories like Food, Transport, Bills, or Shopping.

**Why this priority**: Category-level control is more actionable than one overall monthly budget.

**Independent Test**: Set a category budget and add expenses in/out of that category; confirm progress updates.

**Acceptance Scenarios**:

1. **Given** Food budget is 3000 EGP for May, **When** user spends 2400 EGP on Food, **Then** category budget shows 80% used.
2. **Given** Transport has no category budget, **When** transport expenses exist, **Then** app shows no false warning for that category.

---

### User Story 2 - Subscription Center (Priority: P2)

A user can see recurring subscriptions and bills in one place, with upcoming due dates and monthly impact.

**Why this priority**: Subscriptions are a major repeat expense and bring users back before charges happen.

**Independent Test**: Seed recurring expenses and confirm subscription center lists upcoming charges.

**Acceptance Scenarios**:

1. **Given** monthly internet recurring expense exists, **When** user opens subscription center, **Then** it shows next due date and amount.
2. **Given** recurring expense is paused/archived, **When** center opens, **Then** it does not count as active upcoming charge.

---

### User Story 3 - Local Alerts For Category And Subscription Risk (Priority: P3)

The user receives local, optional alerts when a category budget is near/exceeded or a subscription is due soon.

**Why this priority**: Timely reminders create practical return visits.

**Independent Test**: Set thresholds and due dates; verify scheduler creates/cancels notifications.

**Acceptance Scenarios**:

1. **Given** Food budget reaches 90%, **When** alerts are enabled, **Then** app schedules or shows a warning.
2. **Given** subscription due tomorrow, **When** due reminders are enabled, **Then** user receives a local notification.

### Edge Cases

- Mixed currencies must not be added without conversion.
- Archived categories/recurring rules must not create new budget alerts.
- Category budget month boundaries must match existing monthly budget conventions.

## Requirements

### Functional Requirements

- **FR-001**: Users MUST be able to create, edit, and remove/archive monthly category budgets.
- **FR-002**: Category budget progress MUST calculate from user-owned expenses for the selected month and matching active category.
- **FR-003**: Mixed-currency category budgets MUST show a warning or separate totals unless conversion is implemented.
- **FR-004**: Subscription center MUST list active recurring expenses with amount, category, payment method, frequency, and next due date.
- **FR-005**: Paused or archived recurring expenses MUST not be counted as active subscriptions.
- **FR-006**: Category and subscription alerts MUST be optional and respect notification permissions.
- **FR-007**: Data MUST remain under `users/{userId}`.

### Key Entities

- **CategoryBudget**: User-owned monthly limit for one category/currency/month.
- **CategoryBudgetProgress**: Spent, limit, remaining, percentage, warning/exceeded state.
- **SubscriptionSummary**: Active recurring expense plus next due date and monthly impact.
- **BudgetAlertPreference**: Thresholds and notification toggles.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can create a category budget in under 30 seconds.
- **SC-002**: Budget progress updates after adding an expense in that category.
- **SC-003**: Subscription center lists active recurring expenses with correct next due date.
- **SC-004**: Category/subscription alerts do not fire for archived or paused items.

## Assumptions

- Existing monthly budget remains as overall budget.
- Existing recurring expense repository and scheduler are available.
- Currency conversion remains future work; this plan uses same-currency calculations only.
