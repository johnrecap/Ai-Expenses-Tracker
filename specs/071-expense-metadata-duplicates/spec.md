# Feature Specification: Expense Metadata And Duplicate Detection

**Feature Branch**: `071-expense-metadata-duplicates`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested plans for merchant/tags/attachments and duplicate detection.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Rich Expense Details (Priority: P2)

As an advanced user, I need merchant, tags, and optional attachments so expenses are easier to search and understand later.

**Why this priority**: Rich metadata increases value after core tracking is stable.

**Independent Test**: User adds merchant/tags/attachment metadata and can find the expense through search/filter/export.

**Acceptance Scenarios**:

1. **Given** a merchant name, **When** an expense is saved, **Then** the merchant appears on detail/search/export surfaces.
2. **Given** tags are added, **When** the user filters/searches, **Then** matching tagged expenses are found.

---

### User Story 2 - Detect Possible Duplicates (Priority: P2)

As a daily user, I need the app to warn me if I enter a likely duplicate expense.

**Why this priority**: Duplicate entries create wrong totals and reduce trust.

**Independent Test**: Adding similar amount/category/merchant/date expenses triggers a warning before save.

**Acceptance Scenarios**:

1. **Given** an expense with same amount/category/day already exists, **When** user adds another similar expense, **Then** the app shows a possible duplicate warning.
2. **Given** the user confirms anyway, **When** they save, **Then** the expense is saved normally.

## Edge Cases

- Legitimate repeated same-price purchases.
- Missing merchant/category.
- AI-generated draft duplicates.
- Receipt image duplicated.
- Offline pending writes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Expense model SHOULD support merchant and tags.
- **FR-002**: Attachments MUST not store provider secrets or sensitive files outside approved app storage policy.
- **FR-003**: Duplicate detection MUST warn, not block, unless future product policy changes.
- **FR-004**: Duplicate detection MUST work for manual, AI, and receipt drafts before save.
- **FR-005**: Search/export SHOULD include merchant and tags.
- **FR-006**: Firestore rules MUST validate new metadata if persisted.

### Key Entities

- **ExpenseMetadata**: Merchant, tags, attachment refs, and note fields.
- **DuplicateCandidate**: Existing expense, similarity reasons, score, and user decision.
- **ExpenseAttachment**: Local/remote reference, media type, created date, and owning expense.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Duplicate warning appears for at least 90% of same-day exact amount/category duplicate fixtures.
- **SC-002**: False positives can be dismissed and saved in 100% of warning cases.
- **SC-003**: Merchant and tags are searchable/filterable after save.
- **SC-004**: No duplicate warning auto-deletes or blocks an expense without user choice.

## Assumptions

- Attachments may start as optional local references or receipt linkage; full cloud storage can be a later plan.
- Duplicate detection is deterministic local logic.

