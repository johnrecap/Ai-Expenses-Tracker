# Feature Specification: Verification Toolchain Stability

**Feature Branch**: `052-verification-toolchain-stability`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Flutter/Dart verification commands intermittently take minutes or hang during analyze, format, version checks, and targeted tests.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fail Fast On Toolchain Permission Problems (Priority: P1)

Developers must get a clear diagnostic when Flutter or Dart cannot write to required cache/telemetry paths instead of waiting on silent timeouts.

**Why this priority**: Current `flutter.bat`/`dart.bat` behavior can loop or fail after doing useful work, wasting every verification run.

**Independent Test**: Run the project diagnostic script in a restricted shell and verify it reports non-writable Flutter cache or Dart telemetry paths in under 10 seconds.

**Acceptance Scenarios**:

1. **Given** `C:\flutter\bin\cache` is not writable, **When** the diagnostic runs, **Then** it reports the Flutter batch lock risk and exits non-zero.
2. **Given** `%APPDATA%\.dart-tool` is not writable, **When** the diagnostic runs, **Then** it reports the Dart analytics/session write risk and suggests `--suppress-analytics` for direct Dart commands.

---

### User Story 2 - Provide Stable Verification Commands (Priority: P1)

The project must document and expose verification commands that do not accidentally trigger known hanging paths.

**Why this priority**: Agents and developers need one reliable command path for analyze, format, and targeted tests.

**Independent Test**: Run documented commands and confirm they either complete or fail fast with a specific cause.

**Acceptance Scenarios**:

1. **Given** only formatting is needed, **When** the safe format command runs, **Then** it uses Dart `--suppress-analytics`.
2. **Given** Flutter commands require SDK cache writes, **When** the environment is restricted, **Then** the runbook tells the operator to run the approved/escalated command or fix SDK cache permissions explicitly.

---

### User Story 3 - Keep Verification Runtime Bounded (Priority: P2)

Targeted tests must be split into bounded groups with timeouts and documented expected durations.

**Why this priority**: A single hanging test command currently hides whether the issue is startup, compilation, or a specific widget test.

**Independent Test**: Run each target group separately and record pass/fail/duration in the runbook.

**Acceptance Scenarios**:

1. **Given** a test group exceeds its timeout, **When** the wrapper exits, **Then** it prints the group name and next diagnostic step.
2. **Given** Flutter startup is healthy, **When** repository-only tests run, **Then** they finish separately from widget tests.

## Edge Cases

- Flutter SDK installed outside the writable workspace may require explicit user approval before ACL changes.
- Dart direct executable works while `dart.bat` hangs because the batch script calls Flutter shared cache locking.
- `flutter analyze --no-pub` can succeed through an approved prefix while `flutter --version` hangs in sandbox; diagnostics must distinguish those paths.
- System-level permission changes must not be applied silently from project scripts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Add a project diagnostic that checks write access to Flutter cache lock paths and Dart telemetry/session paths.
- **FR-002**: Add a verification runbook section explaining the observed root cause and safe command matrix.
- **FR-003**: Add a safe Dart formatting command that uses `--suppress-analytics`.
- **FR-004**: Document that Flutter batch commands require either a writable Flutter SDK cache or explicit approved/escalated execution.
- **FR-005**: Split targeted Flutter tests into small named groups with expected timeouts.
- **FR-006**: Update deferred/future work only for any system-level setup that cannot be completed inside the repo.
- **FR-007**: Do not change ACLs, install SDKs, or mutate global Flutter/Dart configuration without explicit user approval.

### Key Entities

- **Toolchain Diagnostic**: Script/report that identifies local permission and cache lock hazards.
- **Safe Verification Command**: Project-owned command path that fails fast and documents prerequisites.
- **Verification Group**: Small test command set with a bounded timeout and clear owner area.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Diagnostic completes in under 10 seconds on a restricted shell.
- **SC-002**: `dart format --version` equivalent succeeds when run with `--suppress-analytics`.
- **SC-003**: Flutter command prerequisites are reported before a command can silently hang on `flutter.bat.lock`.
- **SC-004**: Targeted test groups are documented so one hanging group does not block all verification context.

## Assumptions

- `C:\flutter` is the active SDK path in this environment.
- The repo should prefer non-mutating diagnostics over persistent machine ACL changes.
- If the user explicitly approves machine permission changes later, that work should be run as a separate, visible environment maintenance step.
