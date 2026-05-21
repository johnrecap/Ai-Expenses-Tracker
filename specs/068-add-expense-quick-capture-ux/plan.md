# Implementation Plan: Add Expense Quick Capture UX

**Branch**: `068-add-expense-quick-capture-ux` | **Date**: 2026-05-20 | **Spec**: `specs/068-add-expense-quick-capture-ux/spec.md`

## Summary

Redesign the Add Expense entry experience around three clear capture modes: quick manual, natural language AI draft, and receipt scan. Preserve the existing safety rule: every AI/receipt result becomes an editable draft and the normal save path commits the expense.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing Add Expense blocs, `AiAssistantCubit`, receipt AI services, settings defaults  
**Storage**: Existing expense repository only  
**Testing**: Widget tests for Add Expense modes, AI draft tests, keyboard layout manual QA  
**Target Platform**: Android mobile  
**Project Type**: Mobile UX flow  
**Performance Goals**: Returning user quick expense under 10 seconds  
**Constraints**: No direct AI mutations; no silent settings fallback after settings load failure  
**Scale/Scope**: One expense draft at a time

## Constitution Check

- AI writes only through preview/manual save: PASS.
- Add Expense defaults come from settings: PASS.
- Manual tracking works when AI fails: PASS.
- Localization required for new UI copy: PASS.

## Project Structure

```text
lib/screens/add_expense/views/add_expense.dart
lib/screens/add_expense/utils/expense_form_defaults.dart
lib/screens/add_expense/blocs/create_expense_bloc/
lib/ai/
lib/screens/ai_assistant/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
test/add_expense/
test/ai/
```

## Implementation Strategy

1. Extract current form state into a clear `ExpenseDraft`/mode model if needed.
2. Add segmented capture mode UI.
3. Make quick manual path minimal and default-first.
4. Move natural language AI and receipt outputs into the same draft fill path.
5. Add tests and small-screen keyboard QA.

## Risks

- UI can become more complex if all modes are visible at once. Mitigation: show one active mode and keep manual fields predictable.
- Settings load failures can confuse AI defaults. Mitigation: keep explicit retry/choice behavior.

## Deferred Items Considered

Related deferred items: keyboard-open Arabic QA, AI gateway device QA, and keeping manual tracking free and usable when AI fails.

