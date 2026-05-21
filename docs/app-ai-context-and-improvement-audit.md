# Expense Tracker - AI Context And Improvement Audit

Date: 2026-05-20

## Purpose

This document is a product and technical context file for another AI or reviewer.
It summarizes what currently exists in the Expense Tracker app, what is risky or
unfinished, and what improvements or new features are worth considering next.

This is not an implementation plan. Any future implementation plan should be
created as a Spec Kit artifact under `specs/<number>-<feature>/`.

## ملخص عربي سريع

التطبيق حاليا عبارة عن Expense Tracker متقدم مبني بـ Flutter و Firebase، وفيه
تسجيل دخول Google و email/password، بيانات منفصلة لكل مستخدم، مصروفات، تصنيفات،
ميزانية شهرية، تقارير، تصدير، مصروفات متكررة، أهداف ادخار، إعدادات حساب، قفل
محلي، إشعارات، دعم عربي/إنجليزي، ذكاء اصطناعي لإضافة المصروفات وتحليل الفواتير
والنصائح، وبنية مبدئية للبريميوم والإعلانات.

أهم ما يحتاج تركيز حاليا:

1. توحيد حساب العملات في كل الشاشات وليس Home و Reports فقط.
2. إنهاء localization/RTL بالكامل وتجربة الشاشات على موبايل صغير.
3. اختبار Firebase الحقيقي: rules/indexes/login/settings/delete account.
4. التأكد أن نسخة الإنتاج فيها `AI_GATEWAY_URL` الحقيقي وليس fallback/mock.
5. تجهيز Premium/Ads بشكل إنتاجي قبل أي نشر عام.
6. تطوير الـ AI ليجاوب على أسئلة المستخدم عن مصاريفه، وليس مجرد ملء فورم.

## Quick Summary

Expense Tracker is now a Flutter mobile finance app, not the original starter
project. It supports authenticated user-owned data, expenses, categories,
budgets, reports, export, recurring expenses, saving goals, account settings,
app lock, notifications, localization foundations, AI-assisted expense entry,
receipt/advice flows, and a monetization/ad foundation.

The strongest current product direction is:

1. Make financial calculations completely trustworthy across currencies.
2. Finish Arabic/English localization and small-screen RTL QA.
3. Finish production readiness: Firebase deploy/smoke tests, release build,
   Google Sign-In SHA setup, real AI gateway URL, AdMob IDs, and store policy.
4. Improve account/profile and data deletion confidence before public release.
5. Expand AI from "fill a form" into a useful assistant over the user's own
   spending history, while keeping manual entry reliable.

## Current Tech Stack

- Flutter and Dart 3.x.
- Bloc/Cubit for state management.
- Local repository package: `packages/expense_repository`.
- Firebase Core, Firebase Auth, and Cloud Firestore.
- Cloudflare Worker AI gateway in `workers/ai-gateway`.
- Optional legacy/future Firebase Functions folder in `functions/`.
- English/Arabic localization through ARB files and generated l10n.
- Local notifications, local auth, secure storage, speech-to-text, image picker,
  PDF/Excel/CSV export, Google Mobile Ads, and HTTP exchange-rate calls.

Main dependency areas in `pubspec.yaml`:

- UI/state: `flutter_bloc`, `bloc`, `equatable`, `fl_chart`, `intl`.
- Firebase: `firebase_core`, `cloud_firestore`.
- Auth repository package includes Firebase Auth.
- Export: `csv`, `excel`, `pdf`, `path_provider`, `share_plus`.
- Device features: `flutter_local_notifications`, `timezone`, `local_auth`,
  `flutter_secure_storage`, `speech_to_text`, `image_picker`, `image`.
- Monetization: `google_mobile_ads`.
- Networking: `http`.

## Architecture Snapshot

The app is organized around feature folders and a local data package.

Important source areas:

- `lib/screens/auth/`: login, register, AuthBloc.
- `lib/screens/home/`: dashboard, navigation, home totals, currency conversion
  summary.
