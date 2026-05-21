# Tasks: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

**Input**: `specs/040-spec-cleanup-tests-backlog/spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`  
**Implementation Intent**: Clean planning noise, add targeted UI safety coverage, and keep deferred work accurate without starting production/device setup.

## Phase 1: Setup And Baseline Review

- [X] T001 Read `AGENTS.md`, `.specify/memory/constitution.md`, and `docs/implementation_plans/deferred-and-advanced-work.md`.

  **Why**: This plan depends on the project's persistent instructions and deferred backlog policy.
  **Steps**:
  1. Confirm `AGENTS.md` points to this plan.
  2. Confirm the deferred file exists.
  3. Note current external blockers: release keystore, Firebase deploy, device QA, AdMob production IDs, real Worker QA, Play Store.
  **Done when**: The worker can explain what is local/actionable versus external/deferred.

- [X] T002 Create a historical task audit list from unchecked tasks in `specs/*/tasks.md`.

  **Why**: Old unchecked tasks are currently mixed between real work, superseded work, and manual blockers.
  **Steps**:
  1. Run `rg -n "^- \\[ \\] T" specs -g tasks.md`.
  2. Group results by category: localization, ads/monetization, AI, Firebase, release/build, manual QA, tests, specs cleanup.
  3. Identify tasks likely superseded by plans 037, 038, and 039.
  4. Identify tasks still open locally.
  5. Identify tasks blocked by external setup.
  **Done when**: There is a clear working list for which task files need status updates.

## Phase 2: Historical Specs Cleanup

- [X] T003 Update superseded monetization/ad tasks in older `specs/*/tasks.md` files.

  **Why**: Plans 037 and 039 completed or superseded several old ad/monetization readiness tasks.
  **Steps**:
  1. Review open tasks in `specs/023-free-premium-ads/tasks.md`, `specs/026-live-monetization-state/tasks.md`, and `specs/027-production-ads-readiness/tasks.md`.
  2. For each task now completed by `037-monetization-purchases-ads`, mark complete only if code/tests/docs prove it.
  3. For device QA, consent QA, production AdMob IDs, Premium billing verification, and release artifacts, keep unchecked and add blocker notes pointing to the deferred backlog.
  4. Avoid deleting historical tasks.
  **Done when**: Old monetization specs no longer imply completed 037 work is still missing.

- [X] T004 Update superseded AI tasks in older `specs/*/tasks.md` files.

  **Why**: Plans 018, 028, and 038 overlap with earlier Gemini/AI setup tasks.
  **Steps**:
  1. Review open tasks in `specs/012.5-gemini-ai-provider/tasks.md`, `specs/018-cloudflare-ai-gateway/tasks.md`, `specs/028-ai-usage-quota-surface/tasks.md`, and `specs/038-ai-production-reliability/tasks.md`.
  2. Mark local verification tasks complete only if current passing tests/typecheck prove them.
  3. Keep real Android Worker QA and manual Gemini/provider QA unchecked with explicit blocker notes.
  4. Ensure any exposed-key rotation reminder remains deferred until the owner rotates keys.
  **Done when**: AI task status separates local gateway reliability from real-device/provider setup.

- [X] T005 Update localization/export/manual QA task status in older `specs/*/tasks.md` files.

  **Why**: The Arabic PDF font has been added, but broad localization and manual RTL/PDF visual QA remain open.
  **Steps**:
  1. Review open tasks in `specs/030-localization-rtl-polish/tasks.md`, `specs/036-localization-export-ux-polish/tasks.md`, and `specs/012-export-data/tasks.md`.
  2. Ensure the font asset task is not represented as missing anymore.
  3. Keep broad localization, manual RTL, and visual PDF QA unchecked with current blocker notes.
  4. Point deferred visual QA items to `docs/implementation_plans/deferred-and-advanced-work.md`.
  **Done when**: PDF font state and localization/RTL remaining work are accurately represented.

- [X] T006 Update `specs/README.md` with current plan status guidance.

  **Why**: Future workers need a quick way to know which specs are current versus historical.
  **Steps**:
  1. Add a short note that older unchecked tasks may be superseded and should be checked against `040` cleanup notes.
  2. Add references to active remaining local work: localization/RTL, Home navigation tests, Settings tests, feature flag wiring.
  3. Add references to external deferred work: release/device/Firebase/AdMob/Play Store.
  **Done when**: A worker can start from `specs/README.md` and avoid duplicate planning.

## Phase 3: Deferred Backlog Alignment

- [X] T007 Update `docs/implementation_plans/deferred-and-advanced-work.md` with spec cleanup as a near-term maintenance item.

  **Why**: The deferred file should remember that old specs require ongoing alignment after new plans land.
  **Steps**:
  1. Add or refine a concise Product/Operations item for historical Speckit status cleanup.
  2. Avoid duplicate wording if an equivalent item already exists.
  3. Keep this local/actionable, not mixed with external device QA.
  **Done when**: The file clearly reminds future workers to keep specs aligned.

