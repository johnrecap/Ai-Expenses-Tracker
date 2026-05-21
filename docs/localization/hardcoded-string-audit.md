# Hardcoded String Audit

Date: 2026-05-19
Spec: `specs/061-localization-rtl-release-pass/`

Latest update: 2026-05-20 for `specs/066-localization-rtl-final-pass/`.

## Scope

This audit covers the Plan 061 localization release-pass scope and carries
forward the Plan 047 findings:

- `lib/screens/add_expense/`
- `lib/screens/categories/`
- `lib/screens/expenses/`
- `lib/screens/recurring_expenses/`
- `lib/screens/reports/`
- `lib/screens/saving_goals/`
- `lib/screens/export/`
- `lib/screens/settings/`
- `lib/screens/ai_assistant/`
- `lib/screens/monetization/`
- `lib/ai/`
- `lib/monetization/`
- `lib/services/export/`

User-generated values such as category names, expense descriptions, AI transcripts, emails, receipt text, provider output, currency codes, route names, keys, and debug identifiers are intentionally excluded from localization.

## Search Commands Used

Read-only audit commands run by Worker 047:

```powershell
rg -n "Text\(|tooltip:|labelText:|hintText:|SnackBar|AlertDialog|showDialog|validator:|error" lib\screens lib\ai lib\monetization lib\services\export
rg -n --glob '*.dart' --pcre2 '["'']([^"'']*[A-Za-z][^"'']*)["'']' lib\screens\add_expense lib\screens\categories lib\screens\expenses lib\screens\recurring_expenses lib\screens\reports lib\screens\saving_goals lib\screens\export lib\screens\settings lib\screens\ai_assistant lib\screens\monetization lib\ai lib\monetization lib\services\export
rg -n "context\.l10n|localizedPaymentMethod|AppLocalizations" lib\screens\add_expense lib\screens\categories lib\screens\expenses lib\screens\recurring_expenses lib\screens\reports lib\screens\saving_goals lib\screens\export lib\screens\settings lib\screens\ai_assistant lib\screens\monetization lib\ai lib\monetization lib\services\export
```

## Current Localization Foundation

- Existing ARB naming convention is lower camel case with domain prefixes only where useful, for example `guidedTourNext`, `onboardingAiTitle`, `settingsUnavailableMessage`, and generic keys such as `save`, `cancel`, `currency`.
- Plural and placeholder metadata is already present for keys such as `resultsCount` and `guidedTourStepCount`.
- Existing test helper: `test/helpers/localized_test_app.dart` wraps widgets with generated `AppLocalizations.localizationsDelegates` and `supportedLocales`.
- Existing localization tests: `test/localization/localized_strings_test.dart` and `test/localization/app_language_preference_test.dart`.
- `Add Expense`, `Expenses`, `Home`, language settings, currency settings, and selected settings/profile/guided-tour strings already use `context.l10n`.
- Worker 1 added Plan 061 ARB keys for Recurring, Reports, Export, Saving Goals,
  AI Assistant preview/input controls, receipt/advice controls, and Free/Premium
  widgets. `flutter gen-l10n` was not run because the worker was explicitly
  instructed to leave verification/generation to the parent agent.

## Worker 066 Source-Level Status

### App-Owned Strings Localized In This Pass

- `lib/screens/categories/views/categories_screen.dart`: title, archive dialog,
  empty state, retry, action tooltips, expense-count plural, and known Bloc
  success/failure messages are now mapped to l10n at the UI boundary.
- `lib/screens/categories/widgets/category_form_dialog.dart`: create/edit
  titles, validation, field labels, selected-icon semantics, color controls,
  icon search, and dialog actions now use l10n.
- `lib/screens/category_budgets/views/category_budgets_screen.dart`: screen
  title, month navigation tooltips, archive dialog, empty/error/action states,
  budget progress copy, ignored-currency plural, form labels, and known Cubit
  messages now use l10n at the UI boundary.
- `lib/screens/subscriptions/views/subscription_center_screen.dart`: title,
  manage-recurring action, load failure, monthly impact header, next-due row,
  monthly impact suffix, edit tooltip, empty state, and manage button now use
  l10n while preserving user-entered subscription/category text.
- `lib/screens/export/views/export_screen.dart` and `lib/services/export/`:
  export validation failures are mapped to localized messages, and PDF/CSV/Excel
  labels can now be supplied from l10n through `ExportLabels`.
- `docs/qa/arabic-export-fixture.md`: repeatable Arabic mixed-language export
  fixture created for later PDF visual QA.

### Remaining Open Items For Parent Integration

- Run `flutter gen-l10n` after all workers finish; generated localization files
  were intentionally not refreshed in this worker.
- Run analyze/widget tests after generation; this worker was explicitly
  instructed not to run Flutter verification commands.
