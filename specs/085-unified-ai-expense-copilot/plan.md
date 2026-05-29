# Implementation Plan: Unified AI Expense Copilot

**Branch**: `085-unified-ai-expense-copilot` | **Date**: 2026-05-27 | **Spec**: `specs/085-unified-ai-expense-copilot/spec.md`  
**Input**: Feature specification from `specs/085-unified-ai-expense-copilot/spec.md`

## Summary

Replace the split Home AI and Add Expense AI behavior with one shared AI expense copilot. The shared component will parse natural-language, voice, or receipt input into a full editable draft, including optional suggested category creation. Save remains user-confirmed and flows through existing category and expense repositories.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44; Cloudflare Worker TypeScript where schema changes are required  
**Primary Dependencies**: Existing `AiGatewayClient`, `AiResponseParser`, `AiAssistantCubit`, `AiCategoryResolver`, `CreateExpenseBloc`, `CreateCategoryBloc`, `SettingsRepository`  
**Storage**: Existing expense/category repositories; AI action logs; no new provider-secret storage  
**Testing**: AI parser/service tests, widget tests for both entry points, category creation integration tests  
**Target Platform**: Flutter Android-first UI with Arabic/English support  
**Project Type**: Mobile finance app with AI gateway  
**Performance Goals**: Draft appears within one provider response; no extra provider call during save  
**Constraints**: AI cannot write categories or expenses directly; no hardcoded fallback currency/payment after settings failure; manual entry remains usable  
**Scale/Scope**: One user, active category list, current supported currencies/payment methods

## Constitution Check

- AI-created expenses must use existing Bloc/repository flows after confirmation: PASS.
- Suggested categories must be preview metadata until user confirms: PASS.
- Category writes go through `CategoryRepository`: PASS.
- Cloudflare Worker remains provider-secret boundary: PASS.
- User-facing strings use ARB localization: PASS.
- Home and Add Expense must not duplicate business logic: PASS.

## Project Structure

```text
lib/ai/models/
lib/ai/services/
lib/screens/ai_assistant/
lib/screens/add_expense/
lib/screens/add_expense/widgets/
lib/screens/add_expense/models/
lib/l10n/
workers/ai-gateway/src/
test/ai/
test/add_expense/
test/home/
```

**Structure Decision**: Create a reusable AI capture/draft controller in the app layer and render it in both Home assistant and Add Expense. Keep save orchestration in the existing UI/Bloc boundary so the user always confirms.

## Implementation Strategy

1. Audit current Home AI and Add Expense AI differences.
2. Define one `AiExpenseDraft` contract covering all editable fields plus suggested category metadata.
3. Update parser/gateway schema only if current payload cannot express needed fields.
4. Build one shared `AiExpenseCapturePanel` and controller.
5. Replace Home/Add Expense duplicated AI UI with the shared panel.
6. Implement safe category creation before expense save.
7. Add Arabic/English prompt fixtures and widget tests.

## Risks

- Broad UI refactor can regress manual Add Expense. Mitigation: keep manual form unchanged and feed it from the shared draft.
- AI category creation can duplicate categories. Mitigation: resolve by id/name/alias before creating.
- Settings load failure can lead to wrong currency/payment. Mitigation: block AI default guessing until settings are loaded or user chooses.
- Worker schema changes can break deployed AI. Mitigation: version-compatible parsing and fallback.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/ai test/add_expense test/home --reporter=expanded --timeout=45s
flutter analyze --no-pub
cd workers/ai-gateway && npm run typecheck && npm test
```

## Deferred Items Considered

Deferred AI device QA, quota/provider monitoring, receipt attachment history, and optional model routing remain later. This plan focuses on one shared expense-capture AI experience and safe category creation.
