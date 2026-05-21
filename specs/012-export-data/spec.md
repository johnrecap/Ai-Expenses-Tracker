# Feature Specification: Export Data

**Feature Branch**: `012-export-data`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Exports Expenses By Period (P1)
As a user, I choose a period and export my expenses.

**Acceptance Criteria**
- Date range is required.
- Export rows match selected filters.

### User Story 2 - User Chooses File Format (P1)
As a user, I export CSV, Excel, or PDF.

**Acceptance Criteria**
- CSV, Excel, and PDF are generated.
- User can save or share the generated file.

## Functional Requirements

- Add export service interface.
- Add CSV exporter.
- Add Excel exporter.
- Add PDF exporter.
- Add Export screen and Cubit.

## Out Of Scope

- Cloud backup.
- Scheduled export emails.

## Success Metrics

- CSV content tests pass.
- Exported files include date, amount, currency, category, payment method, and description.

## Detailed Requirements And Edge Cases

- Export must respect date range and filters.
- CSV must escape commas, quotes, and newlines.
- PDF must remain readable when descriptions are long.
- Excel export should use one sheet named `Expenses`.
- UI must show export failure messages instead of silently failing.
