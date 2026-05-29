# Deferred And Advanced Work

This file is the persistent backlog for work that is intentionally deferred,
blocked by external setup, or better suited for later production stages.

When reviewing bugs, proposing features, or creating new Speckit plans, check
this file and mention the relevant items briefly so they are not forgotten.

## Production Setup Blockers

- Create the real Android release keystore and local `android/key.properties`.
- Build and inspect a signed internal/release APK or AAB.
- Run production-device QA on a clean Android device.
- Deploy Firestore rules/indexes and run a Firebase smoke test with a real user.
- Rotate any previously exposed Gemini/provider keys before public release.
- Upgrade Android build tooling for Flutter 3.44+ compatibility: Gradle wrapper
  8.14+, Android Gradle Plugin 8.11.1+, Kotlin Gradle Plugin 2.2.20+, and
  migrate the app/plugin setup toward Flutter built-in Kotlin before those
  warnings become build failures.

## Firebase And Backend-Like Setup

- Confirm Firebase Auth providers, SHA-1/SHA-256 fingerprints, and Google sign-in
  on the final package name.
- Complete Plan 062 backend hooks for persistent app-local display name,
  provider metadata, email update, reauthentication, user-scoped recursive data
  deletion, and Firebase Auth account deletion.
- Validate account deletion end to end with Firebase Auth reauthentication and
  user-scoped Firestore data removal before public release.
- Add a trusted backend recursive deletion path if future user data gains nested
  Firestore subcollections beyond the current client deletion plan.
- Consider a backend-owned account deletion orchestration before public scale if
  client-side data deletion plus Auth deletion needs stronger atomicity or
  support recovery.
- Run end-to-end Firestore writes for expenses, categories, budgets, recurring
  rules, saving goals, settings, and AI action logs.
- Add App Check when the app is ready for public release.
- Keep Cloudflare Worker as the AI gateway; do not put provider keys in Flutter.
- Before replacing Firestore with a VPS backend, create a dedicated Spec Kit
  migration plan for Flutter local-first storage, PostgreSQL schema, Firebase ID
  token verification, sync/tombstones, backfill, rollback, and dual-write
  cutover.
- Track Firebase Admin transitive `uuid` moderate npm audit findings in the VPS
  backend and upgrade once upstream packages provide a non-breaking fix.
- Replace the Plan 082 JSON-fixture backfill scaffold with a production
  Firebase Admin export reader plus PostgreSQL transaction writes before real
  user migration.
- Replace the Plan 082 account-deletion recent-auth header contract with a
  provider-grade recent-login proof or backend-issued one-time deletion token
  before enabling deletion in VPS production.
- Run Plan 082 staging migration dry-run against seeded Firebase/PostgreSQL
  environments and store verification reports before any pilot cutover.
- Apply pulled VPS sync changes back into local repositories, not just push
  pending local writes, before multi-device pilot testing.
- Persist the VPS local sync queue across app process restarts with durable
  Drift-backed status metadata; Plan 086 added reasoned in-memory status but
  restart recovery still depends on the broader local database cutover.

## AI Advanced Reliability

- Run Android device QA with the real `AI_GATEWAY_URL`.
- Test Arabic parse, receipt extraction, advice quota, provider failure, and
  manual fallback on device.
- Add end-to-end widget/repository coverage for AI suggested category creation.
- Keep receipt/Home/Add Expense AI preview defaults aligned so unclear
  date/payment/currency use the user's safe defaults consistently, while amount
  and category still require review when not inferable.
- Create a dedicated attachment storage plan for receipt history, searchable
  attachments, cloud upload policy, Firestore rules, and device QA.
- Add monitoring/alerts for Worker quota, provider errors, and malformed output.
- Add optional model/provider routing later only behind the gateway.

## Monetization And Premium

- Add real purchase verification through a trusted backend path before permanent
  Premium unlock.
- Configure production AdMob app/ad unit IDs outside source code.
- Run consent-region QA and Android test-ad QA.
- Add server-side entitlement restore flow before accepting payments.
- Keep manual finance tracking free and usable even when ads, purchase, or AI
  quota fails.

## Localization, RTL, And Export

- Finish the broad localization pass for Add Expense, Categories, Recurring,
  Expenses, Reports, Export, Settings, AI, and monetization surfaces.
- Run manual Arabic RTL QA on a small Android viewport with keyboard open.
- Visually inspect Arabic PDF export with real data and mixed Arabic/English
  rows. The Arabic font asset is already present; this is visual/manual QA, not
  missing font setup.
- Plan 047 Worker 047 documented the manual RTL/PDF QA checklist, but the
  actual device and PDF visual inspection remain blocked until a parent
  integration pass can run Flutter/device/PDF verification.
- Clean up harmless PDF Helvetica warning output if it keeps appearing during
  automated tests.
- Add more localized widget tests for Add Expense, Settings, Free/Premium, and
  AI Assistant.
- Plan 061 Worker 1 updated ARB/source localization for Recurring, Reports,
  Export, Saving Goals, AI Assistant, and Free/Premium, but `flutter gen-l10n`,
  widget tests, small-screen RTL device QA, and Arabic PDF visual inspection
  remain blocked for the parent verification pass.
- Plan 088 completed another P1 localization pass for Auth, Budget, App Lock,
  Home/Engagement prompts, and rewarded AI credit copy. Still run device RTL QA
  and continue lower-priority localization for any provider/service messages
  that are intentionally preserved until they reach a UI mapping boundary.

## Observability And Operations

