# Feature Specification: Backup Restore Import

**Feature Branch**: `076-backup-restore-import`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested future planning for backup/restore/import after the first stable release.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Export A Complete Backup (Priority: P3)

As a user, I need to export a complete backup of my app data so I am not locked in.

**Why this priority**: Finance users value data ownership.

**Independent Test**: User exports a backup file containing supported user-owned finance data.

**Acceptance Scenarios**:

1. **Given** user has expenses, categories, budgets, recurring rules, and settings, **When** backup runs, **Then** the backup includes supported data with schema version.
2. **Given** backup fails, **When** error appears, **Then** original app data remains unchanged.

---

### User Story 2 - Restore Or Import Safely (Priority: P3)

As a user, I need to import data without corrupting existing records or creating duplicates silently.

**Why this priority**: Bad restore can destroy trust permanently.

**Independent Test**: Restore preview shows counts, conflicts, duplicates, and requires confirmation before writes.

**Acceptance Scenarios**:

1. **Given** a backup file, **When** user previews restore, **Then** app shows what will be added/updated/skipped.
2. **Given** duplicates are detected, **When** restore proceeds, **Then** user-selected conflict policy is applied.

## Edge Cases

- Old backup schema version.
- Corrupt file.
- Different user ID.
- Duplicate IDs.
- Missing categories for expenses.
- Mixed currency rates in backup.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Backup MUST include schema version and supported collections.
- **FR-002**: Restore/import MUST show a preview before any write.
- **FR-003**: Restore/import MUST never silently overwrite existing data.
- **FR-004**: Import MUST validate ownership and schema compatibility.
- **FR-005**: Conflict policy MUST be explicit.
- **FR-006**: Backup files MUST not include auth tokens, provider secrets, PIN data, or AI provider keys.

### Key Entities

- **BackupManifest**: Schema version, exported collections, counts, created date, and app version.
- **RestorePreview**: Add/update/skip/conflict counts and warnings.
- **ImportConflict**: Existing item, incoming item, conflict reason, and resolution.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Backup/restore round-trip preserves supported finance data in tests.
- **SC-002**: 100% of restore writes require preview and confirmation.
- **SC-003**: Corrupt/incompatible files are rejected without writing data.
- **SC-004**: No sensitive auth/PIN/provider secret fields appear in backup fixtures.

## Assumptions

- This is a post-stable P3 feature.
- Initial backup format can be JSON plus existing export formats remain separate.

