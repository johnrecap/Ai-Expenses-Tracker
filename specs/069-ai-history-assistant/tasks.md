# Tasks: AI History Assistant

**Input**: `specs/069-ai-history-assistant/spec.md`, `plan.md`

## Phase 1: Intent And Ground Truth

- [X] T001 Define `HistoryQuestionIntent` and `HistoryAnswer` in `lib/ai/models/`.
  - **Why**: History questions need their own read-only contract.
  - **Benefit**: Separates insights from mutation commands.
  - **Expected**: Models include intent, filters, result, confidence, source, and navigation target.

- [X] T002 Add fixture expenses for common Arabic/English history questions in `test/ai/`.
  - **Why**: Natural-language behavior needs stable expected answers.
  - **Benefit**: Prevents regressions in parser/resolver logic.
  - **Expected**: Fixtures cover totals, thresholds, categories, period comparisons, and no-data cases.

## Phase 2: Deterministic Resolver

- [X] T003 Implement `AiHistoryQueryResolver` under `lib/ai/services/`.
  - **Why**: Local calculations must be ground truth.
  - **Benefit**: Answers remain useful when provider is down.
  - **Expected**: Resolver maps questions to `ExpenseFilter` or report calculations.

- [X] T004 Add tests for 12 common Arabic/English questions.
  - **Why**: The assistant must understand real user phrasing.
  - **Benefit**: Validates product value before gateway wording.
  - **Expected**: Each question returns deterministic expected result.

- [X] T005 Add mutation-refusal tests.
  - **Why**: First history assistant release is read-only.
  - **Benefit**: Protects user data.
  - **Expected**: Delete/update/create requests do not mutate and use existing confirm-first routing only when appropriate.

## Phase 3: Cubit And UI

- [X] T006 [US1] Add history question state/actions to `AiAssistantCubit`.
  - **Why**: AI Assistant is the existing interaction surface.
  - **Benefit**: Reuses current auth/quota/error handling.
  - **Expected**: User can submit a history question and receive a read-only answer.

- [X] T007 [US1] Render `HistoryAnswer` in `AiAssistantSheet`.
  - **Why**: Users need clear answer plus evidence.
  - **Benefit**: Shows totals, filters, matching expenses, and navigation.
  - **Expected**: UI displays deterministic source data, not just prose.

- [X] T008 [US2] Add comparison answer cards for current vs previous period.
  - **Why**: "Why did I spend more?" needs drivers.
  - **Benefit**: Turns reports into understandable insight.
  - **Expected**: Shows top changed category and amount difference.

## Phase 4: Optional Gateway Wording

- [ ] T009 Add optional gateway prompt path for rephrasing deterministic history answers.
  - **Why**: AI wording can make answers friendlier.
  - **Benefit**: Improves UX without risking math correctness.
  - **Expected**: Provider receives sanitized aggregate facts, not raw sensitive descriptions unless explicitly allowed by existing policy.

- [X] T010 Add provider failure fallback to local wording.
  - **Why**: AI provider can fail or quota can be exhausted.
  - **Benefit**: Feature remains useful offline/provider-down.
  - **Expected**: Local answer still appears.

## Phase 5: Localization And Verification

- [X] T011 Add ARB keys for answer labels, no-data states, unsupported mutation copy, and navigation actions.
  - **Why**: The assistant must work in Arabic and English.
  - **Benefit**: Keeps UI professional for Arabic users.
  - **Expected**: Matching keys in `app_en.arb` and `app_ar.arb`.

- [X] T012 Run `flutter gen-l10n`.
  - **Why**: New keys need generated getters.
  - **Benefit**: Catches localization errors.
  - **Expected**: Generation succeeds.

- [X] T013 Run targeted AI, reports, and expenses tests.
  - **Why**: Feature crosses AI parsing and financial calculations.
  - **Benefit**: Confirms answers match deterministic data.
  - **Expected**: Targeted tests pass.

- [X] T014 Run `flutter analyze --no-pub`.
  - **Why**: New models/cubit states can leave stale references.
  - **Benefit**: Static safety.
  - **Expected**: No analyzer issues.
