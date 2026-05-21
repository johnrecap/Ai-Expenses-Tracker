# Tasks: Smart Budget Recommendations

**Input**: `specs/072-smart-budget-recommendations/spec.md`, `plan.md`

## Phase 1: Recommendation Core

- [X] T001 Add `BudgetRecommendation` and input models under `lib/screens/budget/models/` or `lib/services/finance/`.
  - **Why**: Recommendations need explainable metadata.
  - **Benefit**: UI can show amount, confidence, and caveats.
  - **Expected**: Models include scope, suggested amount, confidence, source period, and explanation.

- [X] T002 Implement `BudgetRecommendationService`.
  - **Why**: Recommendation logic must be testable and local.
  - **Benefit**: Avoids AI hallucination and quota dependency.
  - **Expected**: Service handles average, trend, outliers, sparse data, and missing-rate caveats.

- [X] T003 Add tests for steady, growing, shrinking, sparse, and outlier histories.
  - **Why**: Budget suggestions can mislead if edge cases are ignored.
  - **Benefit**: Keeps recommendations trustworthy.
  - **Expected**: Every fixture has expected amount/confidence/caveat.

## Phase 2: Monthly Budget UI

- [X] T004 [US1] Add recommendation entry point to Monthly Budget screen.
  - **Why**: Users set monthly budgets there.
  - **Benefit**: Suggestion appears where it is useful.
  - **Expected**: User can view suggestion without replacing current budget automatically.

- [X] T005 [US1] Open budget form with suggested editable amount and threshold.
  - **Why**: User must remain in control.
  - **Benefit**: Reduces setup friction without surprise saves.
  - **Expected**: Save only occurs after explicit user action.

- [X] T006 [US1] Show confidence and caveats.
  - **Why**: Sparse/missing-rate history affects reliability.
  - **Benefit**: Builds trust in suggestions.
  - **Expected**: UI labels low confidence and missing-rate exclusions.

## Phase 3: Category Budget Suggestions

- [X] T007 [US2] Add category recommendation list for high/growing categories.
  - **Why**: Category budgets are powerful but hard to set up.
  - **Benefit**: Helps users focus on meaningful categories.
  - **Expected**: Suggested categories include amount and reason.

- [X] T008 [US2] Open category budget form with editable suggested values.
  - **Why**: Suggestions should not auto-create budgets.
  - **Benefit**: Prevents unwanted budget clutter.
  - **Expected**: User can accept/edit/cancel each suggestion.

## Phase 4: Localization And Verification

- [X] T009 Add ARB keys for recommendation labels, confidence, caveats, accept/edit/cancel, and explanations.
  - **Why**: New UI copy is app-owned.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: Matching keys in `app_en.arb` and `app_ar.arb`.

- [X] T010 Run `flutter gen-l10n`.
  - **Why**: New keys require generated getters.
  - **Benefit**: Catches ARB issues.
  - **Expected**: Generation succeeds.

- [ ] T011 Add budget/category budget widget or cubit tests for accepting recommendations.
  - **Why**: Integration must prove no automatic save.
  - **Benefit**: Keeps user control intact.
  - **Expected**: Tests verify editable prefill and explicit save.

- [X] T012 Run targeted budget/category budget tests and `flutter analyze --no-pub`.
  - **Why**: Recommendation feature touches budget flows.
  - **Benefit**: Confirms correctness.
  - **Expected**: Targeted tests and analyzer pass.
