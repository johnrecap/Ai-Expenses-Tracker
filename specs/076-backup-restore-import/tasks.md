# Tasks: Backup Restore Import

**Input**: `specs/076-backup-restore-import/spec.md`, `plan.md`

## Phase 1: Backup Contract

- [X] T001 Define backup schema and `BackupManifest` in `lib/services/backup/`.
  - **Why**: Restore needs versioned data.
  - **Benefit**: Enables safe future migrations.
  - **Expected**: Manifest includes schema version, app version, timestamp, collections, counts, and warnings.

- [X] T002 Document excluded sensitive fields in `docs/privacy/backup-data.md`.
  - **Why**: Backup must not include secrets.
  - **Benefit**: Protects privacy and trust.
  - **Expected**: Auth tokens, PIN data, provider keys, and raw secret fields are explicitly excluded.

## Phase 2: Export Backup

- [X] T003 [US1] Implement backup serializer for supported collections.
  - **Why**: User needs full app-data portability.
  - **Benefit**: Backup includes more than report exports.
  - **Expected**: Expenses, categories, budgets, recurring, saving goals, settings, and aliases are included if approved.

- [ ] T004 [US1] Add backup export entry point in Settings/Privacy.
  - **Why**: Data ownership belongs in privacy/settings.
  - **Benefit**: User can find backup feature.
  - **Expected**: User initiates backup and shares/saves file.

- [X] T005 Add serialization tests with fixture data.
  - **Why**: Backup correctness must be proven.
  - **Benefit**: Prevents missing collections.
  - **Expected**: Manifest counts and serialized data match fixtures.

## Phase 3: Restore Preview

- [X] T006 [US2] Implement backup parser and schema validator.
  - **Why**: Corrupt/incompatible files must not write data.
  - **Benefit**: Protects existing data.
  - **Expected**: Invalid files are rejected before preview.

- [X] T007 [US2] Implement `RestorePreview` and conflict detection.
  - **Why**: User must know what will happen before restore.
  - **Benefit**: Prevents silent overwrites and duplicates.
  - **Expected**: Preview shows add/update/skip/conflict counts.

- [ ] T008 [US2] Add restore confirmation UI.
  - **Why**: Restore is a destructive/high-impact action.
  - **Benefit**: Keeps user in control.
  - **Expected**: No writes occur before explicit confirmation.

## Phase 4: Restore Execution

- [ ] T009 [US2] Implement repository-backed restore execution with conflict policy.
  - **Why**: Writes must go through repository boundaries.
  - **Benefit**: Preserves user ownership and testability.
  - **Expected**: Add/skip/update policy is applied as selected.

- [ ] T010 Add restore round-trip tests.
  - **Why**: Backup without restore confidence is incomplete.
  - **Benefit**: Proves data portability.
  - **Expected**: Export then preview/restore recreates supported data in fake repos.

## Phase 5: Localization And Verification

- [ ] T011 Add ARB keys for backup, restore, preview, conflicts, warnings, and confirmation.
  - **Why**: New UI copy must be localized.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: Matching keys exist.

- [ ] T012 Run `flutter gen-l10n`.
  - **Why**: New keys require generated getters.
  - **Benefit**: Catches ARB errors.
  - **Expected**: Generation succeeds.

- [ ] T013 Run backup/restore tests and `flutter analyze --no-pub`.
  - **Why**: Data portability is high risk.
  - **Benefit**: Confirms no static or fixture failures.
  - **Expected**: Targeted tests and analyzer pass.
