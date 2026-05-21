# Tasks: AI Commands Over Existing Data

## Implementation Intent

Extend the assistant beyond add-preview. Search, summaries, and advice can execute read-only. Update and delete are dangerous and must require exact target preview and explicit confirmation.

---

## Phase 1: Models And Logs

### T001 - Add New AI Intents

**Files:** Modify `lib/ai/models/ai_intent.dart`.

**Steps:** Add `searchExpenses`, `summarizeExpenses`, `financialAdvice`, `updateExpense`, `deleteExpense`; update JSON mapping; unknown values map to `unknown`.

**Done When:** Parser recognizes all phase 2 commands.

### T002 - Create Search Payload

**Files:** Create `lib/ai/models/ai_search_payload.dart`.

**Steps:** Include query, date range, category names/ids, amount range, payment methods, currency.

**Done When:** AI search can map to `ExpenseFilter`.

### T003 - Create Summary Payload

**Files:** Create `lib/ai/models/ai_summary_payload.dart`.

**Steps:** Include requested period: this week, this month, custom dates.

**Done When:** AI summary request can call report calculator.

### T004 - Create Advice Payload

**Files:** Create `lib/ai/models/ai_advice_payload.dart`.

**Steps:** Include period, focus category optional, and requested tone if supplied.

**Done When:** Advice service has structured input.

### T005 - Create Target Match Model

**Files:** Create `lib/ai/models/ai_target_match.dart`.

**Steps:** Include candidate expense, score, matched fields, reason text.

**Done When:** UI can explain why an expense was matched.

### T006 - Create AI Action Log Repository

**Files:** Create `packages/expense_repository/lib/src/models/ai_action_log.dart`, entity, repo, Firebase repo.

**Steps:** Store userId, rawInput, parsedResponse, intent, confidence, status, createdAt, confirmedAt optional.

**Done When:** Every command can be audited.

---

## Phase 2: Read-Only Commands

### T007 - Map AI Search To Filter

**Files:** Create or modify `lib/ai/services/ai_action_mapper.dart`.

**Steps:** Convert search payload to `ExpenseFilter`; normalize Arabic dates and payment labels.

**Done When:** Search command can reuse existing filter UI.

### T008 - Open Expenses With AI Filters

**Files:** Modify assistant UI and expenses route.

**Steps:** When search command succeeds, navigate/open Expenses screen with pre-applied filter and show filter summary.

**Done When:** `وريني مصاريف الأكل الشهر ده` opens relevant filtered list.

### T009 - Use Report Calculator For Summaries

**Files:** Modify `AiAssistantCubit`; use `ReportCalculator`.

**Steps:** Calculate totals from real expenses; format summary in assistant UI.

**Done When:** Summary numbers match Reports screen.

### T010 - Generate Advice From Aggregates

**Files:** Create `lib/ai/services/ai_advice_service.dart`.

**Steps:** Identify highest category, budget status, trend; produce short advice from actual numbers; remote AI may rephrase only after numbers are fixed.

**Done When:** Advice cannot invent spending totals.

---

## Phase 3: Update/Delete Commands

### T011 - Create `AiActionMatcher`

**Files:** Create `lib/ai/services/ai_action_matcher.dart`.

**Steps:** Score expenses by description, category, amount, date, and recency; return sorted matches.

**Done When:** Matching is deterministic and testable.

### T012 - One Strong Match Preview

**Steps:** If top score is above threshold and second score is sufficiently lower, show one target preview.

**Done When:** User sees exact expense before update/delete.

### T013 - Multiple Candidate Selection

**Steps:** If ambiguous, show candidate list with amount/date/category/description and require user to pick one.

**Done When:** Ambiguous commands do not mutate data.

### T014 - Confirm Update

**Steps:** Show before/after preview; require Confirm; then call `updateExpense`.

**Done When:** Update only runs after confirmation.

### T015 - Confirm Delete

**Steps:** Show delete warning with target details; require Confirm; then call `deleteExpense`.

**Done When:** Delete never runs from parser output alone.

### T016 - Log Final Status

**Steps:** Log previewed, confirmed, canceled, failed states to `ai_actions`.

**Done When:** Action history records user decision.

---

## Phase 4: Tests

### T017 - Target Matcher Tests

Test no match, one match, close ambiguous matches, last expense command, amount/category matching.

### T018 - Cubit Command Tests

Search, summary, advice, update preview, delete preview, cancel, confirm.

### T019 - Manual QA

Run Arabic commands for search, summary, update Uber amount, delete last expense.

---

## Worker B Completion Checklist

- [x] T001 - Added compatible `AiIntent` values and JSON parsing in `lib/ai/models/ai_intent.dart`.
- [x] T002 - Added `AiSearchPayload` with query, dates, categories, amounts, payment methods, and currency.
- [x] T003 - Added `AiSummaryPayload` with weekly, monthly, and custom report range conversion.
- [x] T004 - Added `AiAdvicePayload` with period, currency, optional focus category, and tone.
- [x] T005 - Added `AiTargetMatch` and `AiTargetMatchResult` for explainable preview/candidate UI.
- [x] T006 - Added `AiActionLog`, entity, abstract repository, Firebase repository, exports, and user-scoped `users/{userId}/ai_actions` path.
- [x] T007 - Added `AiActionMapper` to convert AI search payloads into `ExpenseFilter`, including Arabic period and payment-method normalization.
- [x] T008 - Integrated search command handling in `AiAssistantCubit` and `AiAssistantSheet`; AI search now maps to `ExpenseFilter` and can open `ExpensesScreen` with the pre-applied filter.
- [x] T009 - Integrated summary command handling in `AiAssistantCubit`; summaries now use `ReportCalculator.calculate` against the current in-memory expenses and render totals/top category in the assistant UI.
- [x] T010 - Added `AiAdviceService` that generates advice from `ReportCalculator` and optional `BudgetCalculator` evidence only.
- [x] T011 - Added deterministic `AiActionMatcher` scoring by text, amount, category, date, payment method, and recency.
- [x] T012 - Added strong-match resolution when the top candidate clears score and ambiguity thresholds.
- [x] T013 - Added multiple-candidate resolution when matching is ambiguous.
- [x] T014 - Added confirm-update flow in `AiAssistantCubit` and `AiAssistantSheet`; update commands show target/before-after preview and call `ExpenseRepository.updateExpense` only after explicit confirmation.
- [x] T015 - Added confirm-delete flow in `AiAssistantCubit` and `AiAssistantSheet`; delete commands show target warning and call `ExpenseRepository.deleteExpense` only after explicit confirmation.
- [x] T016 - Added log statuses for `previewed`, `confirmed`, `canceled`, and `failed`, plus repository status update API.
- [x] T017 - Added target matcher tests under `test/ai/ai_action_matcher_test.dart`.
- [x] T018 - Added `AiAssistantCubit` command tests for search, summary, advice, update preview/confirm, delete preview/confirm, and action-log confirmation status.
- [ ] T019 - Manual Arabic QA is still pending on a real Flutter runtime/Firebase session. Coordinator verification completed with `flutter pub get`, `flutter analyze`, and `flutter test --reporter expanded`.
