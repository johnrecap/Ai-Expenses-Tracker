<!--
Sync Impact Report
Version change: 1.25.0 -> 1.26.0
Modified principles: Project Conventions clarified account deletion recent-auth
ordering and exchange-rate base-currency invalidation/target coverage.
Added sections: None.
Removed sections: None.
Templates/guidance reviewed: .specify/templates/plan-template.md (reviewed, no
change), .specify/templates/spec-template.md (reviewed, no change),
.specify/templates/tasks-template.md (reviewed, no change), AGENTS.md
(reviewed, no change).
Follow-up TODOs: None.
-->

# Expense Tracker Constitution

This constitution is mandatory for this project. Every agent working in this repository must follow it before changing code, configuration, documentation, generated workflow files, or tests.

## Rule 0: Skill-First Workflow

Before any project work, the agent must:

1. Read `.specify/memory/constitution.md`.
2. Read `.agents/workflows/development.md`.
3. Read `.agents/skill-matcher.json`.
4. Match the user request to the relevant skills.
5. Read every matched `SKILL.md`.
6. Announce the skills being used and why.
7. Continue only after the workflow requirements are clear.

If a requested skill is not installed, the agent must report it and use the closest installed project workflow without pretending the missing skill exists.

## Rule 1: Spec-Driven Development Is Required

All feature work, bug fixes, refactors, UI changes, Firebase changes, AI Assistant changes, and documentation changes must follow this order:

1. `speckit-constitution` when project principles need to be created or updated.
2. `speckit-specify` to create or update the feature specification.
3. `speckit-clarify` when requirements are ambiguous.
4. `speckit-plan` to create the implementation plan.
5. `speckit-tasks` to create the task list.
6. `speckit-analyze` or `speckit-checklist` when consistency or requirements quality needs validation.
7. `speckit-implement` or the approved local execution workflow to implement the task list.
8. Verification commands before reporting completion.
9. Update this constitution if architecture, conventions, packages, or known features changed.

For simple read-only analysis, the agent may create an analysis document instead of implementation artifacts, but must still read this constitution and report the relevant workflow.

When the user asks for plans, detailed plans, bug-fix plans, feature plans,
review action plans, roadmap execution plans, or implementation approaches, the
deliverable must be Spec Kit artifacts under `specs/<number>-<feature>/`.
The minimum executable planning set is `spec.md`, `plan.md`, and `tasks.md`;
use `research.md`, `data-model.md`, `quickstart.md`, `contracts/`, and
checklists when the scope needs them. A chat response may summarize and link to
those artifacts, but it must not replace them with standalone planning files.

Standalone plan files under `docs/`, `docs/superpowers/plans/`, or ad hoc
Markdown documents are allowed only for read-only analysis, archival notes, or
deferred backlog documentation. They are not authoritative implementation
plans unless a Spec Kit plan explicitly references them as supporting context.

If a request covers multiple independent subsystems, the agent must either
create an umbrella Spec Kit feature with separate user stories and tasks, or
split the work into separate numbered Spec Kit features. The agent must not
collapse unrelated Firebase, Flutter UI, localization, monetization, and release
work into one vague plan.

## Rule 2: Current Architecture