- `lib/screens/add_expense/`: manual expense form and AI form-fill entry point.
- `lib/screens/expenses/`: expense list, filters, edit/delete workflows.
- `lib/screens/categories/`: category management.
- `lib/screens/budget/`: monthly budget.
- `lib/screens/category_budgets/`: category-level budget screen/calculation.
- `lib/screens/reports/` and `lib/screens/stats/`: weekly/monthly reports.
- `lib/screens/recurring_expenses/`: recurring rules.
- `lib/screens/subscriptions/`: subscription summary from recurring expenses.
- `lib/screens/export/`: CSV/Excel/PDF export flow.
- `lib/screens/saving_goals/`: saving goal management.
- `lib/screens/settings/`: profile, language, currency, payment, notification,
  security, privacy, AI, monetization, support settings.
- `lib/screens/account/`: account/profile management and deletion services.
- `lib/screens/app_lock/` and `lib/security/`: PIN/biometric app protection.
- `lib/screens/onboarding/`: first-run language/currency/payment/reminder setup.
- `lib/guided_tour/`: replayable guided product tour.
- `lib/ai/`: AI parsing, receipt, advice, voice, category intelligence, and
  AI action previews.
- `lib/monetization/`: Free/Premium state, ads, consent, feature gates, purchase
  service abstraction.
- `lib/observability/`: privacy-safe observability and feature-flag wrappers.
- `lib/services/exchange_rates/`: daily exchange-rate refresh via Frankfurter.
- `packages/expense_repository/`: Firestore/Auth repositories, entities, models.
- `workers/ai-gateway/`: current production-style AI gateway path.

## Firestore And Data Ownership

Current rules use user-owned subcollections under:

```text
users/{userId}/expenses/{expenseId}
users/{userId}/categories/{categoryId}
users/{userId}/budgets/{budgetId}
users/{userId}/category_budgets/{budgetId}
users/{userId}/recurring_expenses/{recurringExpenseId}
users/{userId}/saving_goals/{goalId}
users/{userId}/settings/profile
users/{userId}/ai_actions/{actionId}
users/{userId}/category_aliases/{aliasId}
```

Top-level legacy collections such as `expenses` and `categories` are denied.

Rules validate:

- required IDs match document IDs and authenticated user ID.
- positive numeric money values.
- ISO-like currency codes.
- payment method enum values.
- category snapshots.
- user settings including app display name, language, supported currencies,
  conversion rates, notification settings, onboarding, guided tour, and exchange
  rate timestamp.
- AI action logs and category aliases.

Release risk: these rules still need deployment and a real Firebase smoke test
against the intended project.

## Existing Feature Inventory

### Authentication

Implemented areas:

- Email/password sign-in and registration.
- Google Sign-In support through the auth repository/bloc path.
- Authenticated user-owned Firestore data paths.
- Error mapping for common Firebase auth failures.

Open risks:

- Final Firebase Auth provider setup, package name, SHA-1/SHA-256 fingerprints,
  and Android release signing must be validated in production-like builds.
- Google and email/password paths both exist, but account reauthentication UX is
  still listed as open in `specs/062-account-profile-management/tasks.md`.

### Account And Profile

Implemented areas:

- Account/Profile screen.
- App-local display name independent from Google profile.
- No profile photo scope.
- Account deletion service path.
- Provider metadata and provider-specific action handling.

Open risks:

- End-to-end deletion with Firebase Auth reauthentication and recursive
  user-scoped Firestore deletion still needs real-device/Firebase validation.
- Sensitive actions need polished reauthentication UX.
- The warning and confirmation flow should be tested with both Google and
  email/password accounts.

### Home Dashboard

Implemented areas:

- Authenticated welcome header using app/user identity.
- Monthly spending total.
- Monthly budget summary.
- Budget remaining.
- Top category.
- Recent transactions.
- Streak, spending health score, and weekly check-in.
- Navigation to settings, AI assistant, reports, and add expense.
- Currency conversion through saved user settings/rates.

Known concerns:

- Home conversion depends on settings rates being fresh and valid.
- Secondary widgets may still need broader mixed-currency handling and QA.
- Small-screen layout should keep being checked after each dashboard change.

### Expenses

Implemented areas:

- Add expense manually.
- Decimal amount support.
- Description, date, category, payment method, currency.
- Edit/delete expense workflows.
- Expense list, search, filtering, and scaling work.
- Offline pending-write feedback is part of the product surface.

Potential improvements:

