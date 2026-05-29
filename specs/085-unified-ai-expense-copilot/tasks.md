# Tasks: Unified AI Expense Copilot

**Input**: Design documents from `specs/085-unified-ai-expense-copilot/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Audit

- [X] T001 Audit Home AI code in `lib/screens/ai_assistant/`. Why: identify behavior that already works well. Expected: list of reusable draft/save/category behavior. Risk: losing working Home AI behavior. Modification: record gaps before refactor.
- [X] T002 Audit Add Expense AI code in `lib/screens/add_expense/widgets/ai_expense_form_fill_card.dart` and `lib/screens/add_expense/views/add_expense.dart`. Why: current `+` flow is weaker and visually different. Expected: list of duplicated or missing capabilities. Risk: patching symptoms instead of unifying. Modification: map every field and action.
- [X] T003 Audit Worker parse payload in `workers/ai-gateway`. Why: full-form AI may need fields not currently returned. Expected: schema compatibility decision. Risk: Flutter expects fields Worker never sends. Modification: decide if schema update is needed.

## Phase 2: Foundational Draft Contract

- [X] T004 [P] Create/extend `AiExpenseDraft` in `lib/ai/models/`. Why: one draft model makes Home and Add Expense deterministic. Expected: fields for amount, currency, category, suggested category, date, payment, merchant, tags, description, confidence, missing fields. Risk: continuing two payload shapes. Modification: include serialization/test helpers.
- [X] T005 [P] Create `SuggestedCategoryDraft` in `lib/ai/models/`. Why: AI category creation needs reviewable metadata. Expected: name, icon key, color, alias/evidence, confidence. Risk: category created without user context. Modification: keep it non-persisted.
- [ ] T006 Add parser tests in `test/ai/ai_expense_draft_parser_test.dart`. Why: parser must accept useful partial drafts. Expected: Arabic/English complete, partial, ambiguous, and new-category fixtures. Risk: AI still rejects valid user input. Modification: test missing fields are empty, not fatal.
- [X] T007 Update Worker schema in `workers/ai-gateway/src/` if T003 finds gaps. Why: Flutter cannot invent missing structured fields. Expected: provider prompt/schema returns the full draft. Risk: deployed AI still acts like a simple form filler. Modification: keep backward compatibility for old fields.

## Phase 3: User Story 1 - One AI Experience Everywhere (P1)

**Independent Test**: Same text from Home and Add Expense produces identical draft data.

- [ ] T008 [P] Build shared `AiExpenseCaptureController` in `lib/screens/add_expense/` or `lib/ai/`. Why: parse/apply/save state should not live in two widgets. Expected: text/voice/receipt draft state, loading, error, quota, settings readiness. Risk: duplicate logic returns. Modification: no direct repository writes.
- [X] T009 [P] Build shared `AiExpenseCapturePanel` in `lib/screens/add_expense/widgets/`. Why: the UI should be one widget reused in both locations. Expected: same visual layout, RTL, loading, retry, missing-fields, and draft status. Risk: user sees two AI products. Modification: expose callbacks for apply/save.
- [X] T010 Replace Add Expense AI card with shared panel in `lib/screens/add_expense/views/add_expense.dart`. Why: `+` flow must match Home AI behavior. Expected: same parser and draft application. Risk: current weak card remains. Modification: keep manual fields below.
- [X] T011 Replace Home AI draft rendering with shared controller/panel where practical in `lib/screens/ai_assistant/`. Why: Home AI must not diverge after future fixes. Expected: same draft, same missing fields, same category suggestion. Risk: Home remains a separate code path. Modification: preserve Home sheet presentation.

## Phase 4: User Story 2 - Full Expense Draft Control (P1)

**Independent Test**: Arabic and English prompts fill every known field and leave unknowns blank.

- [X] T012 Update field application logic in `lib/screens/add_expense/views/add_expense.dart`. Why: AI must control all editable fields, not just amount/category. Expected: amount, currency, date, payment, merchant, tags, description, category/suggested category applied. Risk: draft looks incomplete despite AI knowing data. Modification: one `_applyDraftToForm` method.
- [ ] T013 Add settings guard tests in `test/add_expense/ai_capture_settings_guard_test.dart`. Why: AI must not guess defaults when settings fail. Expected: retry/settings-required state. Risk: wrong currency/payment saved. Modification: block save until explicit choices exist.
- [ ] T014 Add localized missing-field copy in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. Why: users need to know what to review. Expected: concise Arabic/English messages. Risk: hardcoded English in Arabic flow. Modification: run `flutter gen-l10n`.
- [ ] T015 Add prompt fixture tests for Arabic colloquial inputs in `test/ai/`. Why: target users will use Egyptian Arabic. Expected: useful drafts for common phrases. Risk: AI feels worse than manual entry. Modification: include food, transport, subscription, cash/card examples.

## Phase 5: User Story 3 - Safe Category Creation During Save (P1)

**Independent Test**: Suggested category is created first, then the expense saves with that category.

- [X] T016 Implement category resolution service call in `lib/ai/` using existing `AiCategoryResolver`. Why: avoid duplicate categories. Expected: existing category/alias matched before creation. Risk: category spam. Modification: no widget-level matching.
- [X] T017 Wire suggested category confirmation in Add Expense save flow. Why: category must be created only after user confirms. Expected: create category, update draft category id, then save expense. Risk: expense saved with empty category. Modification: handle failure atomically from user perspective.
- [X] T018 Wire same category confirmation in Home AI save flow. Why: both AI entry points must have same permissions. Expected: Home AI can create reviewed categories too. Risk: Home has more power than Add Expense or vice versa. Modification: reuse T017 orchestration.
- [ ] T019 Add tests in `test/ai/ai_suggested_category_save_test.dart`. Why: write order is critical. Expected: category create called once, expense create called after, failures stop expense save. Risk: hidden data inconsistency. Modification: fake repositories/blocs.

## Phase 6: Receipt And Voice Parity

- [X] T020 Audit receipt and voice input integration points. Why: shared AI panel should support future input modes without more forks. Expected: extension hooks identified. Risk: voice/receipt remain separate mini-products. Modification: add controller methods or TODOs where needed.
- [ ] T021 Reuse shared draft application for receipt extraction in `lib/screens/add_expense/views/add_expense.dart`. Why: receipt output should fill the same fields. Expected: receipt and text drafts behave consistently. Risk: receipt keeps old field gaps. Modification: map receipt payload to `AiExpenseDraft`.

## Phase 7: Verification

- [X] T022 Run `flutter gen-l10n`. Why: new copy must generate. Expected: generated files updated. Risk: build fails or stale UI strings. Modification: commit generated changes.
- [ ] T023 Run targeted Flutter AI/Add Expense/Home tests. Why: this refactor crosses critical save paths. Expected: parser, widget, category save tests pass. Risk: AI creates bad expenses. Modification: fix before build.
- [X] T024 Run Worker typecheck/tests if schema changed. Why: Flutter and gateway contracts must match. Expected: Worker stays deployable. Risk: deployed AI returns invalid payload. Modification: update contracts/prompt.

Verification notes:
- Parent updated Worker structured-output tests to match the current product
  decision: unclear date/payment/currency use the safe defaults
  today/Cash/default currency, while amount/category remain review-required.
- Parent ran `workers/ai-gateway` typecheck and all Worker tests successfully.
- Parent ran `flutter gen-l10n` successfully.
- Targeted Flutter AI/Add Expense/Home tests remain open because the local
  Flutter/Git toolchain hung during the sync coordinator test run.

## Dependencies

- T004-T007 block shared UI work.
- T008-T009 block T010-T011.
- T016 blocks T017-T019.

## MVP Scope

Complete T001-T019 first. Receipt/voice parity can follow once text AI and category creation are unified.
