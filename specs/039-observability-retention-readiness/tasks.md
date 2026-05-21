# Tasks: Observability Retention And Readiness

**Input**: `specs/039-observability-retention-readiness/spec.md`, `plan.md`  
**Implementation Intent**: Make the app supportable in production and improve repeat use without automatic AI spending.

## Phase 1: Safe Logging And Observability Boundary

- [X] T001 Update `lib/simple_bloc_observer.dart` to disable or sanitize verbose logs outside debug mode.

  **Why**: Current observer logs every event/change/transition and can expose private expense data in production logs.
  **Steps**:
  1. Use `kDebugMode` or equivalent to restrict event/transition logging to debug builds.
  2. In release mode, log only safe error categories if any logging remains.
  3. Avoid logging raw Bloc state, raw expense descriptions, auth tokens, receipt text, or provider metadata secrets.
  4. Keep development debugging useful.
  **Done when**: Release-mode code path cannot log raw Bloc event/transition payloads.

- [X] T002 Add `lib/observability/observability_service.dart` abstraction.

  **Why**: Widgets/repositories should not directly depend on Crashlytics/Analytics APIs.
  **Steps**:
  1. Define methods for `recordError`, `logEvent`, and optional `setUserContext`.
  2. Define allowed event names and safe parameter shape.
  3. Provide a no-op implementation for tests and unsupported platforms.
  4. Keep API small and injectable.
  **Done when**: Future telemetry calls go through one safe boundary.

- [X] T003 Decide whether to add Firebase Crashlytics/Analytics/Remote Config now or document deferral.

  **Why**: These are recommended for production, but they affect privacy, platform setup, and dependencies.
  **Steps**:
  1. Evaluate adding `firebase_crashlytics`, `firebase_analytics`, and `firebase_remote_config`.
  2. If added, update pubspec and platform setup.
  3. If deferred, document exact future task and keep no-op service.
  4. Do not add telemetry that sends private expense payloads.
  **Done when**: Observability path is explicit, not accidental or half-integrated.

- [X] T004 Add observability privacy documentation in `docs/observability/privacy-safe-events.md`.

  **Why**: Future contributors need rules for what can and cannot be logged.
  **Steps**:
  1. List forbidden values: descriptions, receipt images/text, auth tokens, provider keys, raw AI prompts if sensitive, PIN/biometric data.
  2. List allowed values: feature area, error code, platform, build type, anonymized counts.
  3. Include examples of safe and unsafe events.
  **Done when**: Telemetry privacy boundaries are written and reviewable.

## Phase 2: Feature Flags And Kill Switches

- [X] T005 Add a feature flag service abstraction.

  **Why**: Risky surfaces like AI, ads, receipt extraction, and rewards may need to be disabled quickly.
  **Steps**:
  1. Define flags for AI gateway, receipt AI, advice AI, ads, rewarded credits, premium CTA, and experimental retention cards.
  2. Provide local defaults that preserve current behavior.
  3. Keep remote config optional behind the abstraction.
  4. Ensure disabled AI still leaves manual expense tracking and local reports available.
  **Done when**: The app can centralize feature availability decisions.

- [ ] T006 Wire feature flags into AI/ads/premium surfaces through existing services.

  **Why**: Flags are only useful if high-risk features actually consult them.
  **Steps**:
  1. Gate AI provider-backed actions without blocking local AI-free insights.
  2. Gate ad loading through monetization feature gate.
  3. Gate Premium purchase CTA if purchases are unavailable.
  4. Show honest localized unavailable messages.
  **Done when**: Turning off a flag disables the feature safely at UI/service boundaries.

## Phase 3: QA And Navigation Coverage

- [X] T007 Create `docs/qa/production-device-qa.md`.

  **Why**: Production readiness needs repeatable real-device checks, not only unit tests.
  **Steps**:
  1. Add environment setup: Firebase project, SHA fingerprints, Worker URL, test user, test ad ids.
  2. Add flows: register/login/google login, add expense, category, budget, recurring, export, reports, settings, AI parse, receipt, advice, offline sync, notifications, ads, premium page, app lock.
  3. Add expected result and pass/fail/blocker columns.
  4. Include screenshots/log capture instructions.
  **Done when**: A tester can execute production QA without asking for hidden steps.

- [X] T008 Add Home widget/navigation tests in `test/home/`.

  **Why**: Home shortcuts and menus are critical and previous plan still lists this gap.
  **Steps**:
  1. Test main Home actions open Add Expense, Expenses, Categories, Reports, Settings/menus as applicable.
  2. Test Category Budgets and Subscription Center menu entries navigate.
  3. Test logout confirmation opens instead of immediate sign-out.
  4. Use repository/test wrappers instead of real Firebase.
  **Done when**: Home navigation regressions are covered without hanging tests.
  **Plan 040 completion**: Added `test/home/home_navigation_test.dart` covering
  View All, Settings shortcut, budget manage navigation, and logout confirmation
  with fake repositories/blocs and no Firebase/plugin calls.

