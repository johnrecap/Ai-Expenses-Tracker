# Feature Specification: Advanced Search And Filters

**Feature Branch**: `007-search-filters`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Searches Expenses (P1)
As a user, I search by name, category, or description to find expenses quickly.

**Acceptance Criteria**
- Search text filters current expense list.
- Empty results show a clear empty state.

### User Story 2 - User Applies Advanced Filters (P1)
As a user, I filter expenses by date, category, amount, payment method, and currency.

**Acceptance Criteria**
- Filters can be combined.
- Filters can be reset.

## Functional Requirements

- Add `ExpenseFilter`.
- Add pure filter service.
- Add Expenses screen.
- Add search bar and filter sheet.
- Use date-scoped Firestore query plus local filtering first.

## Out Of Scope

- Complex Firestore composite index optimization.
- Saved filter presets.

## Success Metrics

- Filter service tests cover combined filters.
- Home `View All` opens filterable expenses list.

## Detailed Requirements And Edge Cases

- Local filtering must be deterministic and case-insensitive for text.
- Date filters must include the full end date, not stop at midnight.
- Category filtering should use `categoryId` first and name fallback only for legacy data.
- Reset filters must clear UI controls and filter state together.
- Do not add complex Firestore composite-index requirements until the UX is proven.