- Manually QA Arabic small-screen layout, keyboard-open forms, and PDF output.
- Review remaining service/model/provider strings before deciding whether they
  should become localized UI messages or stay classified as data/internal.

## Worker 1 Release-Pass Status

### App-Owned Strings Localized In This Pass

- `lib/screens/recurring_expenses/`: screen title, empty state, archive dialog,
  retry action, next-date label, form titles, labels, validation, payment
  method labels, frequency labels, and date controls now use l10n.
- `lib/screens/reports/`: report title, week/month controls, empty state,
  category header, top-category label, ignored-currency message, period
  comparison labels, and category-breakdown empty state now use l10n.
- `lib/screens/export/`: screen title, date-range required state, pick-range
  tooltip, currency/all-currencies labels, category/payment headings, export,
  share, export-ready snackbar, and missing-date-range snackbar now use l10n.
- `lib/screens/saving_goals/`: screen title, empty state, retry action,
  contribution dialog, archive dialog, form titles/labels/validation, deadline
  controls, card progress/remaining/deadline labels, and action tooltips now
  use l10n.
- `lib/screens/ai_assistant/`: AI text-input hint/tooltips, receipt camera/gallery
  controls, advice period controls, preview form labels, category resolution
  labels, major snackbars, command prompts/actions, local summary/advice titles,
  prediction/repeated-expense labels, target confirmation labels, and voice
  status messages now use l10n.
- `lib/screens/monetization/`: Free/Premium title, refresh/privacy labels,
  Free-safe warning, plan badge, comparison table, quota card, ad behavior card,
  and Premium CTA panel now use l10n.

### Remaining App-Owned Or Follow-Up Strings

- `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`
  `_InternalAiStatusCard` intentionally remains provider/debug copy and is
  hidden in release mode.
- Some AI result bodies (`state.resultMessage`, provider advice, target-match
  reasons, local detector quality notes, and status messages supplied by lower
  layers) are data/provider/service output. They should be mapped to localized
  app-owned messages in a later AI-service pass if product wants fully localized
  generated/local insight prose.
- `lib/monetization/models/monetization_plan.dart` still contains model-level
  English display strings. Current Plan 061 UI widgets no longer depend on
  those strings in the Free/Premium screen, but the model strings should remain
  classified as app-owned if another UI starts rendering them directly.
- `lib/services/export/export_service.dart` validation strings remain service
  errors. The current UI prevents the primary missing-date-range case locally;
  a later export-service localization pass can replace raw service error
  propagation with localized error codes.

## App-Owned Strings To Localize

### P1 Finance Surfaces

These strings should move to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, then generated l10n and UI references should be updated by the ARB/code owners.

#### Categories

- `lib/screens/categories/views/categories_screen.dart`: app bar title, archive dialog title/buttons, empty state, retry button, edit/archive tooltips, and expense-count suffix.
- `lib/screens/categories/widgets/category_form_dialog.dart`: create/edit dialog titles, validation text, field labels, selected icon semantics, color/custom-color labels, search icons label, and save/cancel buttons.

Do not translate category names, stored icon keys, color values, or user-created category aliases.

#### Recurring Expenses

- Completed in Plan 061 Worker 1 for the view and form display boundaries.
- `lib/screens/recurring_expenses/blocs/recurring_expense_bloc/recurring_expense_bloc.dart`: app-facing success, failure, and validation messages.

Do not translate recurrence ids, currency codes, or user-entered descriptions.

#### Reports

- Completed in Plan 061 Worker 1 for the screen, month comparison card, and
  category breakdown empty state.

Do not translate category names, amounts, currency codes, or formatted dates.

#### Saving Goals

- Completed in Plan 061 Worker 1 for the screen, form, and card display
  boundaries.
- `lib/screens/saving_goals/blocs/saving_goal_bloc/saving_goal_bloc.dart`: app-facing success, failure, and validation messages.

Do not translate saving goal names or user-entered descriptions.

#### Export

- Completed in Plan 061 Worker 1 for `lib/screens/export/views/export_screen.dart`.
- `lib/screens/export/cubit/export_cubit.dart`: validation/failure messages displayed by UI.
- `lib/services/export/export_service.dart`: validation errors displayed through export failure state.
- `lib/services/export/pdf_exporter.dart`: PDF title/table headings/date labels if these are app-owned in generated files.

Do not translate output file extensions, route names, currency codes, category names, payment method enum values after they are localized at display boundaries, or raw validation debug details not shown to users.

#### Subscription Center

The current plan scope did not list `lib/screens/subscriptions/`, but Home exposes Subscription Center and the deferred backlog groups it with localization risk. It still contains app-owned strings: app bar title, manage recurring tooltip/button, empty copy, edit tooltip, and estimated monthly/next due labels. Parent should decide whether Worker 048 or a follow-up plan owns it.

