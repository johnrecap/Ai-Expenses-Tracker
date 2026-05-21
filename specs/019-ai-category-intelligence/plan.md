# Implementation Plan: AI Category Intelligence

**Branch**: `[019-ai-category-intelligence]` | **Date**: 2026-05-17 | **Spec**: `specs/019-ai-category-intelligence/spec.md`  
**Input**: Feature specification from `specs/019-ai-category-intelligence/spec.md`

## Summary

Add a deterministic category resolution layer before and after AI parsing so natural Arabic/English source words map to the user's real active categories. The AI remains preview-first: it may suggest a category, but existing repositories perform creation only after confirmation.

## Technical Context

**Language/Version**: Dart 3.x for Flutter; TypeScript for Cloudflare Worker prompt/schema updates.  
**Primary Dependencies**: Flutter Bloc, existing `expense_repository`, existing `lib/ai` models/services/cubit, Cloudflare Worker AI gateway.  
**Storage**: Firestore user subcollection for learned aliases if implemented; no global category data.  
**Testing**: `flutter test`, `flutter analyze`, Worker `npm test`, Worker `npm run typecheck`.  
**Target Platform**: Flutter app across Android/iOS/web/desktop; Worker for AI provider normalization.  
**Project Type**: Mobile-first Flutter app with Firebase and Cloudflare AI gateway.  
**Performance Goals**: Category resolution under 300 ms locally with 100 categories and 1,000 aliases.  
**Constraints**: No AI direct writes; no category auto-create; no global user data; offline fallback must continue.  
**Scale/Scope**: One authenticated user's active categories and aliases.

## Constitution Check

- **AI Assistant Safety**: Pass. All mutations remain confirmation-first.
- **Repository Pattern**: Pass. Alias/category persistence goes through repository abstractions.
- **User Ownership**: Pass. Learned aliases are user-scoped.
- **Cloudflare Free Path**: Pass. Worker updates do not require Firebase Functions.
- **Change Scope**: Pass. Existing Bloc/Cubit and repository patterns remain.

## Project Structure

```text
specs/019-ai-category-intelligence/
├── spec.md
├── plan.md
└── tasks.md

lib/ai/
├── models/
│   ├── ai_expense_payload.dart
│   ├── ai_action_preview.dart
│   └── ai_category_resolution.dart        # new
├── services/
│   ├── ai_category_resolver.dart          # new
│   ├── ai_response_parser.dart
│   └── mock_ai_service.dart
└── cubit/
    └── ai_assistant_cubit.dart

packages/expense_repository/lib/src/
├── category_alias_repo.dart               # new optional abstraction
├── firebase_category_alias_repo.dart      # new optional implementation
├── models/category_alias.dart             # new optional model
└── entities/category_alias_entity.dart    # new optional entity

workers/ai-gateway/src/ai/
├── promptBuilder.ts
└── structuredSchema.ts

test/ai/
├── ai_category_resolver_test.dart
├── ai_response_parser_gemini_test.dart
└── ai_assistant_cubit_test.dart
```

**Structure Decision**: Keep AI interpretation in `lib/ai`, persistence in `packages/expense_repository`, and provider schema normalization in `workers/ai-gateway`. Widgets receive ready preview state and do not run matching logic inline.

## Research

### Decision: Add deterministic resolver in Flutter
**Rationale**: It preserves offline behavior, reduces AI calls, and can repair imperfect provider output before preview validation.  
**Alternatives considered**: Rely on Gemini only, rejected because quota/provider errors would break category matching; add matching inside UI widgets, rejected because it would duplicate logic.

### Decision: Existing category first, suggestion second
**Rationale**: User data stays tidy and category creation remains intentional.  
**Alternatives considered**: Auto-create missing categories, rejected because it violates confirmation-first safety and creates noisy categories.

### Decision: Alias learning is P2
**Rationale**: MVP can ship with curated aliases. Learned aliases add polish but require new repository/model work.

## Data Model

### CategoryResolution
- `categoryId`: selected existing category id, nullable for suggestions.
- `categoryName`: selected or suggested category name.
- `confidence`: 0.0 to 1.0.
- `reason`: short user-readable reason.
- `source`: `exact_id`, `exact_name`, `alias`, `recent_history`, `ai_suggested`, `manual`.
- `suggestedCategory`: optional nested category suggestion.

### CategoryAlias
- `aliasId`: deterministic id or generated id.
- `userId`: owner.
- `categoryId`: active category target.
- `phrase`: normalized source word or phrase.
- `locale`: example `ar-EG` or `en`.
- `createdAt`, `updatedAt`, `lastUsedAt`.
- `useCount`.

### CategorySuggestion
- `name`: editable category name.
- `icon`: suggested modern icon key.
- `color`: suggested color int.
- `reason`: why this category was suggested.

## Risks

- **Wrong category mapping**: Mitigate with confidence thresholds and editable preview.
- **Alias drift after archive**: Ignore aliases whose category is archived.
- **Overfitting to one user's terms**: Store learned aliases per user only.
- **Provider returns incomplete JSON**: Worker normalizer and Flutter parser convert incomplete high-risk outputs to clarification.

## Verification

Run after implementation:

```text
flutter analyze
flutter test test/ai/ai_category_resolver_test.dart test/ai/ai_response_parser_gemini_test.dart test/ai/ai_assistant_cubit_test.dart
cd workers/ai-gateway && npm run typecheck && npm test
```
