# Implementation Plan: Flexible AI Expense Drafts

**Branch**: `056-ai-flexible-expense-drafts` | **Date**: 2026-05-19 | **Spec**: `specs/056-ai-flexible-expense-drafts/spec.md`

## Summary

Change AI expense capture from clarification-first for missing amount/category to draft-first: any non-empty add-expense-like input should produce an editable preview, leave unknown fields blank, show validation errors, and keep confirmation disabled until the user completes the draft.

## Technical Context

**Language/Version**: Dart 3.x, Flutter; TypeScript Worker  
**Primary Dependencies**: Flutter Bloc, existing AI services, Cloudflare Worker gateway  
**Storage**: No schema change  
**Testing**: Flutter AI unit/widget tests and Worker Vitest normalization tests  
**Scope**: `lib/ai`, `lib/screens/ai_assistant/widgets`, `workers/ai-gateway/src/ai`, `test/ai`, `workers/ai-gateway/test`

## Implementation Notes

- Let `AiResponseParser` parse add-expense payloads with missing amount.
- Make `AiAssistantCubit` emit `previewReady` whenever it can build a draft preview.
- Keep validation errors on the preview to disable confirmation.
- Make unknown non-empty AI responses fall back to an add-expense draft with the original input as description.
- Make the amount field blank when the preview amount is invalid or missing.
- Worker should normalize defaults but avoid clarifying questions for missing draft fields.

## Verification

```text
flutter test --no-pub test/ai --reporter expanded --concurrency=1 --timeout 45s
cd workers/ai-gateway && npm test && npm run typecheck
flutter analyze --no-pub
```

## Deferred Items To Keep In Mind

Real-device AI gateway QA with Arabic parse, provider failure, quota, and manual fallback remains deferred until production gateway configuration is available.
