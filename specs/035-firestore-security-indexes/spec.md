# Feature Specification: Firestore Security And Indexes

**Feature Branch**: `035-firestore-security-indexes`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Harden Firestore rules, add required indexes, and add emulator verification for user-scoped production data.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Protect User Data With Strict Rules (Priority: P1)

As a signed-in user, I need assurance that only I can read or write my expenses, categories, budgets, settings, AI logs, and related financial data.

**Why this priority**: The current rules isolate by user id but allow broad writes under each user document path without schema validation.

**Independent Test**: Firestore rules emulator denies cross-user access, denies global legacy collections, and denies malformed user-scoped documents.

**Acceptance Scenarios**:

1. **Given** user A is authenticated, **When** user A reads/writes `users/{userA}/expenses/{expenseId}`, **Then** the request is allowed only when required fields are valid.
2. **Given** user A is authenticated, **When** user A tries `users/{userB}/expenses/{expenseId}`, **Then** the request is denied.
3. **Given** any user writes to global `expenses` or `categories`, **When** rules evaluate, **Then** the request is denied.

---

### User Story 2 - Prevent Runtime Query Failures (Priority: P1)

As a user, I need search, recurring expense generation, AI logs, category aliases, and saving goals to load without Firestore missing-index failures.

**Why this priority**: Several repository queries use `where` plus `orderBy`; production Firestore can require composite indexes.

**Independent Test**: Repository query paths run against emulator or documented indexes without missing-index errors.

**Acceptance Scenarios**:

1. **Given** recurring expenses include active and archived records, **When** due recurring rules are queried, **Then** the query succeeds and returns only eligible records.
2. **Given** expenses are date-filtered, **When** the app applies date-scoped reads, **Then** the query succeeds and returns deterministic results.
3. **Given** saving goals or AI action logs exist, **When** sorted streams load, **Then** Firestore does not require an undeclared index.

---

### User Story 3 - Maintain A Rules Verification Workflow (Priority: P2)

As a future developer, I need repeatable commands and tests so security regressions are caught before deployment.

**Why this priority**: Rules without emulator tests regress easily when new collections are added.

**Independent Test**: A rules test suite can be run locally and fails if user isolation or schema validation is broken.

**Acceptance Scenarios**:

1. **Given** a new user-scoped collection is added later, **When** the developer updates rules, **Then** the rules tests describe allowed and denied access.
2. **Given** rules change, **When** tests run, **Then** cross-user access remains denied.

### Edge Cases

- Existing old documents may miss newer optional fields and should remain readable if already supported by entity parsing.
- Writes must reject negative amounts, invalid months, invalid currencies, and impossible ownership values.
- Offline local writes should still sync when valid.
- Rules should avoid depending on client-supplied fields for ownership when the path user id is authoritative.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Rules MUST allow access only when `request.auth.uid == userId` for every user-scoped collection.
- **FR-002**: Rules MUST reject writes to legacy global `expenses` and `categories`.
- **FR-003**: Rules MUST validate required fields and safe types for expenses, categories, budgets, category budgets, recurring expenses, saving goals, settings, AI action logs, and category aliases.
- **FR-004**: Rules MUST preserve read compatibility for existing valid user documents.
- **FR-005**: The project MUST include `firestore.indexes.json` for required repository queries.
- **FR-006**: The project MUST include local rules tests or documented emulator scripts that prove allowed and denied scenarios.
- **FR-007**: Deployment documentation MUST include commands to deploy rules and indexes.

### Key Entities

- **FirestoreRuleSet**: Access and validation rules for all user-scoped collections.
- **FirestoreIndexSet**: Composite indexes required by repository query patterns.
- **RulesTestCase**: Emulator-backed test that proves allowed/denied access for a collection and scenario.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Cross-user read/write attempts are denied for 100% of user-scoped collections in emulator tests.
- **SC-002**: Malformed writes are denied for all financial collections covered by rules.
- **SC-003**: All current repository Firestore queries have declared indexes or documented proof they do not need one.
- **SC-004**: A developer can run rules/index verification locally using documented commands.

## Assumptions

- Firestore remains the only production database for app data.
- User-scoped paths under `users/{userId}` remain the source of truth.
- Some validations will be conservative and may need updates when new fields are added.
