# Feature Specification: Home And Settings Live Data

**Feature Branch**: `[021-home-settings-live-data]`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User reports Home total balance card is not correctly tied to actual data and Settings are not working well.

## User Scenarios & Testing

### User Story 1 - Home Dashboard Uses Real User Data (Priority: P1)

As a user, I want the Home card to reflect my actual expenses, budget, currency, and profile instead of hardcoded values like `John Doe` or fake income.

**Why this priority**: Home is the main screen; fake values undermine trust in the expense tracker.

**Independent Test**: Create expenses, set a monthly budget, change base currency, reopen Home, and verify every number and label reflects actual data.

**Acceptance Scenarios**:

1. **Given** the user has 250 EGP expenses this month and budget 1,000 EGP, **When** Home opens, **Then** it shows spent 250 EGP and budget remaining 750 EGP.
2. **Given** the user has no budget, **When** Home opens, **Then** it does not show fake income and instead shows monthly spending and a prompt to set a budget.
3. **Given** the authenticated user display name is Saeed, **When** Home opens, **Then** the welcome text says Saeed, not John Doe.

---

### User Story 2 - Settings Persist And Affect App Behavior (Priority: P1)

As a user, I want settings changes such as base currency, default payment method, supported currencies, notifications, app protection, and AI preferences to save and affect the app immediately.

**Why this priority**: Settings currently appear present but not all settings are complete or visibly connected to app behavior.

**Independent Test**: Change a setting, leave the screen, return, and verify the value remains and affects Add Expense, AI preview, Home, notifications, and protection where applicable.

**Acceptance Scenarios**:

1. **Given** base currency is EGP, **When** the user changes it to USD, **Then** new expense defaults and Home labels use USD where conversion is not required.
2. **Given** default payment method is Cash, **When** the user changes it to Wallet, **Then** Add Expense and AI preview default to Wallet when payment is not specified.
3. **Given** daily reminders are disabled, **When** the app syncs notification settings, **Then** no daily reminder is scheduled.

---

### User Story 3 - Settings UX Is Organized (Priority: P2)

As a user, I want settings grouped into clear sections: profile, currency/payment, notifications, app protection, AI usage, ads/premium, and privacy.

**Why this priority**: More features are being added; settings need a scalable structure before monetization and ads.

## Requirements

### Functional Requirements

- **FR-001**: Home MUST not display hardcoded user name, income, total balance, or static financial numbers.
- **FR-002**: Home MUST show a clearly defined metric: monthly spending, budget remaining when budget exists, and mixed-currency warning when needed.
- **FR-003**: Home MUST use `AuthAuthenticated.user` for display name/email fallback.
- **FR-004**: Home MUST use `UserSettings.baseCurrency` as the default currency context.
- **FR-005**: Settings MUST load, save, and re-render persisted settings through `SettingsRepository`.
- **FR-006**: Supported currencies MUST be editable by the user with validation that base currency remains included.
- **FR-007**: Default payment method MUST affect Add Expense and AI preview defaults.
- **FR-008**: Notification settings MUST keep scheduling in sync after save.
- **FR-009**: Settings MUST include a future-safe AI usage section that can display daily free limits and remaining usage when available.
- **FR-010**: Settings MUST include a future-safe premium/ads section placeholder that does not pretend purchases are active before Plan 023 is implemented.

### Key Entities

- **HomeSummary**: User-facing computed data: period, spending, budget, remaining, currency state, top category, pending sync count.
- **SettingsSectionState**: Grouped UI state for profile, currency/payment, notifications, protection, AI, monetization, and privacy.
- **UserSettings Extension**: Supported currencies and optional AI/preference fields if needed.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Home has zero hardcoded financial values after implementation.
- **SC-002**: Changing base currency or default payment method persists and is visible after app restart.
- **SC-003**: Mixed-currency Home state avoids adding incompatible currencies together 100% of the time.
- **SC-004**: Settings save failures show a recoverable message and leave previous values intact.

## Assumptions

- Income tracking is not implemented yet; Home should not show fake income.
- Currency conversion is still out of scope; mixed currencies must be shown conservatively.
- Existing `SettingsRepository` remains the persistence boundary.