- Faster add flow with AI first but always editable/manual.
- Merchant/vendor field.
- Tags.
- Attachments/receipt image linked to expense.
- Duplicate detection.
- Refund/transfer/non-expense transaction types.
- Bulk edit/delete.

### Categories

Implemented areas:

- Category repository and Firestore rules.
- Category management screen.
- Icon/color registry and modern visuals.
- AI category matching and category aliases.

Potential improvements:

- Better archive/merge behavior.
- Category-specific monthly budgets and alerts need more polish.
- Category aliases could learn from repeated user corrections.

### Budgets

Implemented areas:

- Monthly budget model/repository/screen.
- Budget progress card.
- Warning threshold field in rules.
- Budget calculations using base currency conversion in core Home flow.

Known concerns:

- Category budgets still appear to use conservative same-currency calculations
  and may ignore mixed-currency expenses.
- Budget notifications and category budget alert preferences are not complete.

### Reports And Statistics

Implemented areas:

- Weekly/monthly report periods.
- Total, top category, bucket/chart data, previous period comparison.
- Currency conversion through the same settings/rates path used by Home.
- Report metadata for converted and unconverted currencies.
- AI summaries/advice and weekly digest updated to consume converted reports.

Known concerns:

- Historical reports use the latest saved daily rates, not transaction-date
  historical rates.
- Missing rates must remain clearly visible and must not silently add currencies.
- Manual QA is still needed on a real Android install.

### Exchange Rates And Multi-Currency

Implemented areas:

- User settings store base currency, supported currencies, conversion rates, and
  `exchangeRatesUpdatedAt`.
- `ExchangeRateRefreshService` refreshes once per local day when rates are stale.
- If offline/provider fails, existing saved rates remain in use.
- `FrankfurterExchangeRateService` fetches a source-to-base rate per supported
  non-base currency.

Known concerns:

- Provider selection, fallback provider, historical rates, and freshness UI are
  deferred.
- Currencies unsupported by the provider need clear messaging.
- Category budgets, subscription monthly impact, and any secondary summaries
  should be audited so all finance surfaces use the same conversion rules.

### AI Assistant

Implemented areas:

- AI text-to-expense parsing.
- AI form fill in Add Expense.
- Flexible drafts: AI may fill known fields and leave unknown fields empty for
  manual completion.
- Category intelligence and aliases.
- Receipt image parsing path.
- Financial advice path.
- Voice input path.
- AI usage/quota surfaces.
- AI action logs.
- Local/mock fallback when no gateway URL is configured.
- Cloudflare Worker gateway for provider-backed parse, receipt, advice, and
  quota flows.

Product direction:

- The AI should accept natural user input in Arabic or English.
- The AI should not force the user to provide every field.
- Unknown or ambiguous fields should remain editable instead of blocking the
  draft.
- No AI output should write data without preview/confirmation.

Known concerns:

- Real gateway device QA is still open.
- `AI_GATEWAY_URL` must be provided in production builds.
- Worker/provider quota, timeout, malformed output, and auth errors need
  monitoring/alerts before public launch.
- Some AI-generated/local fallback messages may still need localization mapping.

### Export

Implemented areas:

- CSV export.
- Excel export.
- PDF export.
- Share/export ready UI.
- Date range and filter-oriented export flow.

Known concerns:

- Manual QA remains: generate real CSV/Excel/PDF, open/share them, and visually
  inspect Arabic PDF output with mixed Arabic/English rows.

### Notifications And Engagement

Implemented areas:

- Local notification service abstraction.
- First-run reminder introduction.
- Daily check-in settings.
- Weekly digest settings.
- Streak and health score.
- Weekly digest screen/check-in entry point.

Known concerns:

- Notification permission/scheduling behavior needs Android real-device QA.
- Category budget and subscription due notifications are still not complete.

### App Lock And Security

Implemented areas:

- PIN setup/unlock.
- Optional biometric unlock.
- Secure storage and hashing support.
- Settings security section.

Known concerns:

- Real-device biometric availability and fallback QA remains important.
- App Check is not yet enabled and is deferred until public release readiness.

### Monetization, Ads, And Premium

Implemented areas:

- Free/Premium screen and plan surfaces.
- Entitlement repository abstraction.
- Purchase service abstraction.
- Disabled purchase service with honest "coming soon/unavailable" behavior.
- Ad service and consent abstractions.
- Google Mobile Ads integration/stub paths.
- Test-ID-safe ad configuration.
- Quota surfaces and rewarded credit foundation.

