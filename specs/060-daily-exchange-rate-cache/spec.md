# Feature Specification: Daily Exchange Rate Cache

**Feature Branch**: `060-daily-exchange-rate-cache`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User description: "التطبيق يعمل تحديث لسعر العملات المتاحه في التطبيق بشكل يومي مره واحده في اليوم ويتم حفظها في التطبيق تلقائي والعمله تفضل علي السعر ده بقيه اليوم ولو التلفون متوصلش بالنت لفتره طويله يفضل السعر ده هوه الاساسي لحد لمه يتم التوصيل بالانترنت ويتم تحديث سعر العملات"

## User Scenarios & Testing

### User Story 1 - Daily Cached Rates (Priority: P1)

As a user with multiple currencies enabled, I want the app to refresh exchange rates automatically once per day and use the saved rates for all same-day calculations so totals stay consistent and are not recalculated differently on every screen rebuild.

**Why this priority**: This removes incorrect fixed-rate behavior and makes multi-currency totals predictable for normal daily use.

**Independent Test**: With EGP as base currency and USD enabled, open Home after the saved rate is stale; the app fetches a current USD-to-EGP rate, saves it, and Home uses that saved rate for monthly spending and budget progress.

**Acceptance Scenarios**:

1. **Given** the user has USD enabled and no exchange-rate refresh has happened today, **When** Home loads with internet available, **Then** the app refreshes USD against the base currency and saves the rate with today's refresh date.
2. **Given** exchange rates were refreshed earlier today, **When** Home rebuilds multiple times, **Then** the app uses the saved rates and does not request another refresh that day.
3. **Given** a USD expense and EGP base currency, **When** a saved USD rate exists, **Then** Home and monthly budget totals include the converted EGP amount.

---

### User Story 2 - Offline Continuity (Priority: P2)

As a user without internet, I want the app to keep using the last saved exchange rates instead of blocking totals or inventing new values.

**Why this priority**: Users may be offline for days, and finance totals should remain usable from the latest trusted data.

**Independent Test**: Save rates, simulate a stale refresh date, make the refresh fail, and verify Home still calculates with the saved rates.

**Acceptance Scenarios**:

1. **Given** saved exchange rates exist but are older than today, **When** the app cannot reach the exchange-rate provider, **Then** the saved rates remain in use and are not erased.
2. **Given** no saved rate exists for a currency and the refresh fails, **When** Home calculates totals, **Then** the currency is shown as missing instead of using a fake or fixed rate.

---

### User Story 3 - Supported Currency Scope (Priority: P3)

As a user managing supported currencies, I want automatic refresh to cover only the currencies currently enabled in the app so network usage and saved data stay small.

**Why this priority**: Refreshing only active currencies avoids unnecessary requests and keeps stored settings aligned with the user's selected currencies.

**Independent Test**: Enable EGP, USD, and EUR; trigger a stale refresh; verify only USD and EUR rates are requested for EGP base and saved.

**Acceptance Scenarios**:

1. **Given** EGP is the base currency and USD/EUR are enabled, **When** daily refresh runs, **Then** it requests and saves rates for USD and EUR only.
2. **Given** the user removes EUR from supported currencies, **When** settings are saved, **Then** stale EUR rates are filtered out by existing supported-currency rules.

### Edge Cases

- The base currency itself must never be saved as a conversion rate.
- A provider error, timeout, invalid currency, or invalid rate must leave existing saved rates unchanged.
- Multiple Home rebuilds on the same day must not cause repeated provider calls.
- If a provider returns a partial result, only valid positive rates may be saved.
- Existing users without `exchangeRatesUpdatedAt` should be treated as needing refresh, but their existing manual/saved `conversionRates` should still work until refresh succeeds.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST refresh exchange rates for supported non-base currencies at most once per local calendar day.
- **FR-002**: The app MUST save successful refreshed rates in the user's settings automatically.
- **FR-003**: The app MUST use saved exchange rates for Home monthly spending and budget progress calculations throughout the day.
- **FR-004**: The app MUST keep the last saved rates when refresh fails because the phone is offline, the provider times out, or the provider returns an error.
- **FR-005**: The app MUST not use hardcoded exchange-rate values as a fallback.
- **FR-006**: The app MUST not erase existing rates when a daily refresh fails.
- **FR-007**: The app MUST consider rates stale when no refresh timestamp exists or when the saved refresh date is before the current local date.
- **FR-008**: The app MUST update the saved refresh timestamp only after at least one valid provider rate is saved or after a successful provider call confirms the requested currency set has no non-base currencies.
- **FR-009**: The app MUST preserve manual/saved rates for currencies not refreshed due to provider failure, while replacing rates for currencies that refresh successfully.
- **FR-010**: The app MUST validate provider rates as positive finite numeric values before saving them.

### Key Entities

- **Exchange Rate Cache**: The saved conversion-rate map in user settings plus an exchange-rate refresh timestamp.
- **Supported Currency Set**: The user's base currency and enabled supported currencies that determine which rates should be refreshed.
- **Daily Refresh State**: Whether saved exchange rates are fresh for the current local day.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A user opening Home repeatedly on the same day triggers no more than one successful exchange-rate refresh attempt for that day.
- **SC-002**: After a successful daily refresh, multi-currency Home totals and budget progress include converted amounts using the saved rates.
- **SC-003**: If the phone is offline after a previous successful refresh, totals continue to use the last saved rates for 100% of enabled currencies that have saved rates.
- **SC-004**: If no saved rate exists and refresh fails, the app reports the missing rate instead of calculating with a fabricated value.

## Assumptions

- "Once per day" uses the device's local calendar day, matching the user's app experience.
- The existing `conversionRates` map stores the value of one unit of the source currency in the current base currency.
- Existing settings storage is the correct persistence point because it is user-scoped and already used by Home and Add Expense.
- Provider selection, manual refresh UI, historical rates per expense date, and freshness indicators are deferred beyond this MVP.
