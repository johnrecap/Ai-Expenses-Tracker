# Feature Specification: Cleanup Dead Code And Assets

**Feature Branch**: `029-cleanup-dead-code-assets`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found unused demo data, old category PNG assets, an unused chart wrapper, unused dependency risk, and legacy Firebase Functions code that may confuse future workers.

## User Scenarios & Testing

### User Story 1 - Remove Unused App Artifacts (Priority: P1)

A developer can work in the app without being misled by unused data files, old assets, or dead widgets.

**Why this priority**: Dead code causes future workers to implement against the wrong path.

**Independent Test**: Search for each removal candidate and confirm no production reference remains before deleting.

**Acceptance Scenarios**:

1. **Given** old category PNG assets are unused, **When** cleanup is complete, **Then** category UI still renders through the icon registry.
2. **Given** demo transaction data is unused, **When** it is removed, **Then** app screens still use repository data.

---

### User Story 2 - Keep Useful Legacy Backend Context Clear (Priority: P2)

Future workers understand that `functions/` is optional legacy backend code and `workers/ai-gateway` is the current free AI path.

**Why this priority**: Deleting backend code blindly could lose useful future work, but leaving it undocumented creates confusion.

**Independent Test**: Read project docs and confirm the current AI backend path is unambiguous.

**Acceptance Scenarios**:

1. **Given** a worker needs AI gateway code, **When** they read docs, **Then** they choose `workers/ai-gateway`.
2. **Given** a worker sees `functions/`, **When** they read docs, **Then** they understand it is optional legacy/future code unless a plan targets it.

---

### User Story 3 - Dependency List Matches Usage (Priority: P3)

Dependencies in `pubspec.yaml` are used intentionally or removed.

**Why this priority**: Unused packages increase build risk and make the app harder to maintain.

**Independent Test**: Run import search and dependency validation before removing any package.

**Acceptance Scenarios**:

1. **Given** a dependency has no imports and no generated/platform requirement, **When** cleanup runs, **Then** it is removed and the app still analyzes.
2. **Given** a package is planned for future work but currently unused, **When** cleanup is reviewed, **Then** the decision is documented instead of accidental.

### Edge Cases

- Assets may be referenced by platform config, README, or tests even if not in `lib`.
- `functions/` may have package-lock/build files that should stay if future backend work is planned.
- Removing dependencies can require lockfile updates and platform rebuild checks.

## Requirements

### Functional Requirements

- **FR-001**: Cleanup MUST verify references with search before deleting files or dependencies.
- **FR-002**: Category icon cleanup MUST preserve `CategoryIconRegistry` and backward-compatible icon keys.
- **FR-003**: Demo data MUST not be used by production Home, Expenses, Reports, or Add Expense screens after cleanup.
- **FR-004**: Legacy backend code MUST be either retained with clear documentation or moved/archived by an explicit plan.
- **FR-005**: Removed assets MUST also be removed from `pubspec.yaml` asset declarations if listed individually.
- **FR-006**: Dependency removal MUST be followed by `flutter pub get`, `flutter analyze`, and relevant tests.

### Key Entities

- **Removal Candidate**: File, asset, dependency, or widget suspected unused.
- **Retention Decision**: Documented reason to keep a legacy artifact.
- **Cleanup Verification**: Search and build/analyze results proving removal is safe.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Every deleted file has a recorded no-reference search result.
- **SC-002**: `flutter analyze` passes after cleanup.
- **SC-003**: Category screens render without old PNG assets.
- **SC-004**: Future workers can identify current AI backend path in under 1 minute from docs.

## Assumptions

- `assets/logo.png` remains in use and must not be removed.
- Category icons should be rendered through `CategoryIconRegistry`.
- `functions/` is retained unless a separate archival plan is approved.