- Language: Dart 3.x.
- Framework: Flutter.
- State management: Bloc and Flutter Bloc.
- Backend: Firebase Core and Cloud Firestore through a local repository package.
- Authentication: Firebase Authentication is integrated through `AuthRepository`, `FirebaseAuthRepository`, and `AuthBloc`, including email/password and Google Sign-In provider flows through `google_sign_in`.
- Repository pattern: `packages/expense_repository` exposes models, entities, auth/settings repositories, `ExpenseRepository`, `FirebaseExpenseRepo`, `CategoryRepository`, `FirebaseCategoryRepository`, and the other feature-specific repository interfaces.
- Expense schema: expenses include user ownership, category snapshot fields, description, payment method, currency, timestamps, source, and optional recurring/AI references while keeping legacy embedded category parsing.
- User settings: `SettingsRepository` and `FirebaseSettingsRepository` store profile settings under `users/{userId}/settings/profile`, including app-local display name, explicit app language preference independent from currency, supported currencies, conversion rates, default payment method, notification settings, onboarding, guided tour fields, and daily cached exchange-rate metadata.
- Account/profile: `lib/screens/account` and account services provide provider metadata, app-local display name editing independent from Google profile data, provider-aware actions, and in-app account deletion orchestration through repository/auth boundaries.
- Monthly budgets: `BudgetRepository` and `FirebaseBudgetRepository` store deterministic monthly budgets under `users/{userId}/budgets/{yyyy-MM}`.
- Category budgets: `CategoryBudgetRepository` and `FirebaseCategoryBudgetRepository` store archived/user-owned category monthly limits under `users/{userId}/category_budgets/{yyyy-MM}_{categoryId}_{currency}`.
- Search and filtering: `ExpenseFilter`, `ExpenseFilterService`, and `ExpenseFilterCubit` provide local deterministic filtering after repository date-scoped reads.
- Money conversion: `MoneyConversionService`, `ExchangeRateService`, `FrankfurterExchangeRateService`, and `ExchangeRateRefreshService` refresh supported non-base currency rates at most once per local day, persist successful rates in user settings, and keep using last saved rates when the network/provider is unavailable.
- Reports: `ExpenseReport`, `ReportCalculator`, and `ReportCubit` power weekly/monthly stats from real expenses and current `UserSettings`, converting supported mixed currencies into the user's base currency while tracking converted and unconverted currency metadata.
- Recurring expenses: `RecurringExpenseRepository`, `FirebaseRecurringExpenseRepository`, and `RecurringExpenseScheduler` store client-side recurrence rules and materialize due expenses on app open.
- Subscription center: `SubscriptionSummaryService` summarizes active recurring expenses into next due dates and estimated monthly impact by currency.
- Export data: `lib/services/export` contains CSV, Excel, PDF, export request/result, and local save/share services; `ExportCubit` and `ExportScreen` collect filters and generate user-initiated exports from in-memory user expenses.
- Smart notifications: `flutter_local_notifications`, `timezone`, `NotificationService`, `NotificationScheduler`, and `NotificationSettings` support local budget alerts, daily expense check-ins, weekly digest reminders, and reminder scheduling from user settings.
- Saving goals: `SavingGoalRepository`, `FirebaseSavingGoalRepository`, `SavingGoalBloc`, and the Saving Goals screen store user-owned goals under `users/{userId}/saving_goals` with manual contributions and archive behavior.
- Wallets and transfers foundation: `WalletAccountRepository`, `TransferRepository`, `FirebaseWalletAccountRepository`, and `FirebaseTransferRepository` store manual wallet accounts under `users/{userId}/wallets` and transfers under `users/{userId}/transfers`; transfers are separate from expenses and must not be counted as spending.
- App protection: `local_auth`, `flutter_secure_storage`, `crypto`, `lib/security`, and `AppLockCubit` support optional local PIN lock and biometric unlock without storing plain PIN values.
- Advanced AI: `image_picker` and `image` support local receipt image capture and compression before backend receipt extraction; repeated expense detection and spending prediction run locally without provider calls.
- AI text expense preview: `lib/ai` contains AI intent/response/payload/preview models, strict JSON parsing, provider-swappable `AiService`, deterministic `MockAiService`, injectable `RemoteAiService`, and `AiAssistantCubit`; flexible expense drafts may leave unknown fields empty for user completion instead of blocking all parsing.
- AI commands: Plan 010 adds structured command payloads, deterministic `AiActionMatcher`, aggregate-backed `AiAdviceService`, `AiActionMapper`, and `AiActionLogRepository`/`FirebaseAiActionLogRepository`; `AiAssistantCubit` and `AiAssistantSheet` now support search, summary, advice, update preview/confirm, delete preview/confirm, and decision audit trails.
- AI provider gateway: Plan 012.5 adds `GatewayAiService`, `AiGatewayClient`, `AiProviderConfig`, and `AiGatewayException` for authenticated structured AI calls through a backend gateway; Flutter uses `http` for gateway calls and never stores provider API keys.
- Cloudflare AI gateway: `workers/ai-gateway` contains the free-plan TypeScript Worker for `aiParse`, `aiReceipt`, and `aiAdvice`, Firebase Auth token verification, Gemini 2.5 Flash REST calls, structured schema validation, D1-backed per-user quota, safe usage logging, and normalized provider errors. This is the current free Firebase/Spark AI path.
- Monetization foundation: `lib/monetization` owns entitlement snapshots, Free/Premium policy, AI quota display models, feature gates, ad consent/service abstractions, fake ad services for tests, disabled purchase hooks, and `MonetizationCubit`; authenticated app startup now provides shared monetization state, real `google_mobile_ads` wrappers for Android/iOS-capable builds, consent-aware ad startup, and test-ID defaults while keeping production IDs and purchase verification external.
- Firebase Functions gateway: `functions/` contains the older TypeScript gateways and tests, retained as optional future backend code only; it is not required for the free-plan AI path.
- Routing/navigation: direct Flutter `Navigator` and `MaterialPageRoute`; no dedicated routing package.
- UI framework/widgets: Flutter Material, Cupertino widgets, Font Awesome icons, custom logo asset, `fl_chart`, and `flutter_colorpicker`.
- Formatting/localization packages: `intl`, `flutter_localizations`, `l10n.yaml`, and ARB files under `lib/l10n` provide English/Arabic localization for current app-owned UI surfaces, with remaining manual RTL and PDF QA tracked separately.
- Storage/database: authenticated data uses Firestore user subcollections under `users/{userId}/expenses`, `users/{userId}/categories`, budgets, category budgets, recurring expenses, saving goals, settings, AI action logs, and category aliases; old global `expenses` and `categories` are denied legacy paths only.
- Firestore rules: `firestore.rules` validates the current user-owned schema, including settings profile fields, decimal amounts, supported currencies/conversion rates, account display name, notification settings, guided tour state, AI action logs, and category aliases.
- Verification tooling: `docs/qa/flutter-verification-runbook.md` and `tools/verification/` document safe Windows Flutter/Dart diagnostics and bounded verification commands for local hangs.
- Build system: Flutter toolchain with Android Gradle, iOS/macOS Xcode projects, CMake for desktop targets, and Flutter web.
- Android application id / Firebase package name: `com.saeeddevstudio.ai_expenses_tracker`.
- Target platforms: Android, iOS, web, Windows, Linux, and macOS project folders exist.
- Testing: `flutter_test` covers repository/model/service/cubit/widget slices; full-suite and targeted verification history is tracked in Rule 7 and individual Spec Kit task files.

