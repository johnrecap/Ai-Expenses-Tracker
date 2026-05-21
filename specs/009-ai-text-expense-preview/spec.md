# Feature Specification: AI Text To Expense Preview

**Feature Branch**: `009-ai-text-expense-preview`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Enters Natural Language Expense (P1)
As a user, I type a sentence like `صرفت 250 جنيه على أكل امبارح بالكاش` and get an expense preview.

**Acceptance Criteria**
- AI extracts amount, category, date, payment method, currency, and description.
- Preview is shown before saving.

### User Story 2 - User Confirms Or Edits Preview (P1)
As a user, I review and edit the AI result before it affects my data.

**Acceptance Criteria**
- No expense is created until Confirm.
- User can edit preview fields.
- Unclear text asks for clarification.

## Functional Requirements

- Add AI models.
- Add `AiService` interface.
- Add mock AI service.
- Add parser that accepts structured JSON only.
- Add `AiAssistantCubit`.
- Add assistant UI and preview card.

## Out Of Scope

- Receipt scanning.
- Update/delete commands.
- Remote provider production secrets.

## Success Metrics

- AI parsing and cubit behavior have tests.
- Confirmed AI expenses use normal repository flow.

## Detailed Requirements And Edge Cases

- AI output must be structured JSON. Plain natural-language model output is invalid.
- No expense may be created before the user presses Confirm.
- Confidence below threshold must ask for clarification.
- The preview must allow user edits because AI extraction can be wrong.
- Category matching must support Arabic and English names where possible.
- The remote AI implementation must not include API secrets in Flutter code.