- [X] T008 Update `docs/implementation_plans/deferred-and-advanced-work.md` with Home/Settings test priorities.

  **Why**: These are near-term local quality tasks and should not be buried among broad product ideas.
  **Steps**:
  1. Ensure Home navigation widget tests are listed as near-term local work.
  2. Ensure broader Settings widget smoke tests are listed as near-term local work.
  3. Mention that tests must use fakes and avoid real Firebase/platform plugins.
  **Done when**: The file clearly separates local test coverage from device QA.

- [X] T009 Update `docs/implementation_plans/deferred-and-advanced-work.md` for Arabic PDF status.

  **Why**: The font asset is now present, so the backlog should not imply missing font setup.
  **Steps**:
  1. Replace any wording that implies the Arabic font asset is missing.
  2. Keep visual/manual PDF QA for mixed Arabic/English rows as deferred.
  3. Note any remaining PDF warning cleanup if current tests still emit harmless Helvetica warnings.
  **Done when**: The PDF backlog reflects the latest state accurately.

## Phase 4: Home Navigation Test Coverage

- [X] T010 [P] Create or update shared Home test fakes in `test/helpers/`.

  **Why**: Home tests should not initialize real Firebase, AdMob, notifications, or platform services.
  **Steps**:
  1. Add fake repositories for expenses, categories, settings, budgets, monetization/ad services if missing.
  2. Add a small widget wrapper that provides the blocs/repositories Home requires.
  3. Reuse existing helpers where possible; do not duplicate large fake classes.
  4. Keep fake data deterministic.
  **Done when**: Home widget tests can pump the screen without real services.

- [X] T011 [P] Add Home `View All` navigation test in `test/home/home_navigation_test.dart`.

  **Why**: The transaction list entry to Expenses is a core repeat-use path.
  **Steps**:
  1. Pump Home/Main screen with at least one expense and required providers.
  2. Tap `View All`.
  3. Assert Expenses screen or an Expenses-specific widget/text appears.
  4. Ensure no real Firebase repository is created.
  **Done when**: The test fails if `View All` navigation is broken.

- [X] T012 [P] Add Home Settings navigation test in `test/home/home_navigation_test.dart`.

  **Why**: Settings is the entry point for currency, payment, notifications, security, AI usage, and monetization.
  **Steps**:
  1. Pump Home/Main screen with fake settings repository.
  2. Tap the settings icon.
  3. Assert Settings screen title or a stable Settings section appears.
  4. Verify required providers are passed or faked.
  **Done when**: The test fails if Settings navigation misses providers or crashes.

- [X] T013 [P] Add Home budget/manage navigation test in `test/home/home_navigation_test.dart`.

  **Why**: Budget actions are part of the dashboard value proposition.
  **Steps**:
  1. Pump Home with a BudgetBloc state that renders the budget card.
  2. Trigger the manage/open budget action.
  3. Assert Budget screen or stable budget UI appears.
  4. Keep mixed-currency and budget math outside the test unless needed for rendering.
  **Done when**: The test covers the budget route without real Firestore.

- [X] T014 Add Home logout confirmation coverage if the current Home/menu exposes logout.

  **Why**: Logout should remain confirmation-first.
  **Steps**:
  1. Locate the current logout entry point.
  2. Pump the relevant widget with fake AuthBloc/AuthRepository.
  3. Tap logout.
  4. Assert confirmation dialog appears before sign-out is dispatched.
  5. If Home no longer owns logout, document the correct screen and add the test there.
  **Done when**: Sensitive sign-out behavior has automated coverage or a precise alternate location note.

## Phase 5: Settings Widget Smoke Coverage

- [X] T015 [P] Create or update Settings test fakes in `test/helpers/` or `test/settings/`.

  **Why**: Settings tests need stable fake state for settings, monetization, security, AI, and notifications.
  **Steps**:
  1. Reuse existing fake settings repository/cubit helpers if present.
  2. Add missing fake monetization/ad dependencies.
  3. Stub plugin-dependent sections so tests do not call platform APIs.
  4. Keep fakes narrow and feature-specific.
  **Done when**: Settings widgets can be pumped with success and failure states.

- [X] T016 [P] Add Settings currency/payment smoke test in `test/settings/settings_screen_widget_test.dart`.

  **Why**: Currency and payment defaults affect every new expense and AI preview.
  **Steps**:
  1. Pump Settings with a valid `UserSettings` fixture.
  2. Assert currency and payment sections render.
  3. Interact with a visible control if stable enough.
  4. Assert fake SettingsCubit/repository receives the expected save call when interaction is possible.
  **Done when**: The test catches missing currency/payment sections or broken provider wiring.

