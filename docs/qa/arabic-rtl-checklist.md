# Arabic RTL QA Checklist

Date: 2026-05-19
Spec: `specs/061-localization-rtl-release-pass/`

Latest update: 2026-05-20 for `specs/066-localization-rtl-final-pass/`.

## Purpose

Use this checklist for manual Arabic right-to-left QA after Worker 048/049 finish ARB and code localization. It targets layout issues that widget tests may miss: keyboard overlap, clipping, mixed Arabic/English rows, bidirectional currency/date text, and generated PDF readability.

## Test Setup

- Device: Android phone or emulator, small viewport preferred, for example 360 x 640 logical pixels.
- Locale: Arabic app language selected from Settings or first-run setup.
- Text direction expectation: app-owned text is RTL; numbers, currency codes, emails, and dates remain readable.
- Keyboard: use the default Android keyboard and keep it open for the input checks below.
- Data: use sample data only. Do not use production accounts or sensitive financial descriptions.
- Network/Firebase: use a disposable test user if backend access is required.

## Sample Data

Create or seed equivalent sample data:

| Type | Sample |
| --- | --- |
| Category | `طعام` with any food icon |
| Category | `Uber` with transport icon |
| Expense | `طعام العائلة`, amount `125.50`, currency `EGP`, payment `Wallet` |
| Expense | `Uber airport`, amount `18`, currency `USD`, payment `Visa` |
| Expense | `قهوة Starbucks`, amount `65`, currency `EGP`, payment `Cash` |
| Recurring expense | `Netflix شهري`, amount `10`, currency `USD`, monthly |
| Saving goal | `رحلة دبي`, target `3000`, currency `AED` |
| AI input | `دفعت 125 جنيه غداء مع العائلة بالمحفظة أمس` |
| Export date range | A range containing the mixed Arabic/English rows above |

## Checklist

- [ ] First-run setup or Settings language selection shows Arabic labels, RTL option rows, and no clipped radio/selection controls.
- [ ] Home opens in Arabic RTL and mixed rows keep category names, descriptions, amounts, and currency codes readable.
- [ ] Add Expense opens in Arabic with keyboard closed; amount, description, category, payment method, currency, and date fields fit without clipped labels.
- [ ] Add Expense description field with keyboard open accepts long Arabic text and does not hide the save button or active field.
- [ ] Add Expense category picker shows Arabic app labels while user-created category names remain unchanged.
- [ ] Category create/edit dialog shows RTL labels, icon search, color controls, and action buttons without horizontal overflow.
- [ ] Expenses list search field accepts Arabic and English terms; clear/search icons remain on the expected side for RTL.
- [ ] Expenses filter sheet shows Arabic section labels, date-range controls, amount min/max fields, category chips, payment chips, and currency selection without overlap.
- [ ] Recurring Expenses screen shows Arabic empty state, form labels, frequency selector, start/end dates, and archive confirmation; mixed English descriptions remain readable.
- [ ] Reports screen shows Arabic summary labels, period controls, category breakdown, month comparison, and chart labels without clipping.
- [ ] Saving Goals screen shows Arabic empty state, create/edit dialog, contribution dialog, deadline row, and archive confirmation; goal names remain user text.
- [ ] Export Data screen shows Arabic labels for date range, categories, payment method, currency, export, and share actions.
- [ ] Export flow with no date range shows a localized Arabic message and does not expose raw validation text.
- [ ] Settings groups show Arabic labels for profile, language, currency/payment, notifications, protection, AI usage, monetization, privacy, support, and guidance.
- [ ] App protection/PIN dialogs and biometric fallback text remain readable in RTL with keyboard open.
- [ ] AI Assistant sheet opens in Arabic, close and action buttons are positioned correctly, and the input field remains usable with keyboard open.
- [ ] AI Assistant long Arabic input wraps cleanly and preview labels are Arabic while recognized category/description values remain user/provider content.
- [ ] AI update/delete target picker shows Arabic app-owned prompts/buttons and keeps expense descriptions, scores, and reasons readable.
- [ ] Free/Premium screen shows Arabic plan labels, quota copy, privacy/ad choices, warning state, and CTA text without clipped buttons or nested-card overflow.
- [ ] Rewarded ad/AI quota messages shown from monetization surfaces are localized or safely mapped to localized UI copy.
- [ ] Small viewport navigation, dialogs, bottom sheets, and snackbars do not overflow horizontally.
- [ ] Arabic PDF export opens on device or desktop and Arabic text is readable, aligned, and not reversed or missing glyphs.
- [ ] PDF table rows with mixed Arabic descriptions, English merchant names, dates, amounts, and currency codes remain visually scannable.

## Pass Criteria

- No app-owned English labels appear in Arabic mode on the screens above.
- User-generated English or mixed-language data remains unchanged.
- No visible horizontal overflow, clipped buttons, clipped dialog actions, or keyboard-covered active inputs on the small viewport.
- Generated Arabic PDF text is readable with mixed Arabic/English rows.

## Current Status

Worker 1 completed a source-level localization pass for Recurring, Reports,
Export, Saving Goals, AI Assistant, and Free/Premium app-owned labels. The ARB
files parse as JSON, but generated localization code was not refreshed because
this worker was instructed not to run `flutter gen-l10n`.

Manual RTL device QA, keyboard-open checks, Flutter widget tests, and Arabic PDF
visual inspection are not completed in this Worker 1 pass because the worker was
explicitly instructed not to run build, Flutter, emulator, or verification
commands. These checks remain deferred to the parent integration pass or a
tester with device/PDF inspection access.

## Worker 1 Source-Level Notes

- Recurring forms now use localized frequency and payment labels; verify long
  Arabic frequency/payment labels inside dropdowns on a small viewport.
- Saving Goals cards now use localized progress, remaining, and deadline labels;
  verify the remaining amount row wraps cleanly when Arabic text and long
  currency amounts appear together.
- Free/Premium comparison rows now use Arabic plan/feature labels; verify the
  three-column comparison remains scannable on narrow screens.
- AI Assistant preview labels and category-resolution notes now use l10n; verify
  mixed Arabic app labels with provider/user category names and reasons.
- Export still requires PDF visual QA with generated files after the parent runs
  localization generation and Flutter verification.

## Worker 066 Source-Level Notes

- Categories, category form, category budgets, subscriptions, and export/PDF
  label boundaries received source-level l10n updates.
- Use `docs/qa/arabic-export-fixture.md` for the repeatable mixed Arabic/English
  export/PDF fixture.
- `flutter gen-l10n`, analyzer, widget tests, keyboard-open QA, and manual PDF
  inspection remain open by instruction.
