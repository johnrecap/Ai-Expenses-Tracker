# Implementation Plan: AI Text To Expense Preview

## Technical Context

AI must not directly mutate data. It should parse natural text into structured JSON and show a preview.

## Architecture

Create separate `lib/ai` domain/service/cubit layer and UI under `lib/screens/ai_assistant`. Use mock AI first and remote provider behind interface later.

## Files

- Create: `lib/ai/models/*`
- Create: `lib/ai/services/ai_service.dart`
- Create: `lib/ai/services/mock_ai_service.dart`
- Create: `lib/ai/services/remote_ai_service.dart`
- Create: `lib/ai/services/ai_response_parser.dart`
- Create: `lib/ai/cubit/ai_assistant_cubit.dart`
- Create: `lib/ai/cubit/ai_assistant_state.dart`
- Create: `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`
- Create: `lib/screens/ai_assistant/widgets/*`
- Modify: `lib/screens/add_expense/views/add_expense.dart`

## Data Model

`AiResponse`, `AiExpensePayload`, `AiActionPreview`, `AiIntent`.

## Risks

- Remote AI secrets must not be stored in Flutter.
- Arabic date/payment/category parsing needs deterministic tests.

## Verification

- Parser tests for valid and malformed JSON.
- Cubit tests for preview, clarification, failure, and confirm.

## Detailed Execution Guidance

- Build the mock service first so UI and Cubit can be developed without network.
- Keep the remote AI provider behind `AiService`.
- Parser must reject unstructured text.
- Confirmation must call normal expense creation paths.
- Store `source = ai` for confirmed AI-created expenses.
