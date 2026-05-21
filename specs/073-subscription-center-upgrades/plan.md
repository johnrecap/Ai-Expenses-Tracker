# Implementation Plan: Subscription Center Upgrades

**Branch**: `073-subscription-center-upgrades` | **Date**: 2026-05-20 | **Spec**: `specs/073-subscription-center-upgrades/spec.md`

## Summary

Upgrade Subscription Center from a simple recurring summary into a practical recurring-spend surface: monthly impact, upcoming renewals, caveats, optional notifications, and conservative price-change signals.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Recurring expense repository, `SubscriptionSummaryService`, notification service, finance conversion policy  
**Storage**: Existing recurring expense documents; optional history fields if price-change detection needs them  
**Testing**: Subscription summary service tests, UI tests, notification scheduling tests  
**Target Platform**: Flutter mobile  
**Project Type**: Recurring/subscription UX improvement  
**Performance Goals**: Local summary over active recurring rules  
**Constraints**: No bank integration; no silent mixed-currency summing  
**Scale/Scope**: Active recurring rules for one user

## Constitution Check

- Subscription summaries read active recurring rules only: PASS.
- Mixed-currency calculations follow documented policy: PASS.
- Notification scheduling uses service abstraction: PASS.
- Archived rules do not affect generated past expenses: PASS.

## Project Structure

```text
lib/screens/subscriptions/
lib/screens/recurring_expenses/
lib/services/notifications/
packages/expense_repository/lib/src/models/recurring_expense.dart
test/subscriptions/
test/recurring_expenses/
test/services/
```

## Implementation Strategy

1. Extend summary model with upcoming renewals and caveats.
2. Align monthly impact with shared currency policy.
3. Add renewal window and optional notification integration.
4. Add conservative price-change candidate logic.
5. Localize and test.

## Risks

- Monthly estimates can be misleading for weekly/daily recurrence. Mitigation: label estimates.
- Price changes may be inferred incorrectly. Mitigation: show candidates with confidence/reason.

## Deferred Items Considered

Related deferred item: decide whether subscription monthly impact should convert mixed currencies instead of same-currency warnings.

