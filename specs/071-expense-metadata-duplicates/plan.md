# Implementation Plan: Expense Metadata And Duplicate Detection

**Branch**: `071-expense-metadata-duplicates` | **Date**: 2026-05-20 | **Spec**: `specs/071-expense-metadata-duplicates/spec.md`

## Summary

Expand expense usefulness with merchant/tags/attachments metadata and add deterministic duplicate warnings before saving manual, AI, or receipt drafts. This plan prioritizes warning and searchability over aggressive automation.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `expense_repository`, Add Expense, Expenses filters, Export, AI draft flow  
**Storage**: Firestore expense documents; optional attachment references only in MVP  
**Testing**: Model/entity/rules tests, duplicate service tests, Add Expense tests  
**Target Platform**: Flutter mobile  
**Project Type**: Finance data model and UX improvement  
**Performance Goals**: Duplicate detection over loaded recent expenses should be fast and local  
**Constraints**: No silent blocking/deletion; preserve backward compatibility with old expense docs  
**Scale/Scope**: Current user's recent/date-scoped expenses

## Constitution Check

- Firestore serialization in entities/models: PASS.
- User-owned data only: PASS.
- AI draft remains confirm-first: PASS.
- No silent mutation: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/models/expense.dart
packages/expense_repository/lib/src/entities/expense_entity.dart
packages/expense_repository/lib/src/firebase_expense_repo.dart
firestore.rules
functions/test/firestoreRules.rules.ts
lib/screens/add_expense/
lib/screens/expenses/
lib/services/export/
lib/ai/
test/repository/
test/expenses/
test/add_expense/
```

## Implementation Strategy

1. Extend model/entity/rules for merchant/tags safely.
2. Add deterministic duplicate detection service.
3. Wire warning into Add Expense and AI/receipt draft save paths.
4. Add search/filter/export support for merchant/tags.
5. Treat full attachment storage as a scoped decision before implementation.

## Attachment MVP Policy

This implementation persists merchant and tags only. Attachment file storage,
cloud upload, searchable attachment content, and durable receipt history are
deferred because they require a dedicated storage, privacy, rules, and device QA
plan. Receipt capture can still fill the editable expense form, but this plan
does not persist receipt image paths or upload references on expenses.

## Risks

- Data model changes require Firestore rules updates. Mitigation: add rules tests.
- Duplicate false positives can annoy users. Mitigation: warn with reasons and allow save.

## Deferred Items Considered

Related future work: receipt history, searchable attachments, and cloud attachment storage may require a dedicated storage/security plan.