- [X] T017 [P] Add Settings notification/security smoke test in `test/settings/settings_screen_widget_test.dart`.

  **Why**: Notification and app protection controls are plugin-adjacent and easy to break.
  **Steps**:
  1. Pump Settings with notification settings enabled and disabled cases if practical.
  2. Assert notification controls render without calling real notification plugin APIs.
  3. Assert security/app protection section renders a safe entry point.
  4. Do not test biometric/PIN platform behavior here.
  **Done when**: The test catches broken rendering without device dependencies.

- [X] T018 [P] Add Settings AI/monetization/privacy/support smoke test in `test/settings/settings_screen_widget_test.dart`.

  **Why**: These sections explain trust, quota, ads, privacy, and support.
  **Steps**:
  1. Pump Settings with fake MonetizationCubit state.
  2. Assert AI usage, monetization, privacy, and support sections render.
  3. Assert support messaging does not attach expense data automatically.
  4. Assert unavailable/purchase/AI states are honest when applicable.
  **Done when**: The test catches missing trust/monetization/support surfaces.

## Phase 6: Verification And Status Update

- [X] T019 Run `flutter analyze`.

  **Why**: Test helpers and widget wiring can introduce import or provider errors.
  **Steps**:
  1. Run analyzer from repo root.
  2. Fix issues caused by this plan.
  3. Record any unrelated pre-existing issue separately.
  **Done when**: Analyzer passes.

- [X] T020 Run targeted Home and Settings tests.

  **Why**: These are the primary local deliverables for this plan.
  **Steps**:
  1. Run `flutter test --reporter expanded --concurrency=1 --timeout 45s test/home test/settings`.
  2. Fix failures caused by this plan.
  3. If a plugin/platform issue blocks tests, replace real dependency with a fake or document exact blocker.
  **Done when**: Targeted tests pass.

- [X] T021 Run full Flutter test suite if shared UI/provider code changed.

  **Why**: Home and Settings touch shared blocs, repositories, monetization, localization, and engagement.
  **Steps**:
  1. Run full Flutter tests when code outside test/docs is changed.
  2. Fix plan-caused failures.
  3. Do not run Android release build unless the implementation changes Android packaging or assets.
  **Done when**: Full tests pass or a justified no-build/no-full-suite note is recorded.

- [X] T022 Update `specs/040-spec-cleanup-tests-backlog/tasks.md` and final notes.

  **Why**: The plan itself must remain a trustworthy handoff artifact.
  **Steps**:
  1. Mark completed tasks.
  2. Add blocker notes for device/build/Firebase/AdMob/Play Store work discovered during implementation.
  3. Add any new deferred item to `docs/implementation_plans/deferred-and-advanced-work.md`.
  **Done when**: A future worker can continue without rereading the whole chat.

## Dependencies & Execution Order

- T001 and T002 must be done first.
- T003 to T006 depend on the audit list from T002.
- T007 to T009 can run after T001 and should be kept in sync with T003 to T006.
- T010 blocks T011 to T014 if shared Home fakes are needed.
- T015 blocks T016 to T018 if shared Settings fakes are needed.
- T011 to T014 can run in parallel with T016 to T018 after fakes exist.
- T019 to T022 run last.

## Parallel Opportunities

- T003, T004, and T005 can be split by spec category after T002.
- T011, T012, and T013 can run in parallel if they use shared Home fakes from T010.
- T016, T017, and T018 can run in parallel if they use shared Settings fakes from T015.
- T007 to T009 are documentation-only and can run alongside test creation.

## Suggested MVP

Complete T001, T002, T007, T008, T009, T010, T011, T015, T016, T019, and T020 first. This updates the persistent backlog and adds the first meaningful Home/Settings regression coverage without touching release/device setup.

## Implementation Notes

- Historical task audit was run with `rg -n "^- \[ \] T" specs -g tasks.md`.
- Updated historical status notes in monetization/ad specs (`023`, `026`, `027`), AI specs (`012.5`, `038` context retained), category visuals (`020`), Home/settings live data (`021`), AI voice (`022`), Home navigation (`031`), observability/readiness (`039`), and localization/export backlog references.
- Added shared fake repository/platform helpers in `test/helpers/fake_repositories.dart`.
- Added `test/home/home_navigation_test.dart` covering Home View All, Settings shortcut, budget manage navigation, and logout confirmation.
- Added `test/settings/settings_screen_widget_test.dart` covering Settings currency/payment, notifications/security, AI/monetization/privacy/support rendering.
- Updated `docs/implementation_plans/deferred-and-advanced-work.md` so the Arabic PDF font is no longer treated as missing; visual PDF QA and harmless Helvetica warning cleanup remain deferred.
- Verification completed on 2026-05-18:
  - `flutter analyze` passed with no issues.
  - Targeted `flutter test --reporter expanded --concurrency=1 --timeout 45s test/home/home_navigation_test.dart test/settings/settings_screen_widget_test.dart` passed: 7 tests.
  - Full `flutter test --reporter expanded --concurrency=1 --timeout 45s` passed: 240 tests.
- No Android build was run because this plan changed docs/tests only and did not touch Android packaging, assets, release signing, Firebase config, or production ad IDs.
