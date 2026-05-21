# Feature Specification: Language And Currency Preferences

**Feature Branch**: `041-language-currency-preferences`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User request to decouple application language from currency, remove silent situational defaults, and make AI, voice, dates, and settings respect explicit user choices.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose Language Independently (Priority: P1)

A signed-in user chooses the app language from settings without changing their money currency. The user can choose Arabic, English, or follow the device language, and the app text, date formatting, RTL direction, AI locale, and voice dictation preference follow that language choice.

**Why this priority**: Language controls the entire app experience and must not be inferred from currency. Without this, an Arabic user who tracks USD or an English user who tracks EGP gets inconsistent UI and AI behavior.

**Independent Test**: Set language to Arabic while base currency remains USD, restart the app, and verify the UI is Arabic/RTL while amounts still use USD defaults.

**Acceptance Scenarios**:

1. **Given** a user has base currency `USD`, **When** they set app language to Arabic, **Then** UI strings, text direction, date formatting, AI locale, and voice locale use Arabic while the base currency remains `USD`.
2. **Given** a user has base currency `EGP`, **When** they set app language to English, **Then** UI strings, text direction, date formatting, AI locale, and voice locale use English while the base currency remains `EGP`.
3. **Given** the user chooses "System", **When** the device language changes between Arabic and English, **Then** the app follows the device language without modifying base currency.

---

### User Story 2 - Choose Currency Independently (Priority: P1)

A user chooses a base currency and supported currencies from settings without changing the app language. New manual expenses and AI previews use the base currency only when the user does not explicitly mention another currency.

**Why this priority**: Expense totals, budgets, reports, and AI defaults depend on the user's financial preference. Currency must be controlled by user intent, not locale assumptions.

**Independent Test**: Set app language to Arabic and base currency to USD, then create a manual expense without currency and verify USD is used. Then enter an AI sentence with "جنيه" and verify the preview uses EGP because the user explicitly mentioned it.

**Acceptance Scenarios**:

1. **Given** base currency is `USD`, **When** a manual Add Expense form opens, **Then** the currency field defaults to `USD`.
2. **Given** base currency is `USD`, **When** the AI parses "صرفت 100 جنيه على مواصلات", **Then** the AI preview uses `EGP` because the user explicitly mentioned Egyptian pounds.
3. **Given** base currency is `EGP`, **When** the AI parses "spent 20 dollars on food", **Then** the AI preview uses `USD` because the user explicitly mentioned dollars.
4. **Given** a user removes all supported currencies except the base currency, **When** they save settings, **Then** the base currency remains included and the app does not allow an empty supported-currency list.

---

### User Story 3 - Avoid Silent Fallbacks (Priority: P2)

If settings cannot be loaded or mandatory preferences are missing, the app should show a clear retry or setup path rather than silently assuming `EGP`, `Cash`, or Arabic.

**Why this priority**: Silent defaults create wrong financial data and make debugging hard. Users should understand when the app is missing setup data.

**Independent Test**: Simulate settings load failure and verify the app presents a clear message with retry/setup actions instead of silently using default currency/payment/language in a way that can save incorrect expenses.

**Acceptance Scenarios**:

1. **Given** user settings fail to load, **When** the AI Assistant opens, **Then** the app shows a non-blocking setup warning and prevents AI preview from silently using unknown defaults.
2. **Given** user settings fail to load, **When** Add Expense opens, **Then** the form asks the user to retry settings or choose temporary values before saving.
3. **Given** a legacy user has no stored language preference, **When** the app loads settings, **Then** the app treats language as "System" and does not change stored currency.

### Edge Cases

- Existing users who already have `baseCurrency` but no language preference should migrate to `System` language without losing currency, supported currencies, default payment method, or notification settings.
- AI parsed currency must beat base currency. Base currency is fallback only.
- Voice recognition locale should only request a locale supported by the device; otherwise it should use the plugin default without failing the AI text input.
- Unsupported explicit AI currency values should appear as editable preview text only if they pass a safe ISO-style currency-code validation; otherwise the user must clarify.
- Settings save failure must restore the previous visible state and show an error.
- App language changes should update visible UI after save without requiring a full reinstall.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store an app language preference per user with values `system`, `en`, and `ar`.
- **FR-002**: System MUST preserve existing `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, and notification settings when adding language preference to legacy settings documents.
- **FR-003**: Users MUST be able to change app language from Settings without changing base currency.
- **FR-004**: Users MUST be able to change base currency from Settings without changing app language.
- **FR-005**: System MUST apply app language preference to app localization, text direction, date formatting, AI request locale, and preferred voice recognition locale.
- **FR-006**: System MUST use `baseCurrency` only as a default when a manual or AI-created expense does not explicitly specify currency.
- **FR-007**: System MUST preserve explicit user-entered or AI-parsed currency values even when they differ from base currency.
- **FR-008**: System MUST keep `baseCurrency` included in `supportedCurrencies`.
- **FR-009**: System MUST not save an expense using fallback settings if user settings are unavailable and the save depends on missing currency or payment defaults.
- **FR-010**: System MUST show clear error and retry/setup options when settings cannot be loaded.
- **FR-011**: Settings UI MUST explain that currency conversion is not performed yet; mixed-currency totals remain conservative.
- **FR-012**: Tests MUST cover language/currency independence, settings migration, AI locale propagation, and no-silent-fallback behavior.

### Key Entities

- **LanguagePreference**: User-selected language mode. Values: `system`, `en`, `ar`. Determines UI locale and AI/voice locale hints.
- **UserSettings**: User profile settings containing language preference, base currency, supported currencies, default payment method, notification settings, and update timestamp.
- **AiContext**: Per-request assistant context containing user id, settings-derived default currency/payment method, active categories, expenses, budget, and locale.
- **SettingsLoadState**: UI state that indicates whether settings are loaded, saving, failed, or require setup.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of new AI parse, receipt, and advice requests include locale derived from app language preference rather than a hardcoded locale.
- **SC-002**: Users can change language and currency independently in under 30 seconds from Settings.
- **SC-003**: Existing settings documents without language preference continue loading with no data loss.
- **SC-004**: Automated tests cover at least one Arabic+USD and one English+EGP combination.
- **SC-005**: No save path for a new expense silently uses `EGP` or `Cash` after settings load failure.

## Assumptions

- Supported app languages remain Arabic and English for this plan.
- Currency conversion remains out of scope; reports and budgets keep existing same-currency aggregation rules.
- `system` language preference means the app follows Flutter/device locale resolution.
- If the device lacks the requested voice locale, voice input remains available using the plugin default.
- This plan should be implemented before first-run onboarding and guided-tour plans so those flows can use the same settings model.

