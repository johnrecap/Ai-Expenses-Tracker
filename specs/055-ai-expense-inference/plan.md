# Implementation Plan: Smarter AI Expense Inference

**Branch**: `055-ai-expense-inference` | **Date**: 2026-05-19 | **Spec**: `specs/055-ai-expense-inference/spec.md`  
**Input**: AI assistant asks for amount, category, date, and payment method even when the user input has enough information for a preview.

## Summary

Make add-expense parsing smarter by treating app defaults as valid inferred values for payment method, currency, and missing date; expand relative-date parsing for phrases like `last night`; and align local mock, Flutter parser/cubit, and Cloudflare Worker normalization so the assistant asks only for truly missing amount/category.

## Technical Context

**Language/Version**: Dart 3.x, Flutter; TypeScript Worker  
**Primary Dependencies**: Flutter Bloc, existing AI services, Cloudflare Worker gateway, Gemini structured output, existing category resolver  
**Storage**: No schema change; uses existing settings defaults and category lists  
**Testing**: Flutter AI unit tests plus Worker Vitest structured-schema tests  
**Target Platform**: Android release APK and Cloudflare Worker runtime  
**Project Type**: Mobile app with backend gateway  
**Performance Goals**: Parse-to-preview should remain one user action; no extra clarification for inferable defaults  
**Constraints**: Confirmation-first AI safety remains mandatory; provider keys stay out of Flutter; no automatic expense writes  
**Scale/Scope**: `lib/ai`, `lib/screens/ai_assistant`, `workers/ai-gateway/src/ai`, targeted tests

## Constitution Check

- Spec Kit artifacts created before implementation.
- AI service remains separate from widgets.
- AI never writes directly to Firestore.
- Existing preview and confirmation flow remains mandatory.
- Provider key boundaries remain unchanged.

**Gate Status**: PASS.

## Current Code Findings

- `AiResponseParser` throws for high-confidence add-expense responses missing date, even though preview can default date today.
- `AiAssistantCubit._handleAddExpenseResponse()` rejects any add-expense response below confidence 0.75 before local category/default inference can improve the payload.
- `AiActionPreview.fromPayload()` already defaults date to now, currency to base currency, and payment method to default payment method.
- `MockAiService` lowers confidence unless amount, category, and payment method are all detected, so omitted payment method blocks preview.
- Cloudflare Worker prompt says default payment/date/currency may be inferred, but `missingAddExpenseFields()` still includes date and payment method as missing fields.
- Worker date inference supports yesterday/today but not `last night`.

## Project Structure

```text
specs/055-ai-expense-inference/
|-- spec.md
|-- plan.md
|-- tasks.md
`-- checklists/requirements.md

lib/ai/cubit/ai_assistant_cubit.dart
lib/ai/services/ai_response_parser.dart
lib/ai/services/mock_ai_service.dart
lib/ai/models/ai_response.dart
lib/ai/models/ai_action_preview.dart
workers/ai-gateway/src/ai/promptBuilder.ts
workers/ai-gateway/src/ai/structuredSchema.ts
test/ai/
workers/ai-gateway/test/
```

**Structure Decision**: Keep inference in service/parser layers and gateway normalization; widgets should only display resulting preview or targeted clarification.

## Implementation Notes

- Adjust add-expense required-field logic to require amount and category after inference, not payment/date/currency.
- Let the Cubit build a resolved payload/preview before deciding clarification when the response is low solely because safe defaults were omitted.
- Add relative date parsing for `last night` in Flutter parser and Worker normalization.
- Update Mock AI confidence so common natural language with amount/category/date but no payment method reaches preview using `context.defaultPaymentMethod`.
- Update Worker `missingAddExpenseFields()` so payment method/date are not clarification blockers after defaults.
- Clarification text should be field-specific: amount only, category only, or amount and category.
- Keep low-confidence unknown intent, ambiguous mutation target, and no-amount/no-category cases protective.

## Verification

```text
flutter test --no-pub test/ai --reporter expanded --concurrency=1 --timeout 45s
cd workers/ai-gateway
npm test
npm run typecheck
flutter analyze --no-pub
```

## Deferred Items To Keep In Mind

The deferred AI reliability item still applies: run Android device QA with the real `AI_GATEWAY_URL`, Arabic parse, provider failure, quota, and manual fallback. This plan improves inference rules but does not deploy the Worker or configure production secrets.

## Complexity Tracking

No constitution violations. The plan changes validation and normalization rules, not the confirmation/write boundary.
