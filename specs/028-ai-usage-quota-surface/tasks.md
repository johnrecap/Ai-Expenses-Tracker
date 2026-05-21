# Tasks: AI Usage Quota Surface

**Input**: `specs/028-ai-usage-quota-surface/spec.md`, `plan.md`  
**Implementation Intent**: Make AI daily usage visible and make AI failures safe and understandable.

## Phase 1: Audit Current Worker And Flutter Response Shape

- [X] T001 Inspect Worker AI response payloads.

  **Why**: UI should use trusted quota data, not guessed local counters.
  **Steps**:
  1. Read `workers/ai-gateway` handlers for parse, receipt, and advice.
  2. Identify response fields for usage, limit, remaining, reset time, and error code.
  3. Identify whether each endpoint uses a distinct quota key.
  4. Record missing fields that Flutter needs.
  **Done when**: Worker quota response contract is known.

- [X] T002 Inspect Flutter AI gateway client and response models.

  **Why**: Worker data must be mapped into typed app models.
  **Steps**:
  1. Read AI gateway client/service files under `lib/ai`.
  2. Locate exception/error classes for provider, quota, and parse failures.
  3. Locate `AiAssistantCubit` error handling.
  4. Identify where monetization usage can be updated.
  **Done when**: Flutter mapping and UI update points are known.

## Phase 2: Normalize Usage And Errors

- [X] T003 Add or extend `AiUsageSnapshot` model.

  **Why**: Settings, Free/Premium, and AI Assistant need the same usage data shape.
  **Steps**:
  1. Include action type, used, limit, remaining, resetAt, source, and stale flag.
  2. Support unknown values without crashing UI.
  3. Add value helpers for exhausted/low/available states.
  4. Keep model independent of UI widgets.
  **Done when**: All three AI action types can be represented.

- [X] T004 Add normalized `AiQuotaError` or extend existing gateway exception.

  **Why**: UI needs to distinguish quota from provider failure and unclear input.
  **Steps**:
  1. Define error categories: unclear input, missing fields, quota exhausted, provider unavailable, network, unauthorized, unsupported, unknown.
  2. Map Worker error codes into these categories.
  3. Include optional reset time and action type.
  4. Keep raw provider details out of user-facing messages.
  **Done when**: AI errors are typed enough for separate UI states.

- [X] T005 Update Worker response contract if usage fields are missing.

  **Why**: Flutter cannot show real remaining usage without backend data.
  **Steps**:
  1. Add usage metadata to successful responses if absent.
  2. Add usage metadata to quota-exhausted errors if possible.
  3. Keep schema stable across parse, receipt, and advice.
  4. Update Worker tests for limits 5/3/3.
  **Done when**: Worker responses provide quota data or explicitly document unknown state.

## Phase 3: UI Surfaces

- [X] T006 Update AI Assistant error presentation.

  **Why**: Users need to know what to do next.
  **Steps**:
  1. For unclear input/missing fields, ask user to add missing details.
  2. For quota exhausted, show daily limit reached and reset time if known.
  3. For provider/network outage, show AI temporarily unavailable.
  4. Always keep manual add expense available.
  5. Link quota exhaustion to Free/Premium only, not provider outage.
  **Done when**: Each error type has distinct copy/actions.

- [X] T007 Connect AI usage to `MonetizationCubit` or shared usage state.

  **Why**: Settings and Free/Premium must reflect latest AI activity.
  **Steps**:
  1. On successful AI call, pass usage snapshot to monetization state.
  2. On quota error, pass usage/error metadata without decrementing locally.
  3. Mark usage stale if Worker unavailable.
  4. Add refresh action only when it does not create excessive provider calls.
  **Done when**: Usage card updates after AI actions.

- [X] T008 Replace placeholder AI settings section with live usage.

  **Why**: `ai_settings_section.dart` should be useful, not static.
  **Steps**:
  1. Render text parse remaining/limit.
  2. Render receipt remaining/limit.
  3. Render advice remaining/limit.
  4. Show reset timing when known.
  5. Show stale/offline label when usage is cached.
  **Done when**: Settings gives an accurate AI usage overview.

- [X] T009 Update Free/Premium quota usage card.

  **Why**: Plan screen is the main explanation surface for Free limits.
  **Steps**:
  1. Use the same usage snapshot as Settings.
  2. Show default Free limits when usage is unknown.
  3. Mark unknown/stale clearly.
  4. Keep Premium copy honest; do not claim unlimited provider usage unless policy says so.
  **Done when**: Free/Premium and Settings match.

## Phase 4: Fallback Features

- [ ] T010 Verify manual add expense works when AI fails.

  **Why**: AI is optional convenience, not the core expense path.
  **Steps**:
  1. Force AI gateway failure.
  2. Open Add Expense manually.
  3. Create an expense using existing Bloc/repository flow.
  4. Confirm no AI error blocks the form.
  **Done when**: Manual tracking works with AI unavailable.

- [X] T011 Verify local summaries, repeated expense detection, and prediction do not call AI.

  **Why**: These features must stay usable under quota exhaustion.
  **Steps**:
  1. Inspect repeated expense and prediction services.
  2. Confirm they use local expense data only.
  3. Add tests if the boundary is not already covered.
  4. Document the boundary in the implementation report.
  **Done when**: Local insights are not dependent on provider quota.

## Phase 5: Tests And Verification

- [X] T012 [P] Add model tests for `AiUsageSnapshot`.

  **Why**: Usage math must not break UI.
  **Steps**:
  1. Test available, low, exhausted, stale, and unknown states.
  2. Test reset time formatting input boundaries.
  3. Test action type labels if model owns them.
  **Done when**: Usage model is deterministic.

- [X] T013 [P] Add gateway client tests for quota and provider errors.

  **Why**: Error mapping is the core of the feature.
  **Steps**:
  1. Simulate quota exhausted response.
  2. Simulate provider unavailable response.
  3. Simulate unclear/missing-field parser response.
  4. Assert normalized error type and metadata.
  **Done when**: UI can rely on typed errors.

- [X] T014 [P] Add AI Assistant widget/Cubit tests for error messages.

  **Why**: Users see this surface first.
  **Steps**:
  1. Test quota exhausted copy and Free/Premium CTA.
  2. Test provider outage copy without upsell.
  3. Test unclear input asks for clarification.
  4. Test manual add remains available.
  **Done when**: Error UX is covered.

- [ ] T015 Run verification.

  **Why**: AI and monetization state are shared across screens.
  **Steps**:
  1. Run Worker tests if Worker response changed.
  2. Run `flutter analyze`.
  3. Run AI and monetization tests.
  4. Manually exercise quota exhausted and provider unavailable fixtures.
  **Done when**: Both backend and Flutter surfaces agree.

  **Parent review status**: Automated verification passed (`workers/ai-gateway` `npm test`, `npm run typecheck`, `flutter analyze`, and full `flutter test` with 186 tests). Manual quota-exhausted/provider-unavailable fixture exercise remains open.
