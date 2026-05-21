# Data Model: First-Run Setup Onboarding

## OnboardingProgress

Tracks setup progress for a signed-in user.

Fields:

- `userId`: owner id.
- `currentStep`: one of `essentials`, `aiIntro`, `reminders`, `complete`.
- `selectedLanguagePreference`: optional until chosen.
- `selectedBaseCurrency`: optional until chosen.
- `selectedPaymentMethod`: optional until chosen.
- `notificationChoice`: optional reminder settings.
- `completed`: boolean.
- `version`: integer for future onboarding changes.
- `updatedAt`: timestamp.

Rules:

- `completed` can be true only when language, base currency, and payment method are valid and saved.
- Incomplete progress should resume at the first incomplete required step.

## OnboardingStep

Represents a single UI step.

Values:

- `essentials`: required language/currency/payment choices.
- `aiIntro`: safe AI explanation and optional sample text.
- `reminders`: optional daily reminder/weekly digest choices.
- `complete`: terminal state after settings save.

## UserSettings Extension

Settings need onboarding metadata.

Fields:

- `onboardingCompleted`: boolean.
- `onboardingVersion`: integer.
- Existing fields from Plan 041: language preference, base currency, supported currencies, default payment method, notification settings.

Migration:

- Existing users with valid old settings may be treated as completed for version 1 after first successful settings load.
- New users without settings are not completed.

## NotificationSetupChoice

Temporary setup choices before saving notification settings.

Fields:

- `dailyReminderEnabled`: boolean.
- `reminderTime`: optional hour/minute.
- `weeklyDigestEnabled`: boolean.

Rules:

- Permission denial must not set setup failure.
- Saved notification settings must reflect actual enabled/disabled state.

