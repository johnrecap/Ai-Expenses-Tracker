# Tasks: Flexible AI Expense Drafts

**Input**: Design documents from `specs/056-ai-flexible-expense-drafts/`

## Phase 1: Setup

- [X] T001 Inspect current AI preview rendering and validation behavior.
- [X] T002 Inspect parser/cubit/mock/Worker missing-field behavior.

## Phase 2: Core Behavior

- [X] T003 Update `AiResponseParser` to accept missing amount/category in add-expense payloads.
- [X] T004 Update `AiAssistantCubit` to show editable draft previews instead of blocking clarification for missing amount/category.
- [X] T005 Add unknown non-empty response fallback to an editable add-expense draft.
- [X] T006 Update `AiActionPreviewCard` amount field to show blank when amount is missing/invalid.
- [X] T007 Update Worker normalization to avoid clarification questions for missing draft fields.

## Phase 3: Tests

- [X] T008 Add Flutter tests for missing amount draft, missing category draft, and vague text draft.
- [X] T009 Add/adjust parser tests for incomplete add-expense payloads.
- [X] T010 Add Worker test verifying missing draft fields do not produce clarification questions.

## Phase 4: Verification

- [X] T011 Run Flutter AI tests.
- [X] T012 Run Worker `npm test`.
- [X] T013 Run Worker `npm run typecheck`.
- [X] T014 Run `flutter analyze --no-pub`.

## Notes

- Do not auto-save expenses.
- Keep validation errors visible and confirmation disabled until manual completion.
