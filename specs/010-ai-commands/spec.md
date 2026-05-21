# Feature Specification: AI Commands Over Existing Data

**Feature Branch**: `010-ai-commands`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Searches And Summarizes With AI (P1)
As a user, I ask `وريني مصاريف الأكل الشهر ده` or `لخصلي صرفي الأسبوع ده`.

**Acceptance Criteria**
- AI search maps to existing filters.
- AI summary uses actual local/report calculations.

### User Story 2 - User Updates Or Deletes With Confirmation (P1)
As a user, I can say `غير مصروف أوبر لـ 180` or `احذف آخر مصروف سجلته`, but the app asks me to confirm the exact target.

**Acceptance Criteria**
- Ambiguous targets show candidates.
- Update/delete never happens without confirmation.

## Functional Requirements

- Add AI intents for search, summary, advice, update, delete.
- Add AI action logs.
- Add target matching.
- Add confirmation UI for mutations.
- Add local aggregate based advice.

## Out Of Scope

- Receipt image parsing.
- Spending prediction.

## Success Metrics

- Target matching tests cover no match, one match, and multiple matches.
- AI actions are logged with final status.

## Detailed Requirements And Edge Cases

- Search, summary, and advice are read-only and may execute after previewing the interpreted request.
- Update and delete require exact target confirmation.
- If more than one target candidate is plausible, the user must choose one manually.
- Advice must be based on actual calculated totals, not invented AI numbers.
- Every AI command should be logged with raw input, parsed intent, confidence, and final status.
