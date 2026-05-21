# Data Model: Language And Currency Preferences

## LanguagePreference

Represents the user's preferred app language mode.

Fields:

- `value`: string enum, one of `system`, `en`, `ar`.
- `resolvedLocale`: runtime-only value derived from `value` plus device locale.

Validation:

- Unknown stored values must fall back to `system`.
- `en` maps to English locale.
- `ar` maps to Arabic locale and RTL direction.
- `system` uses the platform locale resolution already supported by the app.

## UserSettings

Existing user settings profile extended with language preference.

Fields:

- `userId`: owner id.
- `languagePreference`: `LanguagePreference`, default `system`.
- `baseCurrency`: uppercase currency code, default from onboarding or legacy `EGP`.
- `supportedCurrencies`: non-empty uppercase currency list that always includes `baseCurrency`.
- `defaultPaymentMethod`: existing payment method enum.
- `notificationSettings`: existing notification settings.
- `updatedAt`: last update timestamp.

Migration:

- Existing Firestore documents without `languagePreference` load as `system`.
- Existing `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, and `notificationSettings` must not be overwritten by migration.

## AiContext

Existing AI request context extended with locale.

Fields:

- `locale`: resolved app locale such as `ar-EG` or `en-US`.
- Existing fields remain unchanged: `userId`, `now`, `categories`, `categoryAliases`, `expenses`, `budget`, `defaultCurrency`, `defaultPaymentMethod`.

Rules:

- AI requests use `locale`.
- Voice recognition preferred locale uses `locale` when supported.
- Base currency remains fallback only.

## SettingsLoadState

Represents whether preference data is safe to use.

States:

- `loading`: settings are being fetched.
- `success`: settings are usable.
- `saving`: visible optimistic state while persisting.
- `failure`: settings failed to load or save.
- `requiresSetup`: mandatory first-run choices are missing.

Rules:

- Expense save paths that need default currency/payment cannot silently proceed during `failure`.
- Explicit user-provided values may still allow local form editing, but final save must show a clear confirmation of used values.

