# Implementation Plan: AI Production Reliability

**Branch**: `038-ai-production-reliability` | **Date**: 2026-05-18 | **Spec**: `specs/038-ai-production-reliability/spec.md`  
**Input**: Audit findings and recent device error: AI must use real Cloudflare gateway when configured, handle quota/provider errors, keep manual fallback, and validate category matching.

## Summary

Make real AI configuration explicit and testable, improve failure handling and quota surfaces, verify category matching with current user categories, and add device QA instructions for Worker-backed AI.

## Technical Context

**Language/Version**: Dart 3.x, Flutter; TypeScript Worker already exists  
**Primary Dependencies**: Existing `lib/ai`, `AuthRepository`, `MonetizationCubit`, `workers/ai-gateway`  
**Storage**: Firestore user data and Worker D1 quota logs; no client provider keys  
**Testing**: Flutter AI tests, Worker tests/typecheck, manual device QA  
**Target Platform**: Android priority  
**Project Type**: Flutter app plus Cloudflare Worker gateway  
**Performance Goals**: AI request timeout remains bounded; manual flows unaffected by AI failure  
**Constraints**: No direct writes from AI service; confirmation-first mutations; free plan daily limits  
**Scale/Scope**: Provider config docs, error mapping, category resolution QA, usage refresh, device test guide

## Constitution Check

- AI service layer remains separate from widgets.
- AI services must never write to Firestore directly.
- AI add/update/delete require explicit confirmation.
- AI provider configuration can include endpoint/provider/model/timeout only, never keys.
- Core finance features continue when AI quota/provider/gateway fails.

## Project Structure

```text
lib/ai/
lib/screens/ai_assistant/
lib/monetization/
workers/ai-gateway/
docs/ai/
test/ai/
```

**Structure Decision**: Keep app AI changes under existing `lib/ai` and UI under `lib/screens/ai_assistant`; keep Worker verification under `workers/ai-gateway`.

## Implementation Notes

- Do not add provider keys to Flutter. Worker secret remains the only provider key location.
- Build commands from Plan 034 should be the source of truth for `AI_GATEWAY_URL`.
- Prefer improving error messages and status surfaces over automatic retries that burn quota.
- Receipt and advice should keep separate daily quota types.

## Risks

- Real provider can return unexpected JSON. Mitigation: strict parser and clarification flow already exists; expand tests with failing examples.
- Auth token issues can look like provider failures. Mitigation: separate auth error messaging.
- Category aliases can overfit. Mitigation: show preview and confidence rather than silent creation.
