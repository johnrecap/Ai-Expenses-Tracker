# Expense Tracker Spec Kit Index

This folder contains Spec Kit-style artifacts for the full Expense Tracker roadmap. Each feature folder has:

- `spec.md`: what the feature must do and acceptance criteria.
- `plan.md`: technical approach, files, risks, verification.
- `tasks.md`: executable checklist for implementation.

## Execution Order

1. `001-stabilization-baseline`
2. `002-auth-user-scoped-data`
3. `003-expense-model-upgrade`
4. `004-category-management`
5. `005-payment-currency-foundation`
6. `006-monthly-budget`
7. `007-search-filters`
8. `008-reports-stats`
9. `009-ai-text-expense-preview`
10. `010-ai-commands`
11. `011-recurring-expenses`
12. `012-export-data`
13. `012.5-gemini-ai-provider`
14. `013-smart-notifications`
15. `014-saving-goals`
16. `015-offline-sync`
17. `016-app-protection`
18. `017-advanced-ai`
19. `018-cloudflare-ai-gateway`
20. `019-ai-category-intelligence`
21. `020-modern-category-visuals`
22. `021-home-settings-live-data`
23. `022-ai-voice-assistant`
24. `023-free-premium-ads`
25. `024-verification-baseline-repair`
26. `025-google-sign-in-auth`
27. `026-live-monetization-state`
28. `027-production-ads-readiness`
29. `028-ai-usage-quota-surface`
30. `029-cleanup-dead-code-assets`
31. `030-localization-rtl-polish`
32. `031-home-navigation-dashboard-polish`
33. `032-retention-engagement-loops`
34. `033-category-budgets-subscriptions`
35. `034-production-release-hardening`
36. `035-firestore-security-indexes`
37. `036-localization-export-ux-polish`
38. `037-monetization-purchases-ads`
39. `038-ai-production-reliability`
40. `039-observability-retention-readiness`
41. `040-spec-cleanup-tests-backlog`
42. `041-language-currency-preferences`
43. `042-first-run-setup-onboarding`
44. `043-guided-product-tour`
45. `044-settings-rules-repair`
46. `045-flutter-verification-baseline`
47. `046-docs-specs-alignment`
48. `047-localization-rtl-completion`
49. `048-guided-tour-polish`
50. `049-manual-expense-edit-delete`
51. `050-decimal-amounts-support`
52. `051-expense-list-scaling`
53. `052-verification-toolchain-stability`
54. `053-release-auth-load-stability`
55. `054-editable-profile-identity`
56. `055-ai-expense-inference`
57. `056-ai-flexible-expense-drafts`
58. `057-multi-currency-conversion-totals`
59. `058-settings-live-refresh-stability`
60. `059-ai-first-add-entrypoint`
61. `060-daily-exchange-rate-cache`
62. `061-localization-rtl-release-pass`
63. `062-account-profile-management`
64. `063-reports-currency-conversion`
65. `064-production-readiness-gate`
66. `065-financial-calculation-engine`
67. `066-localization-rtl-final-pass`
68. `067-account-deletion-reauth-hardening`
69. `068-add-expense-quick-capture-ux`
70. `069-ai-history-assistant`
71. `070-report-drilldowns-monthly-story`
72. `071-expense-metadata-duplicates`
73. `072-smart-budget-recommendations`
74. `073-subscription-center-upgrades`
75. `074-premium-entitlement-backend`
76. `075-wallets-transfers`
77. `076-backup-restore-import`
78. `077-hardcoded-localization-ui-polish`
79. `078-secondary-finance-surface-consistency`
80. `079-incomplete-feature-surface-readiness`
81. `080-real-device-ui-qa-hardening`

## Current Planning Additions

The newest planning batch breaks the latest requested improvements into separate implementation slices:

