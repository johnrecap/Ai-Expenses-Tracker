# Tasks: AI Category Intelligence

**Input**: `specs/019-ai-category-intelligence/spec.md`, `plan.md`  
**Prerequisites**: Plans 004, 009, 010, and 018 are already implemented.

**Implementation Intent**: Make AI category selection reliable by comparing the expense source against existing categories, known aliases, and optional learned aliases before showing a confirmation preview.

## Phase 1: Setup And Current Behavior Audit

- [X] T001 Audit current AI category flow in `lib/ai/services/ai_response_parser.dart`, `lib/ai/models/ai_action_preview.dart`, `lib/ai/cubit/ai_assistant_cubit.dart`, and `workers/ai-gateway/src/ai/structuredSchema.ts`.

  **Why**: A future worker must know exactly where category data enters, where it is validated, and why previews fail today.
  **Steps**:
  1. Trace remote response `structuredJson.category/categoryId` into `AiResponseParser`.
  2. Trace `AiExpensePayload.categoryName/categoryId` into `AiActionPreview.fromPayload`.
  3. Record where validation adds `Select a category`.
  4. Confirm the AI service does not write to Firestore.
  **Done when**: Implementation notes identify the exact insertion point for `AiCategoryResolver`.

- [X] T002 Create resolver test file `test/ai/ai_category_resolver_test.dart`.

  **Why**: Matching rules are easy to break and must be deterministic.
  **Steps**:
  1. Add tests for Arabic transport phrases: `مواصلات`, `المواصلات`, `اوبر`, `أوبر`, `تاكسي`.
  2. Add tests for food phrases: `اكل`, `أكل`, `مطعم`, `مطاعم`, `دليفري`.
  3. Add tests for bills, shopping, entertainment, health, travel, subscriptions, rent, fuel.
  4. Add an ambiguous phrase test that must return low confidence or no match.
  5. Add an archived category test that must not match.
  **Done when**: Tests fail because `AiCategoryResolver` does not exist yet.

## Phase 2: Foundational Resolver

- [X] T003 Create `AiCategoryResolution` model in `lib/ai/models/ai_category_resolution.dart`.

  **Why**: Category matching needs structured metadata, not just a string.
  **Steps**:
  1. Add fields: `categoryId`, `categoryName`, `confidence`, `reason`, `source`, `suggestedCategory`.
  2. Add `hasExistingCategory` and `requiresUserCategoryConfirmation` getters.
  3. Add `copyWith` only if needed by preview editing.
  4. Export the model from `lib/ai/models/models.dart`.
  **Done when**: Other AI files can import category resolution without depending on UI widgets.

- [X] T004 Create deterministic resolver in `lib/ai/services/ai_category_resolver.dart`.

  **Why**: Flutter must still classify common expenses when the AI gateway is unavailable or returns weak category data.
  **Steps**:
  1. Accept input text, parsed category id/name, active categories, optional aliases, and recent expenses.
  2. Normalize Arabic text by removing diacritics, normalizing `أ/إ/آ` to `ا`, and lowercasing English.
  3. Try exact `categoryId`.
  4. Try exact normalized category name.
  5. Try curated alias dictionary.
  6. Try recent expense source hints only when they point to an active category.
  7. Return `AiCategoryResolution` with confidence and reason.
  **Done when**: Resolver tests for common aliases pass.

- [X] T005 Extend `AiExpensePayload` in `lib/ai/models/ai_expense_payload.dart`.

  **Why**: The preview needs to carry category resolution metadata without changing repository models.
  **Steps**:
  1. Add optional `categoryResolution`.
  2. Keep existing constructor backward compatible.
  3. Update equality/hash behavior if the model uses value comparison.
  4. Do not add Firestore fields here.
  **Done when**: Existing parser and preview tests still compile.

- [X] T006 Apply resolver in `AiAssistantCubit._handleAddExpenseResponse` in `lib/ai/cubit/ai_assistant_cubit.dart`.

  **Why**: Cubit has access to input text, context categories, and response payload before preview creation.
  **Steps**:
  1. Before `AiActionPreview.fromPayload`, call `AiCategoryResolver.resolve`.
  2. If resolver selects an existing category, create a payload copy with selected `categoryId/categoryName`.
  3. If resolver suggests a new category, keep preview in a category-confirmation state.
  4. If resolver has low confidence, emit `needsClarification` with a readable category question.
  5. Preserve update/delete command behavior unless it uses add-expense preview.
  **Done when**: Add-expense AI preview no longer fails for clear transport/food Arabic inputs.

## Phase 3: Suggested Category Preview

- [X] T007 Add suggested category support to `AiActionPreview` in `lib/ai/models/ai_action_preview.dart`.

  **Why**: Users need to review category creation separately from expense confirmation.
  **Steps**:
  1. Add optional suggested category fields or nested model.
  2. Keep `validate()` requiring either an existing category or an approved suggested category.
  3. Ensure `toExpense()` uses a confirmed category only.
  4. Do not let `toExpense()` silently create a category.
  **Done when**: Preview model can represent "expense ready but category needs confirmation".

- [X] T008 Update AI preview UI in `lib/screens/ai_assistant/widgets/ai_action_preview_card.dart`.

  **Why**: The user must see whether a category was matched or newly suggested.
  **Steps**:
  1. Show matched category with reason when available.
  2. Show suggested category name/icon/color when no existing category matches.
  3. Provide controls to choose an existing category instead.
  4. Provide an edit path for suggested category name/icon/color.
  5. Disable final confirm until category choice is valid.
  **Done when**: Category creation is visible and editable before saving.