- Decide when to add Firebase Crashlytics, Analytics, and Remote Config.
- Wire feature flags into AI, ads, premium CTA, receipt AI, advice AI, and
  rewarded credits.
- Keep telemetry privacy-safe: no descriptions, receipt text/images, auth
  tokens, PIN/biometric data, provider keys, or raw sensitive prompts.
- Add release runbooks for logs, incident response, rollback, and support.
- Configure a real off-server encrypted backup destination and alerting for
  backup/restore-check failures before VPS production cutover.
- Protect the VPS `/metrics` endpoint behind Nginx allowlists or auth before
  exposing the API domain publicly.
- Create an aaPanel/Nginx post-create checklist or template override so new
  proxied subdomains consistently use the public-IP `listen` form and do not
  emit unsupported `quic` listeners.
- Replace the Plan 082 in-memory metrics collector with a durable monitoring
  backend or external scraper if production diagnostics need historical trends.
- Run Plan 083 real-device QA in `vpsLocalFirst` mode against a configured VPS
  endpoint before building a release artifact for migration testing.

## Verification Follow-Up

- Superseded: the out-of-scope guided tour/Home widget test failures surfaced
  during the Plan 041 full-suite run were repaired in Plan 043. The constitution
  baseline records `flutter gen-l10n`, `flutter analyze --no-pub`, targeted
  guided-tour/Home/Settings/repository tests, and full `flutter test --no-pub
  --reporter expanded --concurrency=1 --timeout 45s` passing with 290 tests.
  Keep future guided-tour regressions in a new Spec Kit plan.
- Fix local Dart telemetry file permissions if formatter/analyzer commands keep
  exiting after successful work with
  `AppData\Roaming\.dart-tool\dart-flutter-telemetry-session.json` access denied;
  direct Dart CLI commands should use `dart --suppress-analytics <command>` until
  the local telemetry files are repaired.
- Keep Flutter verification/build commands running outside the Codex sandbox via
  the approved `C:\flutter\bin\flutter.bat` command path. Sandboxed Flutter
  commands can hang while writing SDK cache/lock state and leave orphaned
  `git.exe` processes, while the same command outside the sandbox completes
  normally.
- When isolating a single Flutter test from PowerShell, pass long `--plain-name`
  values with safe argument quoting; otherwise `flutter.bat` can treat each word
  as a separate test file and leave misleading hanging runner processes.

## Product And Retention

- Keep historical Speckit task status aligned after each new implementation
  plan so old unchecked items are marked completed, superseded, or blocked with
  a clear note.
- Add explicit subscription renewal notification settings and dated one-shot
  reminder scheduling before enabling renewal alerts in Subscription Center.
- Execute `specs/062-account-profile-management` for full account management:
  both Google and email/password accounts, app-local display name independent
  from Google profile, in-app account deletion with warning/confirmation, and
  no profile photo/avatar scope.
- Add Home navigation widget tests for core shortcuts and menus.
- Add broader Settings widget tests for currency, payment, notifications,
  security, AI, monetization, and support sections. These tests should use
  fakes and avoid real Firebase, ads, notifications, local auth, speech, or
  camera plugins.
- Refine onboarding/checklist prompts after first real-user feedback.
- Run manual real-device QA for the guided product tour on Android after a clean
  install, including skip, complete, replay from Settings, back button, target
  scrolling after Plan 048, and Arabic RTL small-screen placement.
- Capture Plan 089 guided-tour visual QA screenshots in Arabic and English on a
  real Android device after the connector/card polish is installed.
- Add deterministic local nudges and challenges without consuming AI quota.
- Add a safe in-app feedback/support destination before public launch.
- Execute expense list scaling from `specs/051-expense-list-scaling` after
  correctness and localization work; add a dedicated full-history search index
  later only if product needs global search beyond loaded/date-scoped data.
- Evaluate exact minor-unit money storage and currency-specific decimal
  precision later if the app needs stricter accounting than decimal-compatible
  display and Firestore numeric storage.
- Add exchange-rate provider selection, refresh cadence controls, transaction-
  date historical rates, and offline freshness indicators after the live-rate
  MVP is stable.
- Add an explicit legacy expense snapshot backfill/migration flow so pre-Plan
  084 mixed-currency expenses can be converted with auditable historical
  evidence instead of runtime fallback rates.
- Recompute AI command money-edit snapshots with loaded settings before
  allowing AI amount/currency/date updates to persist.
- Complete wallet and transfer UI surfaces before treating Plan 075 as a
  user-facing feature: wallets list, Add/Edit Expense wallet selector, transfer
  form, Expenses wallet filter, and Reports transfer exclusion fixtures.
- Define cross-currency wallet transfer conversion policy before showing
  combined wallet balances across currencies.
- After fixing Reports conversion, decide whether category budgets, subscription
  monthly impact, and other secondary finance summaries should also convert
  mixed currencies instead of keeping conservative same-currency warnings.

## Data Portability And Restore

- Complete backup/restore UI, restore confirmation, conflict policy, repository
  write execution, and round-trip restore tests before enabling user-facing
  restore. Current backup serialization and preview coverage includes wallets
  and transfers, but restore writes remain intentionally disabled.

## Store Readiness

- Prepare Play Store privacy/data safety answers for expenses, Firebase, AI
  gateway, ads, notifications, camera, microphone, and local auth.
- Prepare screenshots, app icon, content rating, support email, and privacy
  policy.
- Confirm test ads are not used in public release.
- Confirm release build includes the real Worker URL and no local/mock-only AI
  configuration.
