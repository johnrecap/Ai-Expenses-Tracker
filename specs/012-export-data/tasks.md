# Tasks: Export Data

## Implementation Intent

Export user expenses for a selected period in CSV, Excel, and PDF. Export should use existing repository/filter logic and should not query Firestore directly from UI widgets.

---

## Phase 1: Dependencies And Contracts

### T001 - Add Export Packages

**Files:** Modify `pubspec.yaml`.

**Steps:** Add `csv`, `pdf`, `printing`, `excel`, `path_provider`, `share_plus` if selected; run `flutter pub get`.

**Done When:** Packages resolve without conflicts.

### T002 - Create `ExportFormat`

**Files:** Create `lib/services/export/export_service.dart` or model file.

**Steps:** Define `csv`, `excel`, `pdf`.

**Done When:** UI can choose output format.

### T003 - Create `ExportRequest`

**Steps:** Include date range, optional category ids, currency, payment methods, and format.

**Done When:** Export can be requested with filters.

### T004 - Create `ExportService`

**Steps:** Define method to generate file bytes/path from expenses and request.

**Done When:** Export Cubit can call service interface.

---

## Phase 2: Exporters

### T005 - CSV Exporter

**Files:** Create `lib/services/export/csv_exporter.dart`.

**Steps:** Output headers date, amount, currency, category, paymentMethod, description; escape commas/new lines.

**Done When:** CSV opens correctly in spreadsheet tools.

### T006 - Excel Exporter

**Files:** Create `lib/services/export/excel_exporter.dart`.

**Steps:** Create one sheet `Expenses`; write same columns; apply basic date/amount formatting if package supports it.

**Done When:** `.xlsx` contains all filtered rows.

### T007 - PDF Exporter

**Files:** Create `lib/services/export/pdf_exporter.dart`.

**Steps:** Add title, period, total, table; handle long descriptions by wrapping/truncating cleanly.

**Done When:** PDF is readable on mobile.

### T008 - Save/Share Service

**Steps:** Use `share_plus` or platform-appropriate file save; isolate platform behavior from exporters.

**Done When:** User can share or save generated file.

---

## Phase 3: UI

### T009 - Create `ExportCubit`

**Files:** Create `lib/screens/export/cubit/export_cubit.dart`.

**Steps:** States: initial, loading, success(file), failure(message).

**Done When:** Export screen has state manager.

### T010 - Create `ExportScreen`

**Files:** Create `lib/screens/export/views/export_screen.dart`.

**Steps:** Include date range, format selector, optional filters, export button.

**Done When:** User can request export.

### T011 - Date Range Selector

**Steps:** Require start and end; validate start <= end.

**Done When:** Invalid periods cannot export.

### T012 - Format Selector

**Steps:** Let user choose CSV, Excel, PDF.

**Done When:** Correct exporter is called.

### T013 - Export States

**Steps:** Show loading, success with share action, and failure message.

**Done When:** Export UX is understandable.

---

## Phase 4: Tests

### T014 - CSV Tests

Verify headers, row count, escaped values.

### T015 - Filter Tests

Verify exported rows match requested date/category/payment filters.

### T016 - Manual QA

Generate each format and open/share it.

---

## Completion Checklist

- [x] T001 - Added export packages in `pubspec.yaml`: `csv`, `excel`, `pdf`, `path_provider`, and `share_plus`; dependency resolution succeeded with `flutter pub get`.
- [x] T002 - Created `ExportFormat` in `lib/services/export/export_service.dart` with CSV, Excel, and PDF labels, extensions, and MIME types.
- [x] T003 - Created `ExportRequest` with required date range, category ids, currency, payment methods, format, validation, and conversion to `ExpenseFilter`.
- [x] T004 - Created `ExportService`, `ExportResult`, and shared export row helpers for consistent row selection and file naming.
- [x] T005 - Created `CsvExportService` with headers and standards-based escaping for commas, quotes, and newlines.
- [x] T006 - Created `ExcelExportService` that writes one workbook sheet named `Expenses` with matching exported rows.
- [x] T007 - Created `PdfExportService` with title, period, totals, and a wrapped/truncated table layout for long descriptions.
- [x] T008 - Created `LocalExportFileSharer` to isolate temporary file save and `share_plus` sharing behavior from exporters.
- [x] T009 - Created `ExportCubit` with initial, loading, success, and failure states.
- [x] T010 - Created `ExportScreen` and linked it from Home through an export action.
- [x] T011 - Added required date range selector and validation before export.
- [x] T012 - Added segmented CSV/Excel/PDF format selector.
- [x] T013 - Added loading, success, share action, saved path display, and failure messages.
- [x] T014 - Added CSV tests for headers, row count behavior, file metadata, and escaping of commas, quotes, and newlines.
- [x] T015 - Added export filter tests for date, category, payment method, and currency selection.
- [ ] T016 - Manual QA remains pending: generate CSV, Excel, and PDF from a real app runtime and open/share each generated file.

## Verification Status

- Coordinator verification completed for implementation with `flutter pub get`, targeted export tests, and `flutter analyze`.
- Full-project verification must still run before final completion reporting.
