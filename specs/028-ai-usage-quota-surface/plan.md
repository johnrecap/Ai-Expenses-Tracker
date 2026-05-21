# Implementation Plan: AI Usage Quota Surface

**Branch**: `028-ai-usage-quota-surface` | **Date**: 2026-05-17 | **Spec**: `specs/028-ai-usage-quota-surface/spec.md`  
**Input**: Make Free AI usage visible, accurate, and safe when quota or provider availability fails.

## Summary

Normalize AI usage and quota errors from the Worker, expose them through app-side AI/monetization state, and update AI Assistant, Settings, and Free/Premium UI to show remaining usage and fallback actions. No core finance feature may depend on provider availability.

## Technical Context

**Language/Version**: Dart 3.x, TypeScript Worker if response contract changes  
**Primary Dependencies**: Flutter Bloc/Cubit, existing AI gateway client, Cloudflare Worker D1 quota  
**Storage**: Worker D1 quota; optional local cached usage snapshot in Flutter  
**Testing**: AI parser/client tests, Cubit tests, widget tests for error surfaces, Worker tests if response contract changes  
**Target Platform**: Flutter app plus Cloudflare Worker gateway  
**Project Type**: Flutter app with serverless AI gateway  
**Performance Goals**: Usage UI updates immediately after successful AI call when response data exists  
**Constraints**: No direct Gemini key in Flutter; no manual feature blocked by AI failures; no fake local quota decrement after backend rejection  
**Scale/Scope**: AI gateway response mapping, app error model, AI Assistant UI, Settings AI usage section, Free/Premium quota card

## Constitution Check

- AI provider responses must be parsed through service layers and structured models.
- AI services must not write to Firestore.
- Receipt/advice calls must respect request-specific backend quota keys.
- Free core finance features remain usable when AI quota is exhausted.

## Project Structure

```text
lib/ai/
|-- models/
|-- services/
|-- cubit/
`-- widgets/

lib/monetization/
|-- models/
`-- cubit/

lib/screens/settings/widgets/ai_settings_section.dart
workers/ai-gateway/
```

**Structure Decision**: Usage normalization belongs in AI service/model code and is surfaced through monetization state; widgets only render prepared state.

## Implementation Notes

- Prefer extending existing gateway response models rather than creating parallel maps.
- If Worker contract is changed, update Worker tests and Flutter client together.
- Error messages must be user-safe and short; technical details can be debug-only.
- Use cached same-day usage only as a display hint, not as authorization.

## Risks

- Worker may not return usage for all actions. Mitigation: show stale/unknown state.
- Rewarded credits require backend support. Mitigation: hide the option until confirmed by policy.
- Updating both Flutter and Worker contracts can drift. Mitigation: document response contract in tests.