## Rule 3: Current Product Scope

The existing app is an Expense Tracker with:

- Splash screen.
- Home screen with live monthly spending, budget remaining, authenticated/app-local display name, top category, conversion/missing-rate status, and transaction list based on current user data.
- English/Arabic localization foundation is wired at the app root, with generated `AppLocalizations`, localized core and later feature surfaces, and reusable test localization wrappers; broad RTL/manual PDF QA remains a release follow-up.
- Add Expense flow with decimal amounts, payment method, currency, category, description, date, manual save, edit/delete support through the expense list, and an AI form-fill card above the manual form.
- Category creation dialog with icon and color selection.
- Stats/Reports screens use real report calculations instead of static chart data.
- Firestore create/list/update/delete/archive operations are exposed through user-scoped repositories and rules for the current finance entities.
- Firebase Auth login, registration, password reset, logout, and auth-gated routing.
- Google Sign-In is exposed from the login screen through `AuthBloc` and `AuthRepository`, with provider cancellation returning to login without an error.
- Upgraded expense model fields for payment method, currency, description, source, category snapshot, timestamps, and repository CRUD/filter operations.
- Category management screen with create, edit, and archive flows. Archived categories are hidden from new expense entry while old expense category snapshots continue to render.
- Monthly budget screen and Home progress card with spent, remaining, warning threshold, exceeded state, and saved-rate mixed-currency conversion where supported.
- Category Budgets screen supports per-category monthly limits with create, edit, archive, progress, threshold/exceeded state, and conservative mixed-currency warnings pending a future conversion audit.
- Filterable expenses screen reachable from Home `View All`, with search, reset, date, category, amount, payment method, and currency filters.
- Reports screen replaces static redacted stats with real weekly/monthly bar chart, category breakdown, top category, period comparison, saved-rate mixed-currency conversion, and converted/unconverted currency status.
- Recurring Expenses screen supports daily, weekly, and monthly rules with archive/pause behavior and client-side generation of due expenses.
- Subscription Center screen lists active recurring expenses with next due date, payment method, frequency, amount, and estimated monthly impact by currency.
- Export Data screen supports date-range export of current user expenses to CSV, Excel, and PDF with optional category, payment method, and currency filters plus local save/share flow.
- Smart notification settings support budget alerts, daily reminder toggles, reminder time selection, local notification channels, permission handling, and reminder scheduling.
- Saving Goals screen supports creating, editing, manually contributing to, and archiving active user saving goals with visible progress and remaining amount.
- Offline sync feedback uses Firestore snapshot metadata to show pending local expense writes in banners and rows until the backend acknowledges them.
- App Protection settings support creating/changing a local PIN, disabling app lock, optional biometric unlock when the device supports it, PIN fallback after biometric failure, and lock checks on launch/resume.
- AI Assistant text entry can parse natural-language expense text into structured JSON-backed preview data, allow user edits, and only create an AI-sourced expense after explicit confirmation through the existing create expense flow.
- Add Expense includes a compact AI form-fill card above the manual form; it can parse natural-language expense text into the existing fields, but the normal Save button remains the only expense commit path.
- AI Assistant command helpers can map search requests to existing filters, generate summary/advice from actual aggregates, produce update/delete target candidates, and log preview/confirmation/cancel/failure status.
- AI Assistant can be configured with `--dart-define=AI_GATEWAY_URL=...` to use the backend Gemini gateway; without that configuration it falls back to the deterministic local mock service.
- AI Assistant receipt capture can send compressed receipt images through the configured AI gateway for structured extraction, then shows the same editable confirmation preview before any expense is saved.
- AI financial advice is explicit user-triggered guidance with daily backend quota and same-day cache; repeated expense suggestions and spending prediction remain local so they work when AI quota or Firebase Functions is unavailable.
- First-run setup onboarding appears after authentication for users whose settings are incomplete. It requires explicit language, base currency, and default payment method choices before Home, explains AI preview/limits without provider calls, and offers optional reminder setup without blocking access.
- Guided product tour appears after first-run setup for users who have not completed or skipped the current tour version. It uses `GuidedTourCubit`, `GuidedTourHost`, `SpotlightTarget`, and localized `TourOverlay` steps to explain AI Assistant, manual entry, AI confirmation, budget, reports, categories, settings, and Free/Premium behavior without calling AI, ads, purchases, permissions, camera, speech, or notification services.
- AI category intelligence resolves AI add-expense categories against the user's active category list, curated Arabic/English aliases, recent expense hints, and user-scoped learned aliases before showing preview. Missing categories are shown as editable suggestions and are only created after explicit confirmation.
- Modern category visuals use `CategoryIconRegistry`, `CategoryIconView`, and curated color presets to render backward-compatible Material category icons without relying on old per-category PNG assets.
- Home live data uses `HomeSummary` and `HomeSummaryCalculator` to keep dashboard finance math out of widgets and avoid fake balance/income values.
- Settings are grouped into profile/account, language, currency/payment, notifications, protection, AI usage, monetization, support, and privacy sections while persisting through `SettingsCubit`, `AccountProfileCubit`, and repository services. Settings must refresh live after profile/language/currency edits without requiring an app restart.
- AI voice dictation uses `speech_to_text` through `lib/ai/voice` to fill the existing AI Assistant text input only; parsing, preview, and confirmation remain owned by the existing AI Assistant flow.
- Free/Premium monetization foundation includes a Free/Premium screen, plan comparison widgets, local policy defaults, consent-aware ad gates, frequency caps, rewarded AI credit plumbing, and future purchase verification hooks without shipping production ad IDs or client-side Premium unlocks.
- Retention engagement loops are local and optional: tracking streaks, weekly digest, and spending health score are calculated under `lib/engagement` from existing expenses, budgets, reports, and settings without AI provider calls.
- Account/Profile supports both Google and email/password accounts, app-local display name independent from provider profile data, no profile-photo scope, and an explicit in-app deletion flow with warning/confirmation.
- Wallet account metadata can be stored on expenses as optional historical wallet snapshots while existing expenses without wallet fields remain valid.
- Daily exchange-rate cache refreshes supported non-base currencies once per local day, persists successful rates in settings, and keeps the last saved rates when offline.
- AI Assistant and Add Expense accept flexible natural-language expense drafts: known fields are filled, unknown fields remain editable, and the user can complete the manual form before saving.