- [X] T009 Integrate confirmed category creation in `AiAssistantSheet` and existing category repository flow.

  **Why**: AI services must not create categories; the UI/domain flow should do it after confirmation.
  **Steps**:
  1. If preview includes a new confirmed category, create it through `CategoryRepository.createCategory`.
  2. Wait for category creation before creating the expense.
  3. Use the created category snapshot in the expense.
  4. On category create failure, show a retry message and do not save the expense.
  5. Refresh category context after successful creation.
  **Done when**: Confirming a suggested category creates exactly one category and one expense.

## Phase 4: Worker And Parser Alignment

- [X] T010 Extend Worker schema in `workers/ai-gateway/src/ai/structuredSchema.ts`.

  **Why**: The provider should return structured category hints instead of uncontrolled prose.
  **Steps**:
  1. Add optional fields `categoryConfidence`, `categoryReason`, `suggestedCategoryName`, `suggestedCategoryIcon`, `suggestedCategoryColor`.
  2. Normalize clear Arabic/English category words to a known category name when possible.
  3. Keep `needsConfirmation = true`.
  4. Lower confidence below 0.75 when category cannot be inferred.
  **Done when**: Worker output gives Flutter enough metadata for preview handling.

- [X] T011 Update Worker prompt in `workers/ai-gateway/src/ai/promptBuilder.ts`.

  **Why**: The model needs explicit instructions to prefer existing categories and suggest only when missing.
  **Steps**:
  1. Tell Gemini to use provided `categoryId` when there is a clear active category match.
  2. Tell Gemini to suggest a category only when no active category matches.
  3. Include Arabic source examples for transport, food, bills, shopping, entertainment, subscriptions, rent, fuel.
  4. Tell Gemini not to invent that a category was created.
  **Done when**: Prompt clearly supports user category matching.

- [X] T012 Add Worker tests in `workers/ai-gateway/test/structuredSchema.test.ts`.

  **Why**: Provider normalization must stay compatible with Flutter.
  **Steps**:
  1. Test Arabic transport input maps to `Transport`.
  2. Test missing category lowers confidence and includes a clarifying question.
  3. Test provider suggested category fields survive normalization.
  4. Test no mutation claims are present.
  **Done when**: Worker tests pass without real Gemini network calls.

## Phase 5: Learned Aliases (P2)

- [X] T013 Add `CategoryAlias` model and entity in `packages/expense_repository/lib/src/models/category_alias.dart` and `packages/expense_repository/lib/src/entities/category_alias_entity.dart`.

  **Why**: User-specific learned mappings must be persisted separately from category definitions.
  **Steps**:
  1. Add `aliasId`, `userId`, `categoryId`, `phrase`, `locale`, `createdAt`, `updatedAt`, `lastUsedAt`, `useCount`.
  2. Add `toEntity/fromEntity`.
  3. Add serialization tests.
  **Done when**: Alias model can round-trip without Firestore access.

- [X] T014 Add `CategoryAliasRepository` and Firebase implementation.

  **Files**: `packages/expense_repository/lib/src/category_alias_repo.dart`, `packages/expense_repository/lib/src/firebase_category_alias_repo.dart`.
  **Why**: Persistence must follow repository pattern and user-scoped Firestore paths.
  **Steps**:
  1. Store aliases under `users/{userId}/category_aliases/{aliasId}`.
  2. Add `getAliases`, `watchAliases`, `upsertAlias`, `deleteAlias`.
  3. Reject empty userId and empty phrase.
  4. Export from package barrel files.
  **Done when**: AI layer can load aliases without direct Firestore access.

- [X] T015 Learn aliases after confirmed AI expense in `AiAssistantCubit` or a focused service.

  **Why**: The app should learn only after the user confirms the mapping.
  **Steps**:
  1. Extract source phrase only from strong resolver matches.
  2. Upsert alias after expense confirmation succeeds.
  3. Increment use count and update last used timestamp.
  4. Do not learn from canceled or failed previews.
  **Done when**: Confirmed mappings improve later local resolution.

## Phase 6: Verification And Documentation

- [X] T016 Add and run targeted Flutter AI tests.

  **Commands**:
  ```text
  flutter test test/ai/ai_category_resolver_test.dart test/ai/ai_assistant_cubit_test.dart test/ai/ai_response_parser_gemini_test.dart
  ```
  **Done when**: All targeted AI tests pass.

- [X] T017 Run Worker validation.

  **Commands**:
  ```text
  cd workers/ai-gateway
  npm run typecheck
  npm test
  ```
  **Done when**: Worker schema/prompt changes are type-safe and tested.

- [X] T018 Run full app verification.

  **Commands**:
  ```text
  flutter analyze
  flutter test
  ```
  **Done when**: Existing app behavior remains healthy.

- [ ] T019 Manual QA on device.

  **Why**: Arabic text, category selection, and preview editing must be validated in the real keyboard/app flow.
  **Steps**:
  1. Sign in as a test user.
  2. Ensure categories Food, Transport, Bills, Shopping exist.
  3. Try at least 10 Arabic phrases.
  4. Confirm one existing-category expense.
  5. Confirm one suggested-category expense.
  6. Cancel one suggested-category preview and verify no data is saved.
  **Done when**: Device flow matches acceptance scenarios.
