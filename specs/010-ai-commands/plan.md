# Implementation Plan: AI Commands Over Existing Data

## Technical Context

This extends AI from add-preview to searching, summarizing, advice, update, and delete.

## Architecture

Reuse filter and report services. Add action logging and target matching. Mutations require confirmation.

## Files

- Create: `lib/ai/models/ai_target_match.dart`
- Create: `lib/ai/models/ai_search_payload.dart`
- Create: `lib/ai/models/ai_summary_payload.dart`
- Create: `lib/ai/models/ai_advice_payload.dart`
- Create: `lib/ai/services/ai_action_matcher.dart`
- Create: `lib/ai/services/ai_advice_service.dart`
- Create: `packages/expense_repository/lib/src/models/ai_action_log.dart`
- Create: `packages/expense_repository/lib/src/ai_action_log_repo.dart`
- Modify: `lib/ai/cubit/ai_assistant_cubit.dart`

## Data Model

`AiActionLog`: raw input, parsed response, action type, confidence, status, timestamps.

## Risks

- Update/delete matching must avoid wrong target selection.
- AI advice must be grounded in local aggregates.

## Verification

- Target matcher unit tests.
- Cubit tests for search, summary, advice, update preview, delete preview.

## Detailed Execution Guidance

- Implement read-only commands before update/delete.
- Target matching must be deterministic and explainable.
- Every mutation command must produce a preview state.
- Advice must use local report/filter calculations as ground truth.
- Log canceled commands too, because cancellation is a meaningful user decision.