Current status:

- Premium is a foundation, not a real paid entitlement system.
- Real purchases should not be enabled until a trusted backend verifies receipts
  and restores entitlements.
- Production AdMob IDs must be configured outside source code.

Potential improvements:

- Make Premium benefits concrete: no ads, higher AI quota, advanced reports,
  receipt limits, export templates, smart budgets.
- Server-side entitlement verification.
- Clear free limits that never break manual finance tracking.

### Localization And RTL

Implemented areas:

- English/Arabic ARB files.
- Generated l10n files.
- Language preference separate from currency.
- Several core screens and later feature surfaces use localization.
- RTL-focused specs and audit documents exist.

Known concerns:

- Broad localization is still incomplete or not fully verified.
- Some service/model/user-visible strings are still English literals.
- Small-screen Arabic with keyboard open needs manual QA.
- Arabic PDF export needs visual QA.

### Observability And Operations

Implemented areas:

- Privacy-safe observability abstraction.
- Feature flag abstraction.
- Documentation for safe events and production QA.

Deferred:

- Decide when to add Crashlytics, Analytics, and Remote Config.
- Wire feature flags into AI, ads, premium CTA, receipt AI, advice AI, and
  rewarded credits.
- Add support/incident/release runbooks.

## Known Bugs, Risks, And Gaps

### P0 / Release Blockers

1. Deploy Firestore rules/indexes and run a real Firebase smoke test.
   Expected coverage: expenses, categories, budgets, recurring rules, saving
   goals, settings, AI action logs, account deletion.

2. Validate Google Sign-In on the final Android package/signing setup.
   Missing SHA fingerprints or provider config will break login even if code is
   correct.

3. Build a signed internal/release artifact and test it on a clean Android
   device.

4. Confirm the release build includes the real `AI_GATEWAY_URL`; otherwise AI
   uses local/mock fallback behavior and is not production-AI ready.

5. Confirm no production release uses test AdMob IDs unless ads are explicitly
   disabled.

### P1 / Correctness And Trust

1. Audit all finance surfaces for currency conversion consistency:
   Home, Reports, Monthly Budget, Category Budgets, Subscription Center, Export,
   AI summaries, weekly digest, and notifications.

2. Add transaction-date historical exchange rates or clearly explain that reports
   use the latest cached daily rate.

3. Finish account deletion and reauthentication end-to-end validation.

4. Complete localization/RTL QA and fix overflow or stale language refresh
   issues.

5. Verify Settings scroll behavior and all Settings sections on small screens.

6. Ensure AI form fill leaves unknown fields empty and never blocks manual save
   unnecessarily.

### P2 / UX Improvements

1. Improve Add Expense so the AI widget is first-class but the manual form stays
   immediately usable.

2. Add better report drilldowns: tap a chart bar/category to open matching
   expenses.

3. Add dashboard customization: choose visible cards, default period, and quick
   actions.

4. Add merchant/tags/notes/attachments to expenses.

5. Add duplicate detection and smart suggestions after repeated edits.

6. Add clearer empty states and recovery actions for offline/provider failures.

### P3 / Advanced Features

1. Forecast monthly spending and cashflow from recurring expenses.

2. Add wallets/accounts and transfers.

3. Add debt/loans/installments.

4. Add shared budgets/family mode only if product scope expands.

5. Add OCR/receipt history and searchable attachments.

6. Add backup/restore import flow.

## Ideas For AI-Oriented Product Improvements

The app already has an AI gateway and action preview architecture. The best next
AI improvements should increase usefulness without making data unsafe.

High-value AI ideas:

- Natural language expense search: "show food last month over 300 pounds".
- Natural language report questions: "why did I spend more this week?"
- Smart category learning from user corrections.
- Duplicate expense warnings.
- Subscription detection from repeated expenses.
- Budget recommendation from last 3 months.
- Spending anomaly detection.
- Receipt-to-draft with category, merchant, amount, tax, and date.
- Arabic voice improvements for common Egyptian phrasing.
- AI cleanup suggestions: "these categories look duplicated".
- Safe bulk actions with confirmation: archive category, rename alias, tag
  selected expenses.

