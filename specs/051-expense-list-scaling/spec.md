# Feature Specification: Expense List Scaling

**Feature Branch**: `051-expense-list-scaling`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: UX/performance review suggestion to add pagination or limits for expense lists instead of watching all expenses at once as data grows.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Load Recent Expenses Quickly (Priority: P1)

Users with many expenses must see the app open and the expenses list render quickly by loading an initial bounded set.

**Why this priority**: Full collection reads can become slow and expensive as user history grows.

**Independent Test**: A repository/widget test seeds many expenses and verifies the first page/list load uses a bounded result set and displays the newest items first.

**Acceptance Scenarios**:

1. **Given** a user has many expenses, **When** they open Home or Expenses, **Then** the first screen loads a bounded recent set.
2. **Given** the first page loads, **When** the user scrolls, **Then** more expenses can be requested without duplicating rows.

---

### User Story 2 - Preserve Filtering Semantics With Bounded Reads (Priority: P2)

Existing date, category, amount, payment method, currency, and search filters must remain predictable when the app uses paginated or bounded reads.

**Why this priority**: Performance cannot come at the cost of confusing filter results.

**Independent Test**: Filter tests confirm whether each filter is server-bounded, locally applied within a date range, or requires the user to widen the date range.

**Acceptance Scenarios**:

1. **Given** a date range filter, **When** expenses are loaded, **Then** the repository reads the date-scoped set before local filters.
2. **Given** a search query without a date range, **When** the data set is too large, **Then** the UI communicates that results are based on the loaded range or asks for a date range.

---

### User Story 3 - Avoid Hidden Cost And Index Regressions (Priority: P3)

Pagination must use Firestore-supported query patterns and documented indexes.

**Why this priority**: Scaling changes can introduce missing-index runtime failures or expensive reads.

**Independent Test**: Repository tests and index docs identify the query order, cursor fields, and required indexes.

**Acceptance Scenarios**:

1. **Given** a paginated query is added, **When** indexes are checked, **Then** `firestore.indexes.json` includes required composite indexes.
2. **Given** a query cannot be indexed cleanly, **When** implementation is planned, **Then** it stays local/filter-bounded instead of adding unsupported query combinations.

## Edge Cases

- Offline Firestore snapshots and pending writes must still show useful sync feedback.
- New local expenses may appear at the top while older pages are loaded.
- Search across all historical expenses may require a future dedicated search index; this plan should not fake global search if only one page is loaded.
- Mixed-currency calculations must not combine incompatible currencies.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Home and Expenses initial reads must be bounded for large histories.
- **FR-002**: Users must be able to load more expenses from the Expenses screen.
- **FR-003**: Bounded reads must preserve newest-first ordering.
- **FR-004**: Filtering behavior must be documented and tested for date-scoped reads and local filters.
- **FR-005**: Firestore query changes must update `firestore.indexes.json` when required.
- **FR-006**: Offline sync feedback must remain visible for pending local writes.
- **FR-007**: The UI must not imply it searched all history when only a bounded page is loaded.

### Key Entities

- **Expense Page**: Bounded ordered result set with cursor metadata.
- **Expense Query Scope**: Date/user/filter constraints that determine what is loaded.
- **Load More State**: UI state for loading, exhausted, error, and retry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Initial Expenses load uses a bounded count rather than all user expenses.
- **SC-002**: Users can load at least one additional page without duplicates.
- **SC-003**: Existing filter tests are updated to document bounded-read behavior.
- **SC-004**: Required Firestore indexes are documented or generated for any new query pattern.

## Assumptions

- This is a later-stage performance plan and should follow correctness fixes first.
- Existing local filtering remains acceptable within explicit date/range scopes.
- Global full-text search is out of scope unless a future dedicated search feature is planned.