The remaining roadmap and release follow-up includes:

- Currency conversion audit for category budgets, subscriptions, exports, notifications, and other secondary finance summaries.
- Historical transaction-date exchange rates or explicit latest-rate-only product copy.
- Production Firebase rules/index deploy and real-user smoke tests.
- Account deletion and reauthentication end-to-end validation on Google and email/password accounts.
- Full localization/RTL manual QA, keyboard-open checks, and Arabic PDF visual inspection.
- Production AdMob IDs, purchase verification backend, entitlement restore, and Play Store readiness.
- Real AI gateway Android QA, monitoring, quota/provider error alerts, and production `AI_GATEWAY_URL` validation.
- Crashlytics/Analytics/Remote Config decision and privacy-safe operational runbooks.

## Rule 4: Data Ownership

Any future Firebase work must isolate data per user. The preferred structure is:

```text
users/{userId}/categories/{categoryId}
users/{userId}/expenses/{expenseId}
users/{userId}/budgets/{budgetId}
users/{userId}/category_budgets/{categoryBudgetId}
users/{userId}/recurring_expenses/{recurringExpenseId}
users/{userId}/saving_goals/{savingGoalId}
users/{userId}/ai_actions/{actionId}
users/{userId}/category_aliases/{aliasId}
users/{userId}/settings/profile
```

Global `expenses` and `categories` collections must not be extended for authenticated production data unless a migration plan explicitly chooses that path.

## Rule 5: AI Assistant Safety

AI features must use a separate service layer. The AI Assistant must never write to Firestore directly.

Required AI flow:

1. User enters text, voice transcript, or receipt image data.
2. AI service returns structured JSON.
3. AI Cubit/Bloc validates intent, confidence, required fields, and ambiguity.
4. UI shows a preview.
5. User edits or confirms.
6. Existing domain Bloc/repository performs the mutation after confirmation.

AI add, update, and delete actions require explicit user confirmation. Low-confidence results must ask for clarification or present an editable partial draft instead of guessing required values. Missing amount, category, date, currency, payment method, or description fields must remain user-editable blanks/defaults and must not force an AI failure when the user can complete the form manually.

## Rule 6: Code Style and Change Scope

Agents must preserve the existing project style unless a spec explicitly approves a focused improvement.

Rules:

- Keep Bloc/Cubit as the state-management approach.
- Keep repository access behind interfaces.
- Do not rebuild the app from scratch.
- Do not mix AI provider code into widgets.
- Do not place all future repository methods in one oversized repository.
- Prefer small feature-focused files.
- Validate user input before parsing numbers or dates.
- Keep Firestore serialization in entity/model mapping code.
- Do not introduce a new state-management package without a spec and approval.

## Rule 7: Verification

Before claiming implementation work is complete, run the most relevant commands:

```text
flutter pub get
flutter analyze
flutter test
```

If a command fails because of an existing unrelated issue, report the exact failure and whether the change made it worse.

Current known verification baseline:

- `flutter analyze` passed with no issues after Plan 001.
- `flutter test` passed after replacing the default counter test with a splash smoke test in Plan 001.
- `flutter analyze` passed with no issues after Plan 002 auth and user-scoped data integration.
- `flutter test` passed after Plan 002 with AuthBloc, repository path, and splash smoke tests.
- `flutter analyze` passed with no issues after integrating Plans 003, 004, and 005.
- `flutter test` passed after Plans 003, 004, and 005 with 22 passing tests, including payment/currency persistence coverage.
- `flutter analyze` passed with no issues after Plan 006 monthly budget.
- `flutter test` passed after Plan 006 with 31 passing tests, including budget calculator, entity, and Bloc coverage.
- `flutter analyze` passed with no issues after Plan 007 advanced search and filters.
- `flutter test` passed after Plan 007 with 38 passing tests, including filter service and Expenses screen coverage.
- `flutter analyze` passed with no issues after Plan 008 weekly/monthly reports.
- `flutter test` passed after Plan 008 with 43 passing tests, including report calculator and cubit coverage.
- `flutter analyze` passed with no issues after reviewing and completing deferred AI command integration from Plan 010.
- `flutter test --reporter expanded` passed after reviewing Plans 009, 010, and 011 with 74 passing tests, including AI command Cubit update/delete confirmation coverage and recurring scheduler coverage.
- `flutter analyze` passed with no issues after Plan 012 export data implementation.
- Targeted export tests passed after Plan 012, including CSV escaping/filtering and CSV/Excel/PDF exporter routing coverage.
- `flutter analyze` passed with no issues after integrating Plans 013 smart notifications, 014 saving goals, and 015 offline sync feedback.
- `flutter test` passed after integrating Plans 013, 014, and 015 with 91 passing tests.
- Firebase Functions gateway verification passed after Plans 013, 014, and 015 with `npm test` and `npm run build`.
- Android release APK build passed after Plans 013, 014, and 015 at `build/app/outputs/flutter-apk/app-release.apk`.
- `flutter analyze` passed with no issues after Plan 016 app protection.
- `flutter test` passed after Plan 016 with 98 passing tests, including PIN hashing and app lock Cubit coverage.
- Android release APK build passed after Plan 016 at `build/app/outputs/flutter-apk/app-release.apk`.
- `flutter analyze` passed with no issues after reviewing and integrating Plans 024 and 025.
- `flutter test --reporter expanded --concurrency=1` passed after Plans 024 and 025 with 180 passing tests, including Google AuthBloc coverage, AI category intelligence, monetization widgets, voice input, and repaired category/budget/auth stream tests.
- Android release APK build passed after Plans 024 and 025 at `build/app/outputs/flutter-apk/app-release.apk`; `android/gradle.properties` now limits Gradle/Kotlin memory use to avoid local Windows paging-file failures during release builds.
- `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, and `flutter test --reporter expanded --concurrency=1` passed after Plans 029 and 030 with 180 passing tests; this includes removal of unused assets/demo data/chart/redacted dependency and generated Arabic/English localization files.
- Android release APK build passed after Plans 029 and 030 at `build/app/outputs/flutter-apk/app-release.apk`.
- `flutter pub get`, `flutter analyze`, and `flutter test --reporter expanded --concurrency=1` passed after integrating Plans 026, 027, and 028 with 186 passing tests; this includes shared monetization state, production AdMob service wrappers, and live AI quota surfaces.
- `workers/ai-gateway` verification passed after Plan 028 with `npm test` (45 passing tests) and `npm run typecheck`.
- Android release APK build passed after Plans 026, 027, and 028 at `build/app/outputs/flutter-apk/app-release.apk`; `android/app/build.gradle` must preserve both `applicationName` and `admobApplicationId` manifest placeholders.
- `flutter analyze` and `flutter test --reporter expanded --concurrency=1 --timeout 45s` passed after integrating Plans 031, 032, and 033 with 214 passing tests; this includes Home scroll overflow repair, local engagement calculators/notifications, category budgets, and subscription summaries.
- Android release APK build passed after Plans 031, 032, and 033 at `build/app/outputs/flutter-apk/app-release.apk`.
- The current folder is a Git repository, but Git-based Spec Kit extension commands may still require a valid branch/commit workflow before they can automate feature setup or commits.
- `flutter analyze` passed with no issues after Plan 040 spec cleanup and Home/Settings widget coverage.
- `flutter test --reporter expanded --concurrency=1 --timeout 45s` passed after Plan 040 with 240 passing tests, including Home navigation and Settings smoke coverage.
- `flutter gen-l10n` passed after Plan 041 language/currency preference integration.
- `flutter analyze --no-pub` passed after Plan 041 with no issues.
- Plan 041 targeted Flutter tests passed with 50 passing tests across settings entity, settings cubit, app language preference, AI gateway client, AI assistant cubit, Add Expense defaults, and AI defaults guard coverage. Full `flutter test --no-pub --reporter compact --concurrency=1 --timeout 45s` was run and no longer hangs, but it still fails on out-of-scope guided tour/Home widget tests introduced by later plans; handle those separately instead of mixing them into Plan 041.
- `flutter gen-l10n`, `flutter analyze --no-pub`, and Plan 042 targeted tests passed after completing first-run setup onboarding. The targeted test command covered `test/onboarding`, `test/auth/auth_gate_test.dart`, and `test/settings/settings_cubit_test.dart` with 21 passing tests. Full suite was not rerun in this pass because the known remaining failures are guided tour/Home tests from Plan 43 and must stay out of the Plan 42 scope.
- `flutter gen-l10n`, `flutter analyze --no-pub`, targeted Plan 043 guided-tour/Home/Settings/repository tests, and full `flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s` passed after completing guided product tour fixes with 290 passing tests.
- `flutter analyze --no-pub` passed after Plan 044 settings rules repair. Rules emulator verification remains a separate `cd functions; npm run test:rules` command and must not be confused with ordinary `npm test`.
- `flutter gen-l10n`, `flutter analyze --no-pub`, and targeted expense tests passed after Plan 049 manual expense edit/delete.
- `flutter analyze --no-pub` passed after Plan 050 decimal amount support.
- `flutter analyze --no-pub` passed after Plan 051 expense list scaling.
- Plan 052 added `tools/verification/diagnose_toolchain.ps1`, `tools/verification/safe_dart_format.ps1`, and updated `docs/qa/flutter-verification-runbook.md` for bounded Windows Flutter/Dart diagnostics.
- `flutter analyze --no-pub` and Android release APK build passed after Plan 053 release auth/load stability.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 054 editable profile identity.
- `workers/ai-gateway` `npm test`, `npm run typecheck`, and `flutter analyze --no-pub` passed after Plan 055 AI expense inference.
- `workers/ai-gateway` `npm test`, `npm run typecheck`, and `flutter analyze --no-pub` passed after Plan 056 flexible AI expense drafts.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 057 multi-currency conversion totals.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 058 settings live refresh stability.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 059 AI-first add entrypoint.
- `flutter analyze --no-pub` and Android release APK build passed after Plan 060 daily exchange-rate cache.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 061 localization RTL release pass; manual small-screen RTL, keyboard-open, widget-test, and Arabic PDF checks remain open.
- `flutter gen-l10n` and `flutter analyze --no-pub` passed after Plan 062 account profile management; reauthentication UX and real Firebase deletion validation remain open.
- `flutter analyze --no-pub` and targeted report/AI/engagement/Home tests passed after Plan 063 reports currency conversion. The targeted tests covered reports, AI assistant/advice/usage/gateway, engagement, and Home conversion paths with 70 passing tests. Manual APK check remains open.

## Rule 8: Project Setup State

The project has local agent setup files:

- `.agents/skills`
- `.agent/skills`
- `.agents/workflows/development.md`
- `.agent/workflows/development.md`
- `.agents/skill-matcher.json`
- `.agent/skill-matcher.json`
- `.agents/MANDATORY_RULES.md`
- `.agent/MANDATORY_RULES.md`
- `.specify`

Spec Kit was initialized for Codex skills mode. `speckit-*` skills are installed under `.agents/skills` and mirrored to `.agent/skills` for the Antigravity folder.

## Rule 9: Internet and External Tooling

When a setup step fails because a tool, package, or skill cannot be found locally, the agent must:

1. Reproduce the failure.
2. Inspect local files and command output.
3. Search official sources when the user asks for internet research or when current tooling may have changed.
4. Prefer official documentation or primary repositories.
5. Cite the source used in the final report.
6. Apply the minimal fix that completes the setup.

## Rule 10: Governance

- This constitution overrides generated templates in this repository.
- User instructions override this constitution when there is a direct conflict.
- Any future change that alters architecture, packages, data model, workflow, or verification commands must update this file.
- Do not leave `[FILL_IN]`, `TBD`, or placeholder sections in this constitution.

## Project Conventions

- Root app files live under `lib/`.
- Feature screens are currently grouped under `lib/screens/`.
- Bloc files are grouped under each screen feature folder.
- Shared Firestore models and repository abstractions live in `packages/expense_repository`.
- App logo assets live under `assets/`; category icons must be rendered through `CategoryIconRegistry` and `CategoryIconView` while keeping the stored category icon as a string key for backward compatibility.
- Dates are formatted using `intl`.
- Static user-facing strings introduced in localized surfaces must use `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`; run `flutter gen-l10n` after ARB changes. User-generated content such as category names, descriptions, and notes must not be translated.
- Firestore entity conversion is handled with `toEntity`, `fromEntity`, `toDocument`, and `fromDocument`.
- Expense serialization must preserve backward compatibility with old documents that only contain `expenseId`, embedded `category`, `date`, and `amount`.
- Auth state is owned by `lib/screens/auth/blocs/auth_bloc/`; widgets must not import `firebase_auth` directly.
- Google Sign-In must also go through `AuthRepository` and `AuthBloc`; widgets must not import `firebase_auth`, `google_sign_in`, or plugin-specific auth types directly.
- User-scoped Firestore repositories must be created only after `AuthAuthenticated` provides a non-empty `userId`.
- Category reads/writes are owned by `CategoryRepository`; new category work must not add category methods back to `ExpenseRepository`.
- Category deletion must be implemented as archival with `isArchived = true` unless a future spec explicitly defines a migration-safe hard-delete workflow.
- Category UI must not build `assets/{category.icon}.png` paths directly. New category pickers must use `CategoryIconRegistry` for icon choices and `CategoryColorPresets` for curated color swatches, with `flutter_colorpicker` available only for custom colors.
- User settings must be accessed through `SettingsRepository`; widgets must not read or write `users/{userId}/settings/profile` directly. Settings profile writes must satisfy `firestore.rules` `validSettings`, including display name, language, currencies, conversion rates, notifications, onboarding, guided tour, and exchange-rate timestamp fields.
- Account/profile UI must use `AccountProfileCubit` and account/profile services. App-local display name must remain independent from Firebase Auth/Google display name after user edits, and no profile-photo/avatar upload scope may be introduced without a new Spec Kit plan.
- Account deletion must require explicit warning/confirmation, route sensitive auth work through repository/services, require provider-appropriate recent authentication before user-scoped data deletion, avoid orphaning user-scoped Firestore data, and be validated against both Google and email/password providers before public release.
- First-run setup must route authenticated users through `FirstRunOnboardingGate` when `UserSettings.requiresOnboarding` is true. Completing setup must save explicit language, base currency, supported currencies, default payment method, `onboardingCompleted`, and `onboardingVersion` through `SettingsRepository`.
- Guided tour state must persist through `UserSettings.guidedTourCompletedVersion`, `guidedTourSkippedVersion`, and `guidedTourLastStepId`. Tour targets must be registered with `SpotlightTarget`; feature widgets must not embed overlay logic or call AI, ads, purchases, permission, camera, speech, or notification services from tour steps.
- App language must use `UserSettings.languagePreference` (`system`, `en`, or `ar`) and must not be inferred from currency. Currency must not be inferred from language.
- Home financial totals must be calculated through `HomeSummaryCalculator`; widgets must not reintroduce hardcoded user names, fake income, fake balances, or hardcoded exchange rates.
- Exchange rates must refresh through `ExchangeRateRefreshService` at most once per local day for the user's supported non-base currencies when valid target coverage exists, persist successful rates and `exchangeRatesUpdatedAt` through `SettingsRepository`, and keep using the last saved rates when the provider or network is unavailable. Changing the base currency must clear saved conversion rates and `exchangeRatesUpdatedAt` because rates are keyed only by source currency into the current base. Finance code must not hardcode exchange rates.
- `MoneyConversionService` is the shared conversion boundary for source-currency expenses into the user's base currency. Reports, Home, AI summaries/advice, and weekly digest must use the same saved-rate conversion semantics when they aggregate mixed currencies.
- Add Expense and AI preview defaults must come from `UserSettings.baseCurrency`, `supportedCurrencies`, and `defaultPaymentMethod`, while explicit user or AI parsed values keep priority.
- Add Expense and AI Assistant save paths must not silently use fallback currency or payment settings after settings load failure; users must retry settings or make explicit choices first.
- Notification preferences live inside `UserSettings.notificationSettings`; notification scheduling must respect those settings, include daily check-in and weekly digest controls, and must not block app startup or expense creation if permission is denied.
- App protection secrets and settings are local-device state under `lib/security`; plain PIN values must never be stored, app lock changes must go through `AppLockService`/`PinService`, and biometric unlock must keep PIN fallback available.
- Monthly budget work must use `BudgetRepository`; budget progress must be calculated from current expenses, not stored counters.
- Category budget work must use `CategoryBudgetRepository`; category budget progress must be calculated from current same-month, same-category expenses and must not claim converted totals until a dedicated conversion audit updates that surface.
- Saving goals must use `SavingGoalRepository`; deletion must be implemented as archival unless a future spec explicitly defines hard-delete behavior.
- Wallet accounts and transfers must use their repository boundaries. Wallet and transfer deletion must be archival unless a future spec explicitly defines a migration-safe hard-delete workflow.
- Transfers must remain separate from expenses and excluded from spending totals; transfer fees must not become categorized spending until a future Spec Kit plan defines that behavior.
- Mixed-currency calculations must not add incompatible currencies together without a valid saved rate and a documented product surface. Missing or invalid rates must be excluded and surfaced as missing-rate/unconverted status, not silently summed.
- Expense list filtering must keep Firestore queries conservative: use date-scoped reads first, then deterministic local filtering via `ExpenseFilterService`.
- Offline expense sync feedback must use Firestore metadata (`hasPendingWrites` with metadata-change snapshots) before adding reachability packages or custom local databases.
- Reports must be calculated by `ReportCalculator` from expense lists and `UserSettings`; report widgets should receive prepared report data and avoid recalculating aggregation in UI. `ExpenseReport.convertedCurrencies`, `unconvertedCurrencies`, and `ignoredCurrencyCount` must distinguish included converted expenses from excluded missing-rate expenses.
- Recurring expense rules must be accessed through `RecurringExpenseRepository`; generated expenses must use deterministic ids based on recurring rule id and scheduled date.
- Subscription summaries must read active recurring rules through `RecurringExpenseRepository` and must not infer subscriptions from unrelated expenses unless a future spec defines that behavior.
- Generated recurring expenses must set `ExpenseSource.recurring` and `recurringExpenseId`; generated past expenses must not be modified when a rule is archived.
- Monthly recurring calculations must preserve the original start day and clamp safely for shorter months.
- Export features must use `ExportService` implementations under `lib/services/export`; widgets must not build CSV, Excel, PDF, or direct filesystem/share behavior inline.
- Exported rows must be selected through `ExportRequest` and existing `ExpenseFilterService` semantics so exported files match the user-visible filtering rules.
- AI provider responses must be parsed through `AiResponseParser`; unstructured text must be rejected and low-confidence add-expense results must ask for clarification or produce an editable partial draft when safe. The app must not reject a useful AI draft only because optional fields are missing.
- AI gateway parse, receipt, and advice requests must use `AiContext.locale` derived from the resolved app language instead of hardcoded locale values.
- AI-created expenses must use `ExpenseSource.ai` and must be created by existing domain Bloc/repository flows after user confirmation, not by an AI service.
- AI voice features must go through `AiVoiceInputService` and `AiVoiceInputController`; widgets may consume transcript state but must not use speech plugin APIs directly or trigger AI mutations from voice callbacks. Preferred voice locale should follow the resolved app language and fall back to plugin default when unavailable.
- AI search, summary, and advice commands must use deterministic app services (`ExpenseFilter`, `ReportCalculator`, `BudgetCalculator`) as ground truth before any UI display or AI rephrasing, and assistant UI must display the interpreted result before navigation or presentation.
- AI update/delete commands must use explainable target previews from `AiActionMatcher`; they must not call `updateExpense` or `deleteExpense` until the user confirms an exact target in UI through `AiAssistantCubit.confirmCommand`.
- AI action history is stored through `AiActionLogRepository` under `users/{userId}/ai_actions`; valid statuses are `previewed`, `confirmed`, `canceled`, and `failed`.
- AI action logs may include provider metadata fields `provider`, `model`, `providerRequestId`, `inputTokens`, `outputTokens`, and `errorCode`; these fields must never contain provider secrets or raw authorization headers.
- AI category matching must go through `AiCategoryResolver`; widgets must not implement their own source-word/category matching. Learned aliases must use `CategoryAliasRepository` under `users/{userId}/category_aliases` and must ignore archived category targets.
- AI suggested categories must stay in preview metadata until the user confirms. Category creation for suggestions must go through `CategoryRepository.createCategory` before creating the expense; AI services and parsers must never write categories directly.
- AI gateway configuration must use `AiProviderConfig`; the only client-side configuration allowed is endpoint/provider/model/timeout/fallback behavior, never API keys.
- Gemini provider secrets must be stored only in backend secret or environment configuration such as Cloudflare Worker secret `GEMINI_API_KEY` or local ignored backend env files; Flutter source and platform folders must not contain AI provider keys.
- AI quota responses and errors must map into `AiUsageStatus` and update shared `MonetizationCubit` usage state when trusted Worker quota metadata exists; Flutter must mark usage stale rather than guessing local decrements when metadata is unavailable.
- Receipt and advice provider calls must use request-specific backend quota keys (`receipt_extraction`, `financial_advice`) and must not call the provider when the daily quota is exhausted.
- Monetization and plan checks must go through `FeatureGateService`, `MonetizationPolicyRepository`, `EntitlementRepository`, and `MonetizationCubit`; widgets must not scatter `isPremium` booleans, ad decisions, or quota math inline.
- Ads must use `AdService` and `AdConsentService` abstractions. Mobile AdMob code must stay behind `GoogleMobileAdsService`/stubs and preserve platform manifest placeholders. Production ad IDs, provider secrets, purchase verification secrets, and permanent Premium unlocks must never be stored or granted directly in Flutter client code.
- Free plan core finance features must remain usable when AI quota is exhausted, ads fail to load, consent is unavailable, or purchases are unavailable.
- Receipt images must be compressed/resized locally before upload, must not be persisted by the app or usage logs, and duplicate receipt calls should reuse a same-day local fingerprint cache where safe.
- Spending prediction and repeated expense detection must stay deterministic local services unless a future paid-plan spec explicitly changes that boundary.
- Cloudflare Worker AI gateway code lives under `workers/ai-gateway`; run `npm run typecheck`, `npm test`, and D1 migration checks there for free-plan backend verification.
- Firebase Functions code lives under `functions/`; run `npm test` and `npm run build` there only when working on the optional future Firebase Functions backend.
- Firestore rules tests live under `functions/test/firestoreRules.rules.ts`; run `cd functions; npm run test:rules` when rules/schema behavior changes, and keep it separate from ordinary `npm test` because it needs emulator tooling.
- Local notification services live under `lib/services/notifications`; widgets and blocs should call scheduler/service abstractions instead of using plugin APIs inline.
- Engagement calculators live under `lib/engagement`; streak, weekly digest, and spending health score calculations must remain deterministic, local, and free of Firebase/plugin/AI provider dependencies.
- Firestore rules are tracked in `firestore.rules` and mapped through `firebase.json`.
- Windows Flutter/Dart verification stability work lives under `tools/verification` and `docs/qa/flutter-verification-runbook.md`; use those diagnostics before leaving broad analyzer/test commands hanging.
- Read-only product/AI review context may live under `docs/`, such as `docs/app-ai-context-and-improvement-audit.md`, but executable implementation plans must still live under `specs/<number>-<feature>/`.
- Long-form roadmap and feature task breakdowns live under `docs/implementation_plans/`.
- Spec Kit feature artifacts live under `specs/<number>-<feature>/` with `spec.md`, `plan.md`, and `tasks.md`.
- Plans for fixes, additions, code review follow-ups, and roadmap execution must
  be created as Spec Kit artifacts, not as standalone implementation-plan files.
- Every `tasks.md` must be detailed enough for a new worker: purpose, files, concrete steps, verification, and done criteria for each task.

**Version**: 1.26.0 | **Ratified**: 2026-05-15 | **Last Updated**: 2026-05-21