### P2 AI And Monetization Surfaces

#### AI Assistant

- Completed in Plan 061 Worker 1 for the AI sheet/app-owned command labels,
  action preview card, AI text input, receipt button, and advice button.
- `lib/ai/cubit/ai_assistant_cubit.dart`, `lib/ai/models/ai_action_preview.dart`, `lib/ai/voice/ai_voice_input_controller.dart`, and receipt/advice services: user-visible clarification, validation, and fallback messages.

Do not translate user prompts, transcripts, provider payload fields, provider raw content, JSON enum values, or audit metadata.

#### Monetization And Free/Premium

- Completed in Plan 061 Worker 1 for Free/Premium screen, quota card, premium
  CTA, comparison table, plan feature rows, and current plan badge.
- `lib/monetization/models/monetization_plan.dart`: Free/Premium titles, summaries, and feature lists are app-owned display copy.
- `lib/monetization/widgets/rewarded_ai_credit_button.dart`: caller-provided label/message should be localized at call sites.
- `lib/monetization/services/ad_consent_service.dart` and stubs: privacy-options and unavailable messages displayed to users should be mapped to localized UI copy.

Do not translate ad placement identifiers, AdMob unit ids, entitlement ids, policy versions, or internal status labels unless displayed directly.

### Settings Surfaces

Already localized: profile heading, authenticated account label, language section, currency section, guided-tour section, settings load failure, retry.

Still app-owned literals:

- `lib/screens/settings/widgets/support_settings_section.dart`: feedback tile, dialog title/body, and No/Include version actions.
- `lib/screens/settings/widgets/security_settings_section.dart`: section description, PIN lock, change PIN, biometric unlock labels, and biometric availability subtitle.
- `lib/screens/settings/widgets/privacy_settings_section.dart`: data ownership title/subtitle.
- `lib/screens/settings/widgets/payment_settings_section.dart`: default payment method field label.
- `lib/screens/settings/widgets/notification_settings_section.dart`: notification section description, budget alerts, daily check-in, check-in time, weekly digest, digest time, and subtitles.
- `lib/screens/settings/widgets/monetization_settings_section.dart`: plan label, remove ads, coming-soon purchase setup, Free-safe state warning, refresh tooltip, privacy/ad choices.
- `lib/screens/settings/widgets/ai_settings_section.dart`: quota labels and helper copy if not already data-driven by localized keys.

Do not translate authenticated user ids, provider names, version strings, or error details unless they are mapped to safe display messages.

## User-Generated Or Data-Driven Strings To Preserve

- Category names, aliases, and category descriptions.
- Expense descriptions, notes, receipt text, AI input, and voice transcripts.
- Saving goal names.
- Formatted amounts, currency codes, percentages, and dates.
- Backend/provider ids, route names, storage keys, cache keys, enum wire values, and request payload keys.
- AI provider raw content unless the UI maps it to a safe app message.

## Provider, Debug, Or Internal Strings

These are not ARB candidates unless they surface directly to users:

- `lib/monetization/services/google_mobile_ads_service.dart`: AdMob unit ids, dart-define names, generated reward ids.
- `lib/monetization/models/ad_placement_policy.dart`: blocked route identifiers and placement ids.
- `lib/ai/services/*`: JSON keys, schema keys, model/provider ids, fingerprints, and internal fallback identifiers.
- `lib/ai/services/mock_ai_service.dart`: deterministic test/mock payload text can remain internal unless shown in production UI.

## Test-Only Strings

Test expectations and fixture labels should move only when they assert app-owned UI copy on localized surfaces:

- Existing localization helper: `test/helpers/localized_test_app.dart`.
- Existing localization tests: `test/localization/localized_strings_test.dart` and `test/localization/app_language_preference_test.dart`.
- Keep test fixture data, fake repository ids, mock category names, and mock expense descriptions as fixtures unless they are meant to assert translated app labels.
- After UI copy moves to ARB keys, update tests to assert through localized wrappers instead of hardcoded English finders where practical.

## Follow-Up Guidance For Workers 048 And 049

- Keep ARB key names lower camel case and reuse generic keys such as `save`, `cancel`, `delete`, `edit`, `confirm`, `retry`, `currency`, `paymentMethod`, `category`, `description`, and `date`.
- Add domain-prefixed keys for ambiguous copy, for example `recurringExpenseArchiveTitle`, `savingGoalDeadline`, `exportAllCurrencies`, `aiPreviewNewCategoryName`, or `premiumPrivacyAdChoices`.
- Prefer localizing display boundaries instead of domain wire values. For example, payment method labels already have `localizedPaymentMethod`.
- After ARB edits, parent/Worker 049 must run `flutter gen-l10n` and inspect generated files.
- Widget tests should use `test/helpers/localized_test_app.dart` or the existing MaterialApp localization delegate pattern.
