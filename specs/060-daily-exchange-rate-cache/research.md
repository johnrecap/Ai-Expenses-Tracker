# Research: Daily Exchange Rate Cache

## Decision: Persist refreshed rates in UserSettings

**Rationale**: `UserSettings` already stores `baseCurrency`, `supportedCurrencies`, and `conversionRates`, and Home already consumes settings. Adding a refresh timestamp keeps all exchange-rate state user-scoped and avoids a new local database dependency.

**Alternatives considered**:

- Separate local file/cache: rejected because it would duplicate settings state and complicate tests.
- Fetch live on every Home build: rejected because the user explicitly wants once-per-day refresh.
- Hardcoded fallback rates: rejected because rates change daily and fabricated values are financially misleading.

## Decision: Use Frankfurter only as a refresh source, not as the calculation source

**Rationale**: Provider calls should update cached settings. Calculations should use saved rates so totals are stable throughout the day and remain available offline.

**Alternatives considered**:

- Calculate directly from live provider results on every view: rejected because totals could change within the same day and fail offline.
- Require manual settings entry only: rejected because the user wants automatic updates.

## Decision: Local calendar day controls refresh cadence

**Rationale**: The user phrased the requirement as daily app behavior. Device-local day is understandable and avoids timezone complexity for an MVP.

**Alternatives considered**:

- Provider date: deferred because it requires richer freshness display.
- 24-hour rolling interval: rejected because it can surprise users who expect "today" to mean calendar day.

## Decision: Failed refresh preserves saved rates

**Rationale**: Offline continuity is the core requirement. Existing saved rates are trusted until a new successful refresh replaces them.

**Alternatives considered**:

- Clear stale rates on failure: rejected because it breaks offline use.
- Block Home until refresh succeeds: rejected because finance tracking must remain usable offline.
