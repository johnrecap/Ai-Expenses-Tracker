# Feature Specification: AI History Assistant

**Feature Branch**: `069-ai-history-assistant`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a plan for evolving AI from form-fill into a read-only assistant over spending history.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ask Spending Questions (Priority: P1)

As a user, I need to ask questions like "How much did I spend on food this month?" or "Show expenses over 500" and get answers from my own data.

**Why this priority**: This is the highest-value AI feature after reliable tracking.

**Independent Test**: User asks common Arabic/English spending questions and receives read-only answers with matching expense filters or report totals.

**Acceptance Scenarios**:

1. **Given** expenses exist this month, **When** the user asks about food spend, **Then** the assistant returns the same total as deterministic local calculations.
2. **Given** the user asks for expenses over a threshold, **When** results exist, **Then** the assistant shows matching transactions and offers navigation/filtering.

---

### User Story 2 - Explain Changes (Priority: P2)

As a user, I need the assistant to explain why spending increased or what category changed most.

**Why this priority**: Users want insight, not just raw totals.

**Independent Test**: Compare current and previous periods and show deterministic drivers before any AI wording.

**Acceptance Scenarios**:

1. **Given** this month is higher than last month, **When** user asks why, **Then** assistant identifies top category and largest change.
2. **Given** mixed currencies exist, **When** assistant answers, **Then** it uses the shared financial calculation policy.

---

### User Story 3 - Stay Read-Only First (Priority: P1)

As a cautious user, I need history questions to never mutate expenses, categories, budgets, or settings.

**Why this priority**: The safest first AI history release is read-only.

**Independent Test**: All history intents return answer/filter/report previews only and never call mutation repositories.

**Acceptance Scenarios**:

1. **Given** user asks "delete expensive food", **When** history assistant parses it, **Then** it refuses mutation or routes to existing confirm-first command flow.
2. **Given** provider fails, **When** local deterministic answer exists, **Then** local summary remains available.

## Edge Cases

- User asks about a period with no data.
- Ambiguous category names.
- Mixed Arabic/English wording.
- AI provider unavailable.
- Query requests mutation disguised as analysis.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: History Assistant MUST be read-only for the first release.
- **FR-002**: Answers MUST be grounded in deterministic local filters/reports before any AI wording.
- **FR-003**: Natural-language filters MUST map to existing `ExpenseFilter` semantics where possible.
- **FR-004**: Report questions MUST use the shared financial calculation policy.
- **FR-005**: Assistant MUST support Arabic and English question phrasing.
- **FR-006**: Provider failures MUST leave local deterministic summaries available.
- **FR-007**: Mutation requests MUST require existing explicit confirmation flows or be refused.

### Key Entities

- **HistoryQuestionIntent**: Search, total, comparison, category driver, subscription check, or unknown.
- **HistoryAnswer**: Deterministic result, optional AI wording, source filters, confidence, and navigation target.
- **HistoryQueryFilter**: Period/category/amount/payment/currency criteria derived from natural language.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 12 common Arabic/English history questions produce deterministic correct answers in tests.
- **SC-002**: 100% of history intents are read-only or explicitly routed to existing confirm-first mutation flow.
- **SC-003**: Mixed-currency answers match Reports/Home calculation fixtures.
- **SC-004**: Provider failure still returns local summary for supported deterministic questions.

## Assumptions

- This plan does not add new mutation abilities.
- The assistant may call the gateway for wording, but local calculations remain ground truth.

