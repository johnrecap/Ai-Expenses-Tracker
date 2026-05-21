# Implementation Plan: AI History Assistant

**Branch**: `069-ai-history-assistant` | **Date**: 2026-05-20 | **Spec**: `specs/069-ai-history-assistant/spec.md`

## Summary

Add a read-only AI History Assistant that answers natural-language questions over the user's expenses and reports. It maps questions to deterministic local filters and report calculations first, then optionally uses AI only to phrase the answer.

## Technical Context

**Language/Version**: Dart 3.x, Flutter, Cloudflare Worker optional  
**Primary Dependencies**: Existing `AiAssistantCubit`, `ExpenseFilterService`, `ReportCalculator`, `AiAdviceService`, gateway client  
**Storage**: No new storage for MVP; optional AI action logs for question history  
**Testing**: AI intent/parser tests, filter/report tests, cubit tests  
**Target Platform**: Flutter mobile app  
**Project Type**: AI read-only assistant feature  
**Performance Goals**: Deterministic answers over loaded/date-scoped expenses without blocking UI  
**Constraints**: No direct mutation; no raw provider answer as ground truth; no secrets in Flutter  
**Scale/Scope**: One user's loaded expense/report data

## Constitution Check

- AI service does not write to Firestore: PASS.
- Deterministic services are ground truth: PASS.
- Missing/ambiguous AI results do not mutate: PASS.
- App language controls AI locale: PASS.

## Project Structure

```text
lib/ai/
lib/screens/ai_assistant/
lib/services/expense_filter_service.dart
lib/services/report_calculator.dart
lib/screens/reports/
lib/screens/expenses/
workers/ai-gateway/
test/ai/
test/reports/
test/expenses/
```

## Implementation Strategy

1. Define read-only history intents and answer model.
2. Add local deterministic resolver for common questions.
3. Add optional provider wording behind gateway without trusting it for math.
4. Render answers with source filters, totals, and navigation options.
5. Add tests for Arabic/English questions and mutation refusal.

## Risks

- Users may expect mutation from chat. Mitigation: keep first release read-only and route mutation commands to existing confirm-first flow.
- Provider wording can hallucinate. Mitigation: display deterministic numbers and filters as the source of truth.

## Deferred Items Considered

Relevant deferred items: real AI gateway QA, provider monitoring, Arabic parse testing, and optional model/provider routing only behind the gateway.

