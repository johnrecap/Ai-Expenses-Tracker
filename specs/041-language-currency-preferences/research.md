# Research: Language And Currency Preferences

## Decision: Store Language Preference In UserSettings

**Rationale**: Settings already own base currency, supported currencies, payment method, and notifications. Language belongs with user preferences and can migrate safely with a default of `system`.

**Alternatives considered**:

- Store language locally only: rejected because signed-in users expect preferences to follow their account.
- Infer from device every time: rejected because the user asked for explicit control.
- Infer from currency: rejected because Arabic+USD and English+EGP are valid combinations.

## Decision: Use Three Language Modes

**Rationale**: `system`, `en`, and `ar` cover the current supported locales while letting users choose either explicit language or device-following behavior.

**Alternatives considered**:

- Boolean Arabic/English only: rejected because users may want system behavior.
- Free-form locale entry: rejected because only Arabic and English are currently localized.

## Decision: Base Currency Is Fallback Only

**Rationale**: User-entered or AI-parsed currency is stronger intent than settings default. Base currency should fill missing currency, not overwrite explicit currency.

**Alternatives considered**:

- Always convert parsed currency to base currency: rejected because conversion is not implemented and would silently corrupt values.
- Reject all non-base currencies: rejected because the app already supports multiple currencies and conservative mixed-currency reporting.

## Decision: Locale Travels Through AiContext

**Rationale**: AI parse, receipt, advice, and voice should receive the same locale source. `AiContext` already carries settings-derived defaults and is the right boundary between UI and services.

**Alternatives considered**:

- Read `Localizations.localeOf(context)` inside every AI widget/service: rejected because service tests become harder and widget/service boundaries blur.
- Keep `ar-EG` hardcoded: rejected because English users and future locales would get wrong AI behavior.

## Decision: Settings Failures Need Visible Recovery

**Rationale**: Silent defaults can create wrong expenses. The user explicitly rejected situational fallback behavior.

**Alternatives considered**:

- Continue current fallback to `EGP`/`Cash`: rejected because it hides data-risk conditions.
- Block the entire app when settings fail: rejected because existing read-only/manual flows should remain usable where explicit values are available.

