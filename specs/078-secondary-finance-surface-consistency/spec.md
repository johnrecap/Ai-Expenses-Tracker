# Feature Specification: Secondary Finance Surface Consistency

**Feature Branch**: `078-secondary-finance-surface-consistency`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: Review found Home and Reports use conversion, while Category Budgets, Subscription Center, Export, and some AI/digest text still need a consistency pass.

## User Scenarios & Testing

### User Story 1 - Category budgets use the same money rules (Priority: P1)

As a user with category budgets and mixed-currency expenses, I want category budget progress to include convertible expenses and clearly warn only about missing rates, so budget status matches Home and Reports.

**Why this priority**: A budget can show the wrong remaining amount if it ignores convertible expenses.

**Independent Test**: A category budget in EGP with EGP and USD expenses shows converted USD in spent total when USD rate exists, and warns only when a rate is missing.

### User Story 2 - Subscription summaries explain currency impact correctly (Priority: P1)

As a user with recurring subscriptions in different currencies, I want Subscription Center to calculate monthly impact consistently or clearly show conservative caveats, so I do not underestimate monthly commitments.

**Why this priority**: Subscriptions are recurring financial obligations; bad totals create repeated user harm.

**Independent Test**: A monthly subscription list with EGP and USD rules shows a base-currency monthly impact when rates exist and a missing-rate caveat when not.

### User Story 3 - Exports preserve original amounts and include conversion metadata (Priority: P2)

As a user exporting finance records, I want original currency data preserved and conversion metadata included when totals are shown, so exported files are auditable and do not silently mix currencies.

**Why this priority**: Exports are used outside the app; unclear converted totals can become misleading records.

**Independent Test**: CSV/Excel/PDF exports include original amount/currency and, where totals are included, converted base amount, base currency, rate, and rate date or a missing-rate warning.

## Requirements

- **FR-001**: Category Budget calculations MUST use the shared financial calculation service when the budget currency equals the user's base currency.
- **FR-002**: Category Budget UI MUST distinguish converted included expenses from missing-rate excluded expenses.
- **FR-003**: Subscription Center MUST either convert monthly impact through the shared calculation rules or group totals by currency with a clear missing-rate caveat; it MUST NOT silently add different currencies.
- **FR-004**: Export outputs MUST preserve original amount and currency for every transaction.
- **FR-005**: Export outputs that show summary totals MUST include base-currency totals only when conversion metadata is available.
- **FR-006**: AI/digest evidence that references totals MUST use the same converted report/budget data as the visible UI.
- **FR-007**: All new warnings MUST be localized through ARB if user-visible.
- **FR-008**: Historical-rate accuracy remains deferred; this plan uses currently saved daily rates consistently.

## Key Entities

- **FinanceSurface**: Category Budget, Subscription Center, Export, AI evidence, or digest summary.
- **ConvertedFinanceResult**: Total plus converted currencies, unconverted currencies, and rate timestamp.
- **ExportConversionMetadata**: Original amount/currency plus converted amount/currency/rate/rate date.

## Success Criteria

- **SC-001**: Mixed-currency category budget tests pass for valid and missing rates.
- **SC-002**: Subscription monthly impact tests pass for valid and missing rates.
- **SC-003**: Export tests prove original values are preserved and conversion metadata is present where totals are shown.
- **SC-004**: No reviewed surface displays "ignored other currencies" when rates exist and conversion succeeded.

## Assumptions

- Daily cached exchange rates remain the source of truth until historical rate support is planned.
- Budgets in currencies other than the user's base currency may keep conservative same-currency behavior unless this plan explicitly converts them.

