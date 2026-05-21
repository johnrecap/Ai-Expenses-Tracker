# Implementation Plan: Category Budgets And Subscription Center

**Branch**: `033-category-budgets-subscriptions` | **Date**: 2026-05-17 | **Spec**: `specs/033-category-budgets-subscriptions/spec.md`  
**Input**: Add category-level budgets and a subscription center on top of existing budget, category, expense, recurring, and notification systems.

## Summary

Introduce user-scoped category budgets, calculate category progress from expenses, add a subscription center based on active recurring expenses, and optionally schedule local alerts. This extends existing finance features without adding a new backend beyond Firebase.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing repository package, Bloc/Cubit, Firestore, notification services  
**Storage**: Firestore under `users/{userId}/category_budgets`; existing recurring expense path  
**Testing**: Repository tests, calculator tests, Cubit tests, widget tests, notification scheduler tests  
**Target Platform**: Flutter app, Android priority  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: Category progress computed from date-scoped expense lists without heavy queries  
**Constraints**: User-scoped data only; no mixed-currency totals without warning; archived categories/rules ignored  
**Scale/Scope**: Category budget models/repository/screen widgets, subscription center, optional alerts

## Constitution Check

- User-owned data must be stored under `users/{userId}`.
- Category reads/writes are owned by `CategoryRepository`.
- Monthly budget work uses repository/calculator services, not stored counters.
- Recurring expense rules use `RecurringExpenseRepository`; generated past expenses must not be modified on archive.
- Mixed-currency calculations must not add incompatible currencies.

## Project Structure

```text
packages/expense_repository/lib/src/
|-- models/
|-- entities/
`-- repositories/

lib/screens/category_budgets/
lib/screens/subscriptions/
lib/services/notifications/
test/category_budgets/
test/subscriptions/
```

**Structure Decision**: Add category budget models/repository to `packages/expense_repository` like existing budget/goal models. Add UI under feature-specific `lib/screens` folders.

## Implementation Notes

- Use deterministic document id pattern such as `{yyyy-MM}_{categoryId}_{currency}` if it matches existing style.
- Category budgets should archive/remove without deleting historical expense data.
- Subscription center should read recurring rules, not infer from AI unless a later plan adds detection.
- Alerts should be local and optional.

## Risks

- Category archive changes can orphan budgets. Mitigation: show archived label or stop active warnings.
- Mixed currencies can mislead users. Mitigation: currency-specific budgets and warnings.
- Recurring rule next-date math can be tricky. Mitigation: reuse existing scheduler/date logic.