- `019-ai-category-intelligence`: AI maps expense source text to existing categories and suggests missing categories without creating them silently.
- `020-modern-category-visuals`: Replaces old category icon handling with a modern, centralized icon registry and picker.
- `021-home-settings-live-data`: Connects Home totals and Settings to real user data instead of placeholders.
- `022-ai-voice-assistant`: Adds speech dictation to the AI Assistant while preserving preview and confirmation.
- `023-free-premium-ads`: Defines and implements the monetization foundation for Free/Premium plans, AI quotas, polite ads, consent, rewarded credits, and future subscription hooks. It depends on the AI quota Worker path and the Settings foundation for final navigation placement.
- `024-verification-baseline-repair`: Repairs the hanging Flutter test baseline and documents reliable verification commands before more feature work.
- `025-google-sign-in-auth`: Adds direct Google Sign-In through the existing AuthRepository/AuthBloc architecture while preserving user-scoped Firebase data.
- `026-live-monetization-state`: Replaces placeholder monetization state with shared live entitlement, policy, usage, and ad readiness state.
- `027-production-ads-readiness`: Converts the ad foundation into real, consent-aware, test-ID-safe AdMob integration with Premium zero-ad guarantees.
- `028-ai-usage-quota-surface`: Shows Free AI usage, quota reset state, and separate failure messages while keeping manual/local features available.
- `029-cleanup-dead-code-assets`: Removes proven-unused demo data, old category PNG assets, dead widgets, and unused dependencies while documenting legacy backend folders.
- `030-localization-rtl-polish`: Adds Arabic/English localization foundation, fixes broken text, and makes core screens RTL-safe.
- `031-home-navigation-dashboard-polish`: Fixes Home no-op actions, especially Settings navigation, and protects real dashboard data flow.
- `032-retention-engagement-loops`: Adds local daily check-in, streaks, weekly digest, and spending health score to increase useful return visits without AI quota.
- `033-category-budgets-subscriptions`: Adds category-level budgets, a subscription center from recurring expenses, and optional local alerts.
- `034-production-release-hardening`: Documents remaining release, keystore, production-device, and deployment blockers.
- `035-firestore-security-indexes`: Documents and prepares Firestore rules/index readiness; live Firebase smoke remains external.
- `036-localization-export-ux-polish`: Adds localization/export polish; broad localization and manual RTL/PDF QA remain open.
- `037-monetization-purchases-ads`: Completes the local monetization/ad foundation and test-ID-safe ad plumbing; production AdMob and store verification remain external.
- `038-ai-production-reliability`: Hardens real Worker AI error/quota behavior and docs; Android real-Worker QA remains external.
- `039-observability-retention-readiness`: Adds observability/retention readiness work; feature flag wiring and release-device checks remain open.
- `040-spec-cleanup-tests-backlog`: Cleans historical task status, adds Home/Settings widget coverage, and aligns the persistent deferred backlog.
- `041-language-currency-preferences`: Decouples app language from currency, makes AI/voice locale follow the selected app language, and removes silent settings fallbacks.
- `042-first-run-setup-onboarding`: Adds mandatory first-run setup for language, base currency, and default payment method, plus AI safety and optional reminder introduction.
- `043-guided-product-tour`: Adds a replayable spotlight tour starting with the AI Assistant icon and covering the core finance workflow without consuming AI/ad/purchase services.
- `064-production-readiness-gate`: Turns release blockers into a single internal-release checklist for Firebase, Auth, Firestore, AI URL, AdMob, export, app lock, notifications, and account deletion.
- `065-financial-calculation-engine`: Plans a shared money calculation contract so all visible totals use consistent conversion metadata and missing-rate behavior.
- `066-localization-rtl-final-pass`: Plans final Arabic/English localization, small-screen RTL, keyboard-open, and Arabic PDF QA.
- `067-account-deletion-reauth-hardening`: Plans provider-aware reauthentication and deletion hardening for Google and email/password accounts.
- `068-add-expense-quick-capture-ux`: Plans a faster Add Expense experience with quick manual entry, natural-language AI drafts, and receipt capture using one editable draft.
- `069-ai-history-assistant`: Plans a read-only assistant for asking questions about spending history using deterministic local calculations as ground truth.
- `070-report-drilldowns-monthly-story`: Plans report drilldowns into filtered expenses and a deterministic monthly financial story.
- `071-expense-metadata-duplicates`: Plans merchant, tags, attachment policy, and deterministic duplicate warnings.
- `072-smart-budget-recommendations`: Plans local budget recommendations from recent spending history.
- `073-subscription-center-upgrades`: Plans stronger subscription summaries, upcoming renewals, mixed-currency caveats, and possible price-change signals.
- `074-premium-entitlement-backend`: Plans a safe path from Premium foundation to trusted backend entitlement verification.
- `075-wallets-transfers`: Plans a later expansion into wallets/accounts and transfers without counting transfers as spending.
- `076-backup-restore-import`: Plans structured backup/restore/import with preview and conflict handling.
- `077-hardcoded-localization-ui-polish`: Plans removal of remaining hardcoded English UI and service messages from secondary surfaces, with Arabic/English widget coverage.
- `078-secondary-finance-surface-consistency`: Plans conversion and missing-rate consistency for Category Budgets, Subscription Center, Export, AI evidence, and digest surfaces.
- `079-incomplete-feature-surface-readiness`: Plans safe gating or completion of unfinished Premium, Wallets/Transfers, and Backup/Restore entry points.
- `080-real-device-ui-qa-hardening`: Plans focused small-screen, keyboard-open, language-refresh, and finance-card UI QA hardening.

## Historical Task Status Guidance

Older unchecked tasks are not always missing implementation. Some are historical
manual QA tasks, some are superseded by later implementation plans, and some are
blocked by external setup. Before starting old work, check the latest cleanup
notes in `040-spec-cleanup-tests-backlog` and the persistent backlog in
`docs/implementation_plans/deferred-and-advanced-work.md`.

Current local/actionable follow-up areas are language/currency preference
decoupling, first-run setup onboarding, guided product tour, broad
localization/RTL polish, and feature-flag wiring.
External/deferred areas include release keystore/build, production-device QA,
Firebase deploy/smoke testing, production AdMob/store setup, and Play Store
readiness.

## Quick Verification Guide

Use Plan 024 as the baseline repair before later feature verification. Pick the command set that matches the files changed:

- Flutter app or package changes: `flutter analyze`, then `flutter test --reporter expanded`.
- Single Flutter test isolation: `flutter test --reporter expanded test/path/to_test.dart`.
- Cloudflare Worker AI gateway changes: run verification from `workers/ai-gateway` with `npm run typecheck` and `npm test`.
- Optional Firebase Functions changes: run verification from `functions` with `npm test` and `npm run build`.
- Android release readiness: run the Android release build only when the change explicitly affects Android packaging or release behavior.

## Backend Folder Roles

- `workers/ai-gateway` is the current free AI gateway path. It handles authenticated AI parse, receipt, advice, quota, and provider calls for the Firebase/Spark-compatible flow.
- `functions/` contains older Firebase Functions gateway work retained as optional legacy/future backend code. Do not edit, verify, or deploy it unless the active Spec Kit plan explicitly targets Firebase Functions.

## Worker Instructions

Before implementing any folder:

1. Read `.specify/memory/constitution.md`.
2. Read that folder's `spec.md`.
3. Read that folder's `plan.md`.
4. Execute `tasks.md` in order.
5. Mark completed tasks as checked.
6. Run verification commands.
7. Update constitution if architecture, packages, or conventions changed.

Do not implement multiple feature folders at once unless a plan explicitly says they are part of the same milestone.
