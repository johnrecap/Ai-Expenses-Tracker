# Feature Specification: Subscription Center Upgrades

**Feature Branch**: `073-subscription-center-upgrades`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested stronger subscription center features around recurring expenses.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Understand Monthly Subscriptions (Priority: P2)

As a user, I need to see total monthly subscription impact, upcoming renewals, and renewal warnings.

**Why this priority**: Recurring spending is a major reason budgets drift.

**Independent Test**: Active recurring expenses produce an accurate monthly impact and upcoming-renewal list.

**Acceptance Scenarios**:

1. **Given** active monthly/weekly/daily recurring expenses, **When** Subscription Center opens, **Then** it shows estimated monthly impact.
2. **Given** a renewal in the next 7 days, **When** user opens the center, **Then** the renewal appears in upcoming list.

---

### User Story 2 - Spot Subscription Changes (Priority: P3)

As a user, I need to notice subscriptions that increased in price or look suspicious.

**Why this priority**: Price increases are high-value alerts but require careful data comparison.

**Independent Test**: Similar recurring rules or generated expenses with changed amount are flagged as possible increase.

**Acceptance Scenarios**:

1. **Given** a subscription amount increased, **When** the center recalculates, **Then** it flags the increase with old/new amount.
2. **Given** missing rates, **When** subscription totals are shown, **Then** caveats appear instead of silently summing currencies.

## Edge Cases

- Multiple currencies.
- Monthly recurrence on day 31.
- Paused/archived recurring rules.
- Weekly subscriptions converted to monthly estimate.
- Missing exchange rate.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Subscription Center MUST summarize active recurring expenses only.
- **FR-002**: Monthly impact MUST use documented currency policy and not silently add incompatible currencies.
- **FR-003**: Upcoming renewals MUST show next due dates.
- **FR-004**: Price change detection MUST be presented as a suggestion, not a certainty, unless data is exact.
- **FR-005**: Renewal notifications SHOULD integrate with existing notification settings when enabled.

### Key Entities

- **SubscriptionInsight**: Monthly impact, next due, status, caveats, and trend.
- **SubscriptionPriceChangeCandidate**: Current/previous amount, confidence, and reason.
- **UpcomingRenewal**: Rule, due date, amount, and notification status.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of active recurring rules appear in the Subscription Center.
- **SC-002**: Upcoming renewals within 7 days are identified in tests.
- **SC-003**: Mixed-currency monthly impact follows the shared currency policy or shows caveats.
- **SC-004**: Archived/paused rules are excluded from active impact.

## Assumptions

- Subscription Center remains based on explicit recurring expenses, not bank integrations.
- Price-change detection can start with explicit recurring rule history or generated expense comparison.

