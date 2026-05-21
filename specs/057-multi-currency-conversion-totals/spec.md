# Feature Specification: Multi-Currency Conversion Totals

**Feature Branch**: `057-multi-currency-conversion-totals`
**Created**: 2026-05-19
**Status**: Draft
**Input**: User reports that when the base currency is USD and an expense is entered in EGP, Home shows `100 EGP + 1 other` instead of converting the EGP value into the base currency total.

## User Scenarios & Testing

### User Story 1 - Home Totals Convert To Base Currency (Priority: P1)

As a user with a base currency, I want monthly spending, budget remaining, and top category on Home to include expenses in supported currencies after conversion, so the dashboard reflects my real spending instead of ignoring other currencies.

**Independent Test**: Set base currency to USD, add a monthly expense of 100 EGP, configure an EGP to USD rate, and verify the Home spending card displays the converted USD total without `+ 1 other`.

**Acceptance Scenarios**:

1. **Given** base currency is USD and EGP has a valid conversion rate, **When** the user has a 100 EGP expense in the current month, **Then** Home includes its converted USD value in the monthly spending total.
2. **Given** Home budget is stored in the base currency, **When** converted spending is calculated, **Then** budget remaining uses the converted base-currency total.
3. **Given** multiple categories contain mixed-currency expenses with rates, **When** Home calculates top category, **Then** top category is based on converted base-currency totals.

---

### User Story 2 - Missing Rates Are Explicit And Safe (Priority: P1)

As a user, I need the app to avoid fake exchange math when a rate is unknown, so I can trust the financial total.

**Independent Test**: Add an EGP expense while base currency is USD and no EGP rate exists. Home should keep the base-currency total accurate for convertible expenses and show a clear unconverted-currency warning.

**Acceptance Scenarios**:

1. **Given** an expense currency has no configured conversion rate, **When** Home calculates totals, **Then** that expense is not added to the base total.
2. **Given** one or more expenses are unconverted, **When** Home displays the spending card, **Then** it shows a concise warning or breakdown naming the unconverted currencies instead of a vague `+ other`.
3. **Given** the missing rate is later configured, **When** Home rebuilds, **Then** the same expense is included in the base total without editing the expense.

---

### User Story 3 - User Can Manage Exchange Rates (Priority: P2)

As a user, I want to maintain exchange rates for my supported currencies relative to my base currency, so currency conversion works without relying on unavailable external services.

**Independent Test**: From Settings, add USD as base and EGP as supported, enter the EGP conversion rate, save, close Settings, and verify the rate is still used by Home.

**Acceptance Scenarios**:

1. **Given** a supported currency is not the base currency, **When** the user opens currency settings, **Then** the user can enter the rate used to convert that currency into the base currency.
2. **Given** a rate is empty, zero, or invalid, **When** the user saves, **Then** the app rejects it with a localized validation message.
3. **Given** the base currency changes, **When** Settings reloads, **Then** rates are revalidated so the base currency rate is always 1 and stale incompatible rates are not silently trusted.

## Requirements

### Functional Requirements

- **FR-001**: Home monthly spending MUST convert supported non-base currency expenses into `UserSettings.baseCurrency` when a valid user-scoped conversion rate exists.
- **FR-002**: Home budget remaining MUST use the converted base-currency spending total when the budget currency matches the base currency.
- **FR-003**: Home top category MUST be calculated from converted base-currency category totals for convertible expenses.
- **FR-004**: Home MUST not add expenses whose currency cannot be converted.
- **FR-005**: Home MUST show a clear mixed-currency status that distinguishes converted currencies from unconverted currencies.
- **FR-006**: Settings MUST allow the user to view and edit conversion rates for supported non-base currencies.
- **FR-007**: Conversion rates MUST be persisted per user with settings and loaded without requiring app restart.
- **FR-008**: Conversion rate input MUST accept decimal values and reject zero, negative, empty, or non-numeric values.
- **FR-009**: Existing expenses MUST retain their original currency and amount; conversion affects aggregate display only.
- **FR-010**: If no conversion rate is available, the UI MUST keep the current safe behavior of not adding incompatible currencies, but must replace vague `+ other` wording with actionable text.

### Key Entities

- **CurrencyConversionRate**: A user-scoped setting keyed by source currency, target base currency, rate value, and last updated time.
- **ConvertedMoney**: A calculated value containing original amount/currency, converted amount/base currency, and conversion status.
- **HomeSummary**: Existing Home summary extended with converted totals and unconverted currency breakdown.

## Success Criteria

- **SC-001**: A current-month 100 EGP expense with base USD and rate `0.02` contributes `2.00 USD` to Home monthly spending.
- **SC-002**: Home no longer displays `+ 1 other` for expenses that have valid conversion rates.
- **SC-003**: Missing rates are visible to the user within Home or Settings in one interaction, without hidden incorrect totals.
- **SC-004**: Existing Home summary tests cover same-currency, converted-currency, and missing-rate cases.

## Assumptions

- MVP conversion rates are user-managed and persisted locally in user settings.
- Live exchange-rate fetching is deferred until an external provider and refresh policy are chosen.
- Conversion is for dashboard/reporting totals only; the original expense amount and currency remain unchanged.

## Out of Scope

- Automatic live exchange-rate sync.
- Historical per-day exchange rates for old expenses.
- Rewriting stored expense amounts.
- Applying conversion to exports, reports, category budgets, subscriptions, and saving goals in this first pass unless explicitly added later.
