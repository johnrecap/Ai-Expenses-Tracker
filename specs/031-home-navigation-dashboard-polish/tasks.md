# Tasks: Home Navigation And Dashboard Polish

**Input**: `specs/031-home-navigation-dashboard-polish/spec.md`, `plan.md`  
**Implementation Intent**: Fix Home no-op actions and keep dashboard values real and clear.

## Phase 1: Audit Home Actions And Data

- [X] T001 Map all visible actions in `lib/screens/home/views/main_screen.dart`.

  **Why**: Every icon must be accountable.
  **Steps**:
  1. List each icon/button in the Home header/action area.
  2. Record current `onPressed` or gesture behavior.
  3. Mark action as working, no-op, duplicate, dangerous, or unclear.
  4. Identify target route/screen for each action.
  **Done when**: Home action inventory is complete.

- [X] T002 Audit Home dashboard data sources.

  **Why**: User reported total balance-like card may not reflect real data.
  **Steps**:
  1. Inspect how Home receives expenses, budget, settings, and currency.
  2. Confirm values come from `HomeSummaryCalculator` or prepared state.
  3. Search Home for hardcoded amounts, names, or sample values.
  4. Record any fake or stale calculations.
  **Done when**: Every displayed finance value has a real source or a fix task.

## Phase 2: Fix Broken Or Unclear Actions

- [X] T003 Implement Settings icon navigation.

  **Why**: The current visible Settings icon must not be a no-op.
  **Steps**:
  1. Locate the Settings icon around the Home header.
  2. Wire it to existing Settings screen using current navigation style.
  3. Pass required repositories/Cubits through existing providers.
  4. Verify back navigation returns to Home.
  **Done when**: Tapping Settings opens the real Settings screen.

- [X] T004 Remove or implement any remaining no-op Home actions.

  **Why**: Dead buttons reduce user trust.
  **Steps**:
  1. For each no-op from T001, decide implement target or remove.
  2. Prefer implementing if the target screen already exists.
  3. Remove only if the action has no current feature behind it.
  4. Keep spacing balanced after removal.
  **Done when**: No visible Home action is inert.

- [X] T005 Add tooltips and semantic labels to icon-only actions.

  **Why**: Icons alone are not always obvious, especially for newer features.
  **Steps**:
  1. Add tooltip text for AI, reports, categories, settings, export, logout, and other icon-only actions.
  2. Add semantic labels where tooltips are insufficient.
  3. Use localization keys if Plan 030 is implemented first.
  4. Keep labels short.
  **Done when**: Screen reader/tooltip users can identify each action.

- [X] T006 Improve action layout on small screens.

  **Why**: Crowded icons can overlap or look unprofessional.
  **Steps**:
  1. Test Home width around common small Android devices.
  2. Keep primary actions visible.
  3. Move secondary actions into an overflow/menu if necessary.
  4. Ensure no control overlaps welcome text or dashboard card.
  **Done when**: Home action row is clean on small widths.

## Phase 3: Dashboard Data Correctness

- [X] T007 Fix any hardcoded or fake Home finance values.

  **Why**: Dashboard trust depends on real totals.
  **Steps**:
  1. Replace fake values with `HomeSummary` fields or clear empty/setup states.
  2. For no budget, show setup prompt rather than fake balance.
  3. For mixed currency, keep warning and avoid invalid totals.
  4. Keep user display name from auth/settings, not hardcoded "John Doe" unless it is the real profile fallback.
  **Done when**: Home shows only real or explicitly empty/setup state.

- [X] T008 Add/extend Home summary tests.

  **Why**: Calculator-backed dashboard values need regression coverage.
  **Steps**:
  1. Test no expenses.
  2. Test expenses within current month.
  3. Test budget remaining/exceeded.
  4. Test mixed currency warning.
  5. Test no budget state.
  **Done when**: Home summary math matches expected fixtures.

- [X] T009 Add Home widget/navigation tests.

  **Why**: No-op controls should not reappear.
  **Steps**:
  1. Pump Home with fake data/providers.
  2. Tap Settings icon and assert Settings route/screen appears.
  3. Verify tooltips exist for icon actions.
  4. Verify no fake sample amount appears in ready state.
  **Done when**: Home navigation and visible data are covered.

  **Parent review status**: The first widget test implementation caused `flutter test test\home\main_screen_test.dart` to hang until the command timeout. It was removed to keep verification unblocked. Home calculator coverage remained until Plan 040 added a safer fake-provider fixture.
  **Plan 040 completion**: Added `test/home/home_navigation_test.dart` covering View All, Settings, budget manage, and logout confirmation without real Firebase/plugin dependencies.

## Phase 4: Verification

- [ ] T010 Run Flutter verification and manual Home QA.

  **Why**: Home is central and layout-sensitive.
  **Steps**:
  1. Run `flutter analyze`.
  2. Run Home summary and widget tests.
  3. Manually test Home on a real/simulated small phone.
  4. Confirm Settings navigation, back navigation, and dashboard values.
  **Done when**: Home actions work and dashboard data is correct.

  **Parent review status**: Automated checks passed after parent fixes (`flutter analyze`, full `flutter test` with 214 tests, and release APK build). Plan 040 later passed `flutter analyze` and full Flutter tests with 240 tests. Manual small-phone Home QA remains open.
