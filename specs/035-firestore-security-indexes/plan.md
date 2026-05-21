# Implementation Plan: Firestore Security And Indexes

**Branch**: `035-firestore-security-indexes` | **Date**: 2026-05-18 | **Spec**: `specs/035-firestore-security-indexes/spec.md`  
**Input**: Security and reliability gaps from the audit: broad user subtree rule, missing schema validation, no `firestore.indexes.json`, and no rules emulator workflow.

## Summary

Tighten Firestore rules from broad subtree access to collection-specific validation, add required composite indexes for repository query patterns, and create a repeatable emulator verification workflow.

## Technical Context

**Language/Version**: Firebase Security Rules v2, Dart 3.x/Flutter for repository context  
**Primary Dependencies**: Firebase CLI/emulator, Firestore, existing repository package  
**Storage**: Firestore `users/{userId}` subcollections only  
**Testing**: Firestore rules emulator tests plus existing Flutter repository tests  
**Target Platform**: Firebase backend used by Flutter app  
**Project Type**: Mobile app with Firebase backend rules  
**Performance Goals**: Avoid missing-index runtime failures and keep queries conservative  
**Constraints**: Preserve user isolation; support offline valid writes; keep legacy global paths denied  
**Scale/Scope**: `firestore.rules`, `firestore.indexes.json`, rules tests/docs

## Constitution Check

- All authenticated production data must stay under `users/{userId}`.
- Global `expenses` and `categories` must not be extended.
- Expense filtering remains conservative: date-scoped Firestore reads plus local deterministic filtering.
- Firestore serialization stays in repository entity/model layers.
- Verification should include rules tests when rules change.

## Project Structure

```text
firestore.rules
firestore.indexes.json
firebase.json
test/firestore_rules/ or functions/rules-tests/
docs/firebase/
packages/expense_repository/lib/src/
```

**Structure Decision**: Keep rules and indexes at project root so Firebase CLI can deploy them through `firebase.json`; keep tests/documentation close to Firebase configuration.

## Implementation Notes

- Start with helper functions: signed-in check, user path check, allowed keys, positive number, timestamp/date checks, currency code checks, month id checks.
- Validate creates and updates separately where created/updated timestamps differ.
- Declare indexes only for actual repository queries found in `packages/expense_repository`.
- Emulator tests should cover allow and deny paths, not every UI flow.

## Risks

- Over-strict rules can break existing documents. Mitigation: validate writes strictly but keep reads path-authenticated for existing user-owned data where necessary.
- Missing index list can be incomplete. Mitigation: scan repository queries and run emulator/manual query flows.
- Emulator setup may require npm/firebase-tools. Mitigation: document exact install/run commands.
