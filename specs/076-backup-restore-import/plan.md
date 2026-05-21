# Implementation Plan: Backup Restore Import

**Branch**: `076-backup-restore-import` | **Date**: 2026-05-20 | **Spec**: `specs/076-backup-restore-import/spec.md`

## Summary

Add a safe backup/restore/import flow with schema versioning, preview, conflict detection, and explicit confirmation. This is not a replacement for existing CSV/Excel/PDF export; it is a structured app-data portability feature.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing repositories, export/share packages, JSON serialization  
**Storage**: User-selected backup file; Firestore writes after restore confirmation  
**Testing**: Serialization tests, restore preview tests, repository fake tests  
**Target Platform**: Flutter mobile  
**Project Type**: Data portability feature  
**Performance Goals**: Backup/preview responsive for typical user data sizes  
**Constraints**: No secrets in backup; no silent overwrite; user-owned data only  
**Scale/Scope**: One user's supported collections

## Constitution Check

- User-owned data only: PASS.
- Firestore writes through repositories: PASS.
- No secrets exported: PASS.
- Preview before mutation: PASS.

## Project Structure

```text
lib/services/backup/
lib/screens/settings/
packages/expense_repository/
test/backup/
test/repository/
docs/privacy/
```

## Implementation Strategy

1. Define backup manifest and schema.
2. Add backup serializer for supported collections.
3. Add restore parser/validator/preview.
4. Add conflict resolution policy.
5. Add settings entry point and tests.

## Risks

- Restore bugs can corrupt data. Mitigation: preview, fake tests, and no silent overwrite.
- Large backups can be slow. Mitigation: start with typical data and add limits/progress.

## Deferred Items Considered

This can wait until after production trust, localization, and finance calculation consistency are stable.

