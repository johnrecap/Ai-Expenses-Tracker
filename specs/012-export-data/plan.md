# Implementation Plan: Export Data

## Technical Context

Export uses filtered expenses and report-style totals.

## Architecture

Create independent exporters for CSV, Excel, and PDF behind `ExportService`. UI collects date range and format.

## Files

- Modify: `pubspec.yaml`
- Create: `lib/services/export/export_service.dart`
- Create: `lib/services/export/csv_exporter.dart`
- Create: `lib/services/export/excel_exporter.dart`
- Create: `lib/services/export/pdf_exporter.dart`
- Create: `lib/screens/export/cubit/export_cubit.dart`
- Create: `lib/screens/export/views/export_screen.dart`

## Data Model

`ExportRequest`: date range, filters, format.

## Risks

- File save/share behavior differs per platform.
- PDF layout must handle long descriptions.

## Verification

- CSV unit tests.
- Date range filter tests.
- Manual export/share test.

## Detailed Execution Guidance

- Build exporters as services, not screen methods.
- Start with CSV because it is easiest to test.
- Reuse existing filter/date range logic.
- Keep file share/save platform behavior isolated.
- PDF and Excel should match CSV row selection.