- [X] T009 Add smoke tests for Settings critical controls.

  **Why**: Settings was previously reported as not working and now has many grouped sections.
  **Steps**:
  1. Test currency/default payment save through SettingsCubit or widget interaction.
  2. Test notification toggle UI updates state.
  3. Test app protection entry points show safe UI.
  4. Test AI/monetization sections render current state.
  **Done when**: Settings has coverage for the controls users rely on.
  **Plan 040 completion**: Added `test/settings/settings_screen_widget_test.dart`
  covering currency/payment, notifications/security, AI/monetization/privacy,
  and support rendering with fake state.

- [X] T010 Add QA result template `docs/qa/qa-run-template.md`.

  **Why**: Testers need to record exact environment and blockers.
  **Steps**:
  1. Add fields for app version, build command, device model, Android version, Firebase project, Worker version, tester/date.
  2. Add pass/fail table for each journey.
  3. Add blocker severity definitions.
  **Done when**: QA runs can be compared across builds.

## Phase 4: Retention Improvements

- [X] T011 Add onboarding/checklist entry points for first-run value.

  **Why**: New users need guidance to create first category, budget, and expense quickly.
  **Steps**:
  1. Detect first-run or empty data state locally/user-scoped.
  2. Show a compact checklist, not a marketing landing page.
  3. Link to Add Expense, Categories, Budget, and AI Assistant.
  4. Allow dismissing without blocking app use.
  **Done when**: A new user has a clear path to first value.

- [X] T012 Add local weekly summary and streak prompt to Home if not already visible enough.

  **Why**: Users return when they see progress and recent behavior.
  **Steps**:
  1. Reuse existing engagement calculators for streak and weekly digest.
  2. Show compact cards/rows that do not crowd finance summary.
  3. Do not call AI provider automatically.
  4. Hide or show empty state when no useful data exists.
  **Done when**: Home provides non-AI reasons to check in.

- [X] T013 Add spending challenge or budget nudge suggestions based on local data.

  **Why**: Simple actionable nudges increase engagement without quota cost.
  **Steps**:
  1. Generate deterministic suggestions from budget progress, top category, repeated expenses, or streak.
  2. Keep suggestions short and non-judgmental.
  3. Respect disabled notifications/engagement settings.
  4. Avoid presenting AI-generated text unless user explicitly requests AI advice.
  **Done when**: Users see practical local suggestions without API calls.

- [X] T014 Add in-app feedback/support action.

  **Why**: Production users need a way to report bugs or request features.
  **Steps**:
  1. Add Settings action for feedback/support.
  2. Use mailto/share sheet or a simple documented contact path.
  3. Include app version and device info only with user consent.
  4. Do not include expense data automatically.
  **Done when**: Users can contact support safely from inside the app.

## Phase 5: Verification

- [X] T015 Run `flutter analyze`.

  **Why**: Logging, settings, and home changes affect shared app code.
  **Steps**:
  1. Run analyzer.
  2. Fix plan-caused issues.
  **Done when**: Analyzer passes.
  **Parent verification (2026-05-18)**: `flutter analyze` passed with no issues after parent fixes.

- [X] T016 Run full Flutter tests.

  **Why**: New navigation/settings/retention tests should join the baseline.
  **Steps**:
  1. Run `flutter test --reporter expanded --concurrency=1 --timeout 45s`.
  2. Confirm no test hangs.
  3. Fix failing tests caused by this plan.
  **Done when**: Full suite passes.
  **Parent verification (2026-05-18)**: Targeted engagement/settings tests passed, and the full Flutter suite passed: 233 tests.

- [ ] T017 Run Android release/internal build.

  **Why**: New assets/packages/flags can affect Android packaging.
  **Steps**:
  1. Build APK with current safe config.
  2. If observability packages were added, verify app launches.
  3. Record artifact path.
  **Done when**: Android build succeeds.

- [ ] T018 Complete one production-device QA run using `docs/qa/production-device-qa.md`.

  **Why**: Production readiness requires real-device validation.
  **Steps**:
  1. Run the checklist on a clean install.
  2. Record pass/fail/blockers in the template.
  3. File follow-up plans for any blocker outside this plan.
  **Done when**: A signed QA result exists for the build.

## Dependencies & Execution Order

- T001 should happen before adding telemetry.
- T002 to T004 define the observability boundary.
- T005 and T006 can run after T002.
- T007 and T010 can run anytime, but T018 depends on them.
- T011 to T014 can run after existing engagement/settings context is understood.
- Verification tasks run last.

## Suggested MVP

Complete T001, T002, T004, T007, T008, T015, T016, and T018 first. This reduces privacy risk and gives production QA confidence before adding more engagement surfaces.

## Worker 039 status notes

- Completed without running Flutter tests/builds per instruction: T001, T002,
  T003, T004, T005, T007, T010, T011, T012, T013, T014.
- Deferred T006 heavy wiring because AI, ads, and premium surfaces overlap
  workers 037/038. The `FeatureFlagService` abstraction and local defaults are
  in place for a follow-up wiring pass.
- T008 and T009 were completed by Plan 040 with fake-provider Home navigation
  and Settings smoke tests.
- T015 and T016 were completed by parent verification after worker handoff.
- T017 and T018 remain blocked for manual/device verification. This worker was
  explicitly instructed not to run `flutter build` or device QA.
- `dart format` was attempted only on touched Dart files and timed out in this
  environment after 120 seconds; no analyzer/test/build verification was run.