Safety rules for AI:

- AI never writes directly without preview/confirmation.
- Missing fields become editable blanks, not hard failures.
- Low confidence shows a draft plus warning or asks one short question.
- Manual entry and local reports must keep working when AI fails.
- Never send PIN, auth tokens, provider keys, or raw secrets to observability.

## Suggested Next Spec Kit Plans

These are possible future Spec Kit plans, not tasks already started:

1. `064-finance-surface-currency-audit`
   Reason: make every money surface use the same conversion logic.
   Benefit: prevents user distrust when Home, Reports, Budgets, and Subscriptions
   disagree.
   Expected result: one shared conversion/reporting contract and tests for every
   visible finance surface.

2. `065-localization-rtl-final-pass`
   Reason: Arabic/English support is a core promise but still needs full
   verification.
   Benefit: fewer broken screens, stale strings, overflow, and keyboard layout
   issues.
   Expected result: localized widgets/tests plus manual small-screen RTL QA
   checklist results.

3. `066-production-firebase-smoke`
   Reason: local tests cannot prove real Firebase rules/provider setup.
   Benefit: catches permission denied, missing indexes, Google Sign-In SHA, and
   settings/profile write issues before release.
   Expected result: documented real-device smoke result for key journeys.

4. `067-account-deletion-reauth-hardening`
   Reason: account deletion is sensitive and currently needs stronger
   end-to-end confidence.
   Benefit: privacy trust and store readiness.
   Expected result: clear reauth UI, deletion confirmation, deletion result
   messages, and tests/fakes for Google and email/password users.

5. `068-ai-history-assistant`
   Reason: AI should do more than fill an expense form.
   Benefit: gives users value from their existing spending data.
   Expected result: safe read-only natural language questions over expenses and
   reports, with no mutation unless explicitly confirmed.

6. `069-premium-entitlement-backend`
   Reason: current Premium is only a foundation.
   Benefit: allows real monetization without trusting the client.
   Expected result: verified purchases, restore flow, and server-owned
   entitlement state.

## Deferred Items To Keep In Mind

From `docs/implementation_plans/deferred-and-advanced-work.md`, the relevant
items for future planning are:

- Real Android release keystore and signed APK/AAB inspection.
- Production-device QA on a clean Android device.
- Firestore rules/index deployment and Firebase smoke tests.
- Firebase Auth provider/SHA setup for final package name.
- Account deletion end-to-end validation.
- App Check before public release.
- Real `AI_GATEWAY_URL` Android QA.
- Worker monitoring for quota/provider/malformed output.
- Production AdMob IDs and consent-region QA.
- Server-side Premium purchase verification.
- Full localization/RTL manual QA and Arabic PDF visual inspection.
- Crashlytics/Analytics/Remote Config decision.
- Play Store privacy/data safety, screenshots, support email, and content rating.

## Questions For The Next AI Reviewer

Use these questions to think about updates or product direction:

1. Which current feature gives the most trust risk if it is wrong: currency,
   account deletion, reports, or AI parsing?
2. Should exchange rates be latest-daily only, or should every expense store the
   conversion rate used on its transaction date?
3. Should users manage wallets/accounts, or is category-based tracking enough?
4. What should be free forever, and what should Premium unlock?
5. Which AI actions should remain read-only until the app has more trust?
6. What exact manual QA checklist is enough before a Play Store internal test?
7. Which dashboard cards should be shown by default for a first-time user?
8. Should recurring expenses generate actual expenses automatically, or stay as
   forecast/subscription metadata until user confirms?

## High-Signal References

- Current instructions: `AGENTS.md`
- Constitution: `.specify/memory/constitution.md`
- Spec index: `specs/README.md`
- Current active plan: `specs/063-reports-currency-conversion/plan.md`
- Deferred backlog: `docs/implementation_plans/deferred-and-advanced-work.md`
- Firestore rules: `firestore.rules`
- Release checklist: `docs/release/play-store-checklist.md`
- Android release guide: `docs/release/android-release.md`
- AI production setup: `docs/ai/production-ai-setup.md`
- Localization audit: `docs/localization/hardcoded-string-audit.md`
- Monetization verification: `docs/monetization/premium-verification.md`
- Production QA checklist: `docs/qa/production-device-qa.md`
