# Feature Specification: Reports Currency Conversion

**Feature Branch**: `063-reports-currency-conversion`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User reported that Home totals convert USD to EGP correctly, but Reports still shows only `100 EGP` and says `1 expense in another currency ignored` for the same data.

## Problem

Reports, weekly charts, period comparison, AI summaries, and weekly digest use `ReportCalculator.calculate` with only a target currency string. That calculator filters out every expense whose currency is not equal to the target currency. Home already uses `MoneyConversionService` and `UserSettings.conversionRates`, so Home converts mixed currencies while Reports ignores them.

This creates a visible contradiction:

- Home: `50 USD` is converted into the base currency and included in monthly spending.
- Reports: the same `50 USD` is ignored, so weekly/monthly totals, top category, chart bars, period comparison, AI report summaries, and weekly digest are wrong.

## User Stories

### US1 - Reports Include Convertible Mixed Currencies (Priority: P1)

As a user with a base currency and saved daily rates, I want Reports totals to include expenses in other supported currencies after conversion, so weekly and monthly analytics match Home.

**Independent Test**: Given base currency `EGP`, conversion rate `USD: 53.232`, an expense `100 EGP`, and an expense `50 USD` in the same week, Reports weekly total is `2761.6 EGP`, chart bucket includes both expenses, top category is based on converted totals, and no ignored-currency warning appears for USD.

### US2 - Previous Period Comparison Uses Converted Totals (Priority: P1)

As a user comparing this week/month against the previous period, I want both periods converted using the same saved rates, so the delta percent is not based only on same-currency expenses.

**Independent Test**: Given current and previous expenses in USD and EGP, `previousTotal`, `total`, and `deltaPercent` are calculated in the base currency after conversion.

### US3 - AI Summary And Weekly Digest Match Reports (Priority: P2)

As a user using AI summary/advice or weekly digest, I want the totals to match Reports, so the app does not give conflicting numbers.

**Independent Test**: AI summary/advice and weekly digest call the same report conversion path and include convertible mixed-currency expenses.

## Functional Requirements

- **FR-001**: `ReportCalculator` MUST accept `UserSettings` or an equivalent conversion context, not just a currency string.
- **FR-002**: Reports MUST use `settings.baseCurrency` as the report currency.
- **FR-003**: Expenses in the base currency MUST be included without conversion.
- **FR-004**: Expenses in other currencies MUST be converted using the same `MoneyConversionService` and `UserSettings.conversionRates` used by Home.
- **FR-005**: Expenses whose currencies have no valid saved rate MUST remain excluded and counted as ignored.
- **FR-006**: Weekly and monthly chart buckets MUST sum converted amounts in the report currency.
- **FR-007**: Category totals and top category MUST be based on converted amounts, not raw source-currency amounts.
- **FR-008**: Previous period totals and delta percent MUST be based on converted amounts for both current and previous ranges.
- **FR-009**: Reports UI MUST stop showing ignored-currency warnings for currencies that were successfully converted.
- **FR-010**: Reports UI SHOULD show a concise converted-currency note when non-base currencies were included, matching Home behavior where practical.
- **FR-011**: AI summary, AI advice, and weekly digest MUST either pass `UserSettings` into `ReportCalculator` or use a wrapper that does.
- **FR-012**: Existing same-currency report behavior MUST remain unchanged when there are no mixed-currency expenses.

## Non-Goals

- Fetching live exchange rates is not part of this plan; Plan 060 owns daily exchange-rate cache and refresh.
- Historical exchange rates per transaction date are not part of this plan; this plan uses the saved current daily rate already stored in settings.
- Category budgets and subscription monthly impact conversion are not part of this plan unless explicitly pulled in later.
- Changing the visual design of Reports charts is not part of this plan.

## Success Criteria

- Reports weekly/monthly totals match Home-style conversion for the same base currency and saved rates.
- The screenshot scenario no longer shows `1 expense in another currency ignored` for USD when a valid USD rate exists.
- Targeted tests cover mixed-currency weekly reports, monthly reports, chart buckets, category totals, previous-period comparison, missing-rate warnings, ReportCubit settings wiring, AI summary/advice, and weekly digest.

