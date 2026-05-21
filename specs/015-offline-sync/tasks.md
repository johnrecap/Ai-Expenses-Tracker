# Tasks: Offline Mode And Sync Feedback

## Implementation Intent

Use Firestore offline capabilities where supported and make sync state visible. Do not build a custom local database unless Firestore behavior proves insufficient.

---

## Phase 1: Research And Model

### - [x] T001 - Confirm Firestore Offline Support

**Files:** Update `specs/015-offline-sync/plan.md` or add `research.md`.

**Steps:** Check current Firebase package behavior for Android, iOS, web, desktop; record platform limitations.

**Done When:** Offline assumptions are documented.

### - [x] T002 - Create `SyncStatus`

**Files:** Create `packages/expense_repository/lib/src/models/sync_status.dart` if UI needs it.

**Steps:** Define `pending`, `synced`, `failed`; map from Firestore metadata where possible.

**Done When:** UI has simple sync states.

### - [x] T003 - Decide On `connectivity_plus`

**Files:** Update plan/research and `pubspec.yaml` only if needed.

**Steps:** Use Firestore metadata first; add connectivity package only for explicit banner/offline detection.

**Done When:** Dependency choice is justified.

---

## Phase 2: Repository Integration

### - [x] T004 - Use Snapshot Metadata

**Files:** Modify stream methods in `FirebaseExpenseRepo`.

**Steps:** Enable metadata changes if supported; inspect `hasPendingWrites`.

**Done When:** Pending write status is observable.

### - [x] T005 - Map Pending Writes

**Steps:** Attach sync status to expense view model or expose metadata separately.

**Done When:** Expense row can show pending state.

### - [x] T006 - Avoid Immediate Server Assumption

**Steps:** After create expense, show success as locally queued if offline; do not require server round trip to update UI.

**Done When:** Offline add does not feel like failure.

---

## Phase 3: UI

### - [x] T007 - Sync Status Banner

**Files:** Create `lib/widgets/sync_status_banner.dart`.

**Steps:** Show offline/pending sync message when connectivity or metadata indicates it.

**Done When:** User understands offline state.

### - [x] T008 - Pending Indicator On Rows

**Files:** Modify expense row rendering in Home/Expenses screen.

**Steps:** Show subtle pending label/icon for unsynced expenses.

**Done When:** Pending expenses are distinguishable.

### - [x] T009 - Hide Pending After Sync

**Steps:** Update UI when metadata changes from pending to synced.

**Done When:** Indicator disappears automatically.

---

## Phase 4: Tests And QA

### - [ ] T010 - Sync Mapping Tests

Unit-test metadata-to-status mapping if abstracted.

### - [ ] T011 - Offline Add QA

Disable internet, add expense, confirm row appears pending.

### - [ ] T012 - Reconnect QA

Restore internet, confirm pending indicator clears and Firestore has one document.
