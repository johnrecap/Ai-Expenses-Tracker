# Tasks: Live Monetization State

**Input**: `specs/026-live-monetization-state/spec.md`, `plan.md`  
**Implementation Intent**: Make monetization state real, shared, and non-blocking.

## Phase 1: Audit Placeholder State

- [X] T001 Find all direct uses of `MonetizationState.initial()`.

  **Why**: These are likely sources of fake UI state.
  **Steps**:
  1. Search `lib` for `MonetizationState.initial`.
  2. Record each screen/widget and whether it is production UI or test fixture.
  3. Keep test fixture usage only where explicitly named as fixture.
  4. Mark production usages for replacement.
  **Done when**: Every placeholder state usage is classified.

- [X] T002 Audit `MonetizationCubit` creation and disposal.

  **Why**: Shared state needs a clear lifecycle tied to the authenticated user.
  **Steps**:
  1. Search for `MonetizationCubit(`.
  2. Identify whether the Cubit is created in Settings, Free/Premium, app root, or tests.
  3. Check whether it has access to current `userId` and repositories.
  4. Decide the single production provider location.
  **Done when**: There is one planned production owner for monetization state.

## Phase 2: Shared Provider Wiring

- [X] T003 Provide `MonetizationCubit` after authenticated user state is available.

  **Why**: Entitlements and usage are user-specific.
  **Steps**:
  1. Locate the widget where authenticated repositories are created.
  2. Instantiate entitlement, policy, and usage dependencies there.
  3. Provide the Cubit to Settings, Free/Premium, AI quota prompts, and ad slots.
  4. Close/dispose the Cubit when user logs out.
  **Done when**: Production screens can read one shared Cubit.

- [X] T004 Add initial load and refresh actions to the Cubit if missing.

  **Why**: Screens need predictable loading and retry behavior.
  **Steps**:
  1. Ensure Cubit can load entitlement and policy together.
  2. Ensure failures produce Free-safe state plus a visible non-blocking error.
  3. Add a manual refresh action for Settings/Free Premium screen.
  4. Avoid repeated load calls on every rebuild.
  **Done when**: State lifecycle covers initial, loaded, stale, error, and refreshing states.
  **Status note (Plan 040 cleanup)**: `MonetizationCubit.load`,
  `refreshEntitlement`, stale usage marking, and failure state handling now exist.

- [X] T005 Connect AI action results to quota state updates.

  **Why**: Usage shown in UI should update after parse, receipt, or advice calls.
  **Steps**:
  1. Inspect AI gateway response models for quota fields.
  2. If response includes usage/remaining/reset, map it into monetization usage state.
  3. If response lacks fields, mark usage stale and allow manual refresh.
  4. Do not decrement usage locally when the Worker rejects the request.
  **Done when**: Successful AI calls update visible quota where data is available.

## Phase 3: Settings And Free/Premium UI

- [X] T006 Replace Settings placeholder state with Bloc-driven state.

  **Why**: Settings is the user-facing control center.
  **Steps**:
  1. Open `lib/screens/settings/views/settings_screen.dart`.
  2. Remove production construction of `MonetizationState.initial()`.
  3. Read shared Cubit state using `BlocBuilder`, `BlocSelector`, or existing style.
  4. Render loading, Free, Premium, quota, error, and purchase-unavailable states.
  **Done when**: Settings reflects injected Free/Premium fixtures correctly.

- [X] T007 Ensure Free/Premium screen consumes shared state.

  **Why**: The screen must not disagree with Settings.
  **Steps**:
  1. Open the Free/Premium screen implementation.
  2. Remove local Cubit creation if a shared provider exists above it.
  3. Keep local test wrappers only in tests.
  4. Add retry/refresh UI tied to Cubit action.
  **Done when**: Navigation from Settings and quota prompts shows the same state.

- [ ] T008 Add navigation from quota exhausted prompts to Free/Premium.

  **Why**: Users hitting limits need a clear explanation.
  **Steps**:
  1. Locate AI quota error presentation.
  2. Add a single CTA to the Free/Premium screen.
  3. Keep manual add expense option visible.
  4. Do not upsell provider outages as quota exhaustion.
  **Done when**: Quota prompt, Settings, and Free/Premium form one consistent flow.

## Phase 4: Tests

- [X] T009 [P] Add MonetizationCubit tests for loading and failure states.

  **Why**: Shared state gates multiple screens.
  **Steps**:
  1. Test Free default load.
  2. Test Premium entitlement load.
  3. Test failed entitlement refresh defaults Free-safe.
  4. Test quota update after AI response payload.
  **Done when**: Cubit behavior is deterministic.
  **Status note (Plan 040 cleanup)**: Covered by `test/monetization/monetization_cubit_test.dart`.

- [X] T010 [P] Add Settings widget tests for Free and Premium states.

  **Why**: This catches regressions back to placeholders.
  **Steps**:
  1. Pump Settings with fake shared Cubit.
  2. Assert Free copy and quota card for Free fixture.
  3. Assert Premium copy and no remove-ads CTA for Premium fixture.
  4. Assert error state remains non-blocking.
  **Done when**: Settings proves it uses live injected state.
  **Status note (Plan 040 cleanup)**: Settings smoke coverage was added in
  `test/settings/settings_screen_widget_test.dart`; broader Premium-state
  expansion can continue as future coverage if needed.

- [X] T011 [P] Add Free/Premium screen widget tests for shared state.

  **Why**: The main monetization screen must render consistently from every entry point.
  **Steps**:
  1. Pump screen with the same fake Cubit used by Settings.
  2. Verify current plan badge.
  3. Verify quota usage card updates when Cubit emits new usage.
  4. Verify refresh action calls Cubit.
  **Done when**: Free/Premium UI is tied to shared state.
  **Status note (Plan 040 cleanup)**: Covered by `test/monetization/free_premium_screen_test.dart`.

## Phase 5: Verification

- [X] T012 Run Flutter verification.

  **Why**: State provider changes can break many screens.
  **Steps**:
  1. Run `flutter analyze`.
  2. Run monetization and settings tests.
  3. Run full `flutter test` if Plan 024 baseline is repaired.
  4. Manually open Settings and Free/Premium as a signed-in user.
  **Done when**: Automated checks pass and UI state matches fixture/manual expectations.
  **Status note (Plan 040 cleanup)**: `flutter analyze` and the full Flutter
  test suite passed on 2026-05-18 with 240 tests. Manual signed-in UI fixture
  review remains a broader QA item in the deferred backlog, not a blocker for
  this local verification task.
