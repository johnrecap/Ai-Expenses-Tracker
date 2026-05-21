# Feature Specification: Category Management

**Feature Branch**: `004-category-management`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Can Manage Categories (P1)
As a user, I can create and edit my categories so expense entry remains accurate.

**Acceptance Criteria**
- Create category works.
- Edit category name, icon, and color works.
- Categories are user-scoped.

### User Story 2 - Used Categories Are Archived Instead Of Deleted (P2)
As a user, old expenses should keep rendering even if a category is no longer active.

**Acceptance Criteria**
- Archive hides a category from Add Expense.
- Existing expenses keep category snapshot display.

## Functional Requirements

- Split category repository from expense repository.
- Add `isArchived`, `createdAt`, `updatedAt`.
- Add Categories screen.
- Replace one-off dialog with reusable category form.
- Validate name, icon, and color.

## Out Of Scope

- Category budgets.
- Nested categories.

## Success Metrics

- Active categories appear in Add Expense.
- Archived categories are hidden from creation flows but old expenses render.

## Detailed Requirements And Edge Cases

- Categories used by expenses must be archived, not hard-deleted.
- Add Expense must only list active categories.
- Existing expense rows must continue to render from category snapshot even after archive.
- Category form must validate name, icon, and color before dispatch.
- Category repository must be user-scoped and must not read global `categories`.
