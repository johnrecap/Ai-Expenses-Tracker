# Feature Specification: Smart Budget Recommendations

**Feature Branch**: `072-smart-budget-recommendations`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested smart budget recommendations based on recent spending and monthly financial story improvements.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recommended Monthly Budgets (Priority: P2)

As a user, I need the app to suggest a monthly budget based on my last 3 months instead of forcing me to guess.

**Why this priority**: Users often do not know what budget amount is realistic.

**Independent Test**: Given 3 months of expenses, the app recommends a budget and warning threshold with an explanation.

**Acceptance Scenarios**:

1. **Given** 3 months of food spending, **When** user opens budget recommendation, **Then** app suggests an amount based on average/trend.
2. **Given** limited history, **When** recommendation is requested, **Then** app explains low confidence and suggests a safe default range.

---

### User Story 2 - Category Budget Suggestions (Priority: P2)

As a user, I need suggestions for category budgets where spending is high or growing.

**Why this priority**: Category budgets are useful but tedious to configure manually.

**Independent Test**: App suggests categories with high/growing spend and lets user create/edit budget manually.

**Acceptance Scenarios**:

1. **Given** transport spending increased, **When** user views recommendations, **Then** app suggests a transport budget.
2. **Given** user accepts, **When** they proceed, **Then** budget form opens with editable values, not automatic save.

## Edge Cases

- Less than 3 months of data.
- Missing exchange rates.
- Highly irregular outlier month.
- User already has a budget.
- User wants lower/higher aggressive target.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Budget recommendations MUST be deterministic and based on user spending history.
- **FR-002**: Recommendations MUST be editable before saving.
- **FR-003**: Recommendations MUST disclose low confidence, outliers, and missing-rate caveats.
- **FR-004**: Monthly and category suggestions MUST use shared financial calculation policy.
- **FR-005**: Manual budget creation MUST remain available.

### Key Entities

- **BudgetRecommendation**: Scope, suggested amount, confidence, explanation, source period, and caveats.
- **BudgetRecommendationInput**: Historical expenses, current settings, existing budgets, and target aggressiveness.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Recommendations are generated for users with at least 2 complete months of data.
- **SC-002**: 100% of recommendations are editable before save.
- **SC-003**: Outlier/missing-rate caveats appear when applicable.
- **SC-004**: Recommendation tests cover steady, growing, shrinking, sparse, and outlier histories.

## Assumptions

- First release uses deterministic local logic, not provider AI.
- AI may later explain recommendations but must not be the source of truth.

