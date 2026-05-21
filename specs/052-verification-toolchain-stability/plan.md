# Implementation Plan: Verification Toolchain Stability

**Branch**: `052-verification-toolchain-stability` | **Date**: 2026-05-18 | **Spec**: `specs/052-verification-toolchain-stability/spec.md`  
**Input**: Investigation of slow/hanging Flutter/Dart verification commands.

## Summary

Add project-owned diagnostics and verification runbooks so Flutter/Dart command hangs are identified before long timeouts. The confirmed local issue is permission-related: sandboxed commands cannot write to `C:\flutter\bin\cache` lock files, and Dart analytics cannot update `%APPDATA%\.dart-tool` session files. The plan avoids silent machine permission changes and provides explicit safe commands and escalation points.

## Technical Context

**Language/Version**: PowerShell, Dart 3.11.3, Flutter SDK at `C:\flutter`  
**Primary Dependencies**: Existing Flutter/Dart SDK, project `flutter analyze`, `flutter test`, `dart format`  
**Storage**: Project scripts/docs only; no production data changes  
**Testing**: Diagnostic script dry runs, analyze command, split targeted Flutter tests  
**Target Platform**: Windows development environment under Codex sandbox and local user shell  
**Project Type**: Developer tooling reliability  
**Performance Goals**: Toolchain preflight under 10 seconds; no silent 4-10 minute hangs from known permission issues  
**Constraints**: No global ACL/config mutation without explicit approval; preserve Spec Kit workflow  
**Scale/Scope**: `tools/verification`, `docs/qa`, Spec Kit task tracking

## Constitution Check

- Verification reliability is a prerequisite for safe changes.
- Machine-level permission changes are treated as explicit operational work, not hidden implementation.
- Spec Kit artifacts are used for this bug-fix plan.

**Gate Status**: PASS.

## Root Cause Evidence

- `C:\flutter\bin\cache\flutter.bat.lock` and `C:\flutter\bin\cache\lockfile` cannot be opened for write in the sandbox.
- `flutter.bat` uses a retry loop around `9> "%cache_dir%\flutter.bat.lock"`, which can hang silently when the lock cannot be opened.
- Direct `dart.exe --version` completes quickly, but Dart CLI commands without `--suppress-analytics` fail while updating `%APPDATA%\.dart-tool\dart-flutter-telemetry-session.json`.
- `dart.exe --suppress-analytics format --version` succeeds quickly.

## Project Structure

```text
tools/verification/diagnose_toolchain.ps1
tools/verification/safe_dart_format.ps1
docs/qa/flutter-verification-runbook.md
docs/implementation_plans/deferred-and-advanced-work.md
specs/052-verification-toolchain-stability/
```

**Structure Decision**: Keep scripts under `tools/verification` and document the operational fix in the QA runbook. Do not mutate global SDK or AppData permissions from these scripts.

## Implementation Notes

- Diagnostic script should check:
  - Flutter SDK path and cache path existence.
  - Write/open access to `flutter.bat.lock` and `lockfile`.
  - Write access to `%APPDATA%\.dart-tool`.
  - Direct `dart.exe --version` availability.
  - Safe Dart analytics suppression path.
- Safe format script should call `dart.exe --suppress-analytics format` and accept explicit file/path arguments.
- Flutter analyze/test commands should remain normal Flutter commands but must be preceded by diagnostics in restricted shells.
- If SDK cache is not writable, the runbook should require either explicit approved execution outside the sandbox or a user-approved ACL repair.

## Verification

```text
powershell -ExecutionPolicy Bypass -File tools/verification/diagnose_toolchain.ps1
powershell -ExecutionPolicy Bypass -File tools/verification/safe_dart_format.ps1 -- --version
flutter analyze --no-pub
flutter test --no-pub test/repository --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/expenses --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/home --reporter expanded --concurrency=1 --timeout 45s
```

## Deferred Items To Keep In Mind

The existing Verification Follow-Up item about Dart telemetry permissions remains relevant. A machine-level ACL repair for `C:\flutter\bin\cache` and `%APPDATA%\.dart-tool` requires explicit user approval and should be handled as environment maintenance.

## Complexity Tracking

No constitution violations. The only external-risk item is a possible machine ACL change, kept out of automatic scripts.
