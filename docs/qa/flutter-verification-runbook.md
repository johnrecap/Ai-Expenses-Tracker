# Flutter verification runbook

This runbook supports Spec Kit plans `045-flutter-verification-baseline` and
`052-verification-toolchain-stability`.
It is for restoring and recording a reliable local Flutter verification
baseline on Windows when Flutter commands hang, especially after stuck
`git.exe`, `flutter.exe`, or `dart.exe` child processes.

## Current run status

| Field | Value |
| --- | --- |
| Spec | `specs/045-flutter-verification-baseline/`, `specs/052-verification-toolchain-stability/` |
| Worker pass | Toolchain diagnostic update |
| Date | 2026-05-18 |
| Commands executed in this pass | `flutter analyze --no-pub`, `tools/verification/diagnose_toolchain.ps1`, `tools/verification/safe_dart_format.ps1 -- --version` |
| Baseline result | Analyzer passed; Flutter/Dart wrapper startup remains environment-blocked in restricted sandbox without approved execution or SDK/AppData permission repair |

Record actual command results in this table when the parent run is allowed to
execute verification commands.

| Step | Command | Result | Classification | Notes |
| --- | --- | --- | --- | --- |
| Process state | `Get-Process flutter,dart,git -ErrorAction SilentlyContinue` | Pass | Diagnostic | No active Flutter/Dart/Git process remained after timeout runs. |
| Lockfile state | `Get-ChildItem -Path C:\flutter\bin\cache -Force | Where-Object { $_.Name -like "*.lock" -or $_.Name -like "lockfile" }` | Pass | Diagnostic | Lock files exist; restricted shell cannot open them for write. |
| Dart version | `C:\flutter\bin\cache\dart-sdk\bin\dart.exe --version` | Pass | Diagnostic | Direct Dart SDK responds quickly. |
| Flutter SDK Git state | `git -C C:\flutter status --short` | Pending | Not run | Confirms whether SDK Git responds. |
| Flutter version | `flutter --version` | Timeout | Toolchain hang | Restricted shell cannot write Flutter cache lock path; use diagnostic first. |
| Dependencies | `flutter pub get` | Pending | Not run | Classify network/sandbox failures separately from hangs. |
| Analyzer | `flutter analyze --no-pub` | Pass | Analyzer | Completed with no issues after code fixes. |
| Smoke test | `flutter test --no-pub test/widget_test.dart --reporter expanded --concurrency=1 --timeout 45s` | Pending | Not run | Smallest app test batch. |
| Settings/onboarding tests | See "Incremental test batches" | Pending | Not run | Current settings persistence surfaces. |
| Guided tour/home tests | See "Incremental test batches" | Pending | Not run | Suites referenced in prior verification notes. |
| Full suite | `flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s` | Pending | Not run | Final baseline after targeted batches pass or fail clearly. |

## Evidence-first diagnostics

Start with the project diagnostic added by plan 052:

```powershell
powershell -ExecutionPolicy Bypass -File tools/verification/diagnose_toolchain.ps1
```

This command must complete quickly. If it reports non-writable
`C:\flutter\bin\cache\flutter.bat.lock`, `C:\flutter\bin\cache\lockfile`, or
`%APPDATA%\.dart-tool`, do not keep retrying raw `flutter.bat` or `dart.bat`
commands inside the restricted shell. They can wait on batch lock acquisition
or fail after analytics writes.

Run diagnostics before terminating processes or removing locks. Use bounded
command execution from the parent shell or task runner so a hung command does
not block the session indefinitely.

```powershell
Get-Process flutter,dart,git -ErrorAction SilentlyContinue |
  Select-Object ProcessName,Id,StartTime,Path
```

Record any process that predates the current verification attempt. A stale
process is evidence only when its timing and parent command match the failed
Flutter run or when it remains after the terminal that launched it has exited.

```powershell
Get-ChildItem -Path C:\flutter\bin\cache -Force |
  Where-Object { $_.Name -like "*.lock" -or $_.Name -like "lockfile" } |
  Select-Object FullName,Length,LastWriteTime
```

This is read-only. Do not delete anything during this step.

```powershell
C:\flutter\bin\cache\dart-sdk\bin\dart.exe --version
```

If direct Dart responds while `flutter --version` hangs, the failure is likely
in Flutter wrapper startup, SDK Git access, cache locking, or child process
management rather than the Dart executable itself.

```powershell
git -C C:\flutter status --short
```

If SDK Git hangs or reports a repository problem, classify subsequent Flutter
hangs as a toolchain environment issue until SDK Git is responsive.

## Command ladder

Run commands in this order after diagnostics are captured. Stop at the first
hang and use the recovery decision rules before continuing.

```powershell
powershell -ExecutionPolicy Bypass -File tools/verification/diagnose_toolchain.ps1
powershell -ExecutionPolicy Bypass -File tools/verification/safe_dart_format.ps1 -- --version
flutter --version
flutter pub get
flutter analyze --no-pub
flutter test --no-pub test/widget_test.dart --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s
```

Classify each result as one of:

- `pass`: command completed successfully.
- `assertion failure`: Flutter test completed and named a failing assertion.
- `analyzer failure`: analyzer completed and reported diagnostics.
- `timeout`: command reached the explicit timeout and exited or was stopped.
- `toolchain hang`: command did not produce a bounded result and left
  Flutter/Dart/Git child processes behind.
- `external dependency issue`: network, sandbox, Firebase, emulator, or
  credential dependency prevented completion.

## Safe command matrix

Use this matrix when running verification from Codex or another restricted
shell.

| Task | Preferred command | Notes |
| --- | --- | --- |
| Toolchain preflight | `powershell -ExecutionPolicy Bypass -File tools/verification/diagnose_toolchain.ps1` | Fails fast on known Flutter cache and Dart telemetry permission issues. |
| Dart format | `powershell -ExecutionPolicy Bypass -File tools/verification/safe_dart_format.ps1 -- <paths>` | Uses direct `dart.exe --suppress-analytics format` to avoid AppData telemetry failure. |
| Analyzer | `flutter analyze --no-pub` | Requires writable Flutter SDK cache or approved/escalated execution outside the restricted sandbox. |
| Flutter tests | `flutter test --no-pub <group> --reporter expanded --concurrency=1 --timeout 45s` | Run only after preflight passes or an approved shell is used. |
| Flutter version | `flutter --version` | Do not use as a health check in a restricted shell if preflight fails; it may hang on the batch lock. |

The direct Dart executable can prove the SDK exists:

```powershell
C:\flutter\bin\cache\dart-sdk\bin\dart.exe --version
```

This does not prove `flutter.bat` is safe, because Flutter also needs write
access to SDK cache lock files.

## Incremental test batches

Use targeted batches before the full suite so failures are tied to named files.
Adjust file names only after listing available tests in the relevant folders.

| Batch | Purpose | Command |
| --- | --- | --- |
| Smoke | Confirms the test runner can start one app test | `flutter test --no-pub test/widget_test.dart --reporter expanded --concurrency=1 --timeout 45s` |
| Repository/services | Covers model parsing, repository contracts, exports, reports, formatter helpers | `flutter test --no-pub test/add_expense/amount_parser_test.dart test/repository test/export test/reports test/settings/currency_formatter_test.dart --reporter expanded --concurrency=1 --timeout 45s` |
| Expenses | Covers filters, edit/delete, decimal amounts, and list pagination UI | `flutter test --no-pub test/expenses --reporter expanded --concurrency=1 --timeout 45s` |
| Settings/onboarding | Covers settings persistence, first-run setup, and app language/currency surfaces | `flutter test --no-pub test/settings test/onboarding test/auth/auth_gate_test.dart --reporter expanded --concurrency=1 --timeout 45s` |
| Guided tour/home | Rechecks suites previously called out in verification notes | `flutter test --no-pub test/guided_tour test/home --reporter expanded --concurrency=1 --timeout 45s` |
| AI targeted | Rechecks decimal AI payload parsing and assistant command behavior | `flutter test --no-pub test/ai/ai_response_parser_test.dart test/ai/ai_assistant_cubit_test.dart --reporter expanded --concurrency=1 --timeout 45s` |
| Full suite | Establishes the final project baseline | `flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s` |

If a targeted path does not exist, record it as `external dependency issue` or
`not applicable` with the missing path, then run the nearest existing targeted
test file for that feature area.

## Known Windows Flutter hang recovery

Use this section only after diagnostics show a real hang or stale state. The
goal is to clear only the process or lock that is blocking the current
verification attempt.

### Cleanup decision rules

Stale lock removal is allowed only when all of these are true:

- The lock is under `C:\flutter\bin\cache`.
- Diagnostics captured the lock path and `LastWriteTime`.
- No active `flutter.exe` or `dart.exe` process from a legitimate current
  command is using the SDK.
- The parent/operator has approved cleanup for this local SDK path.

Process termination is allowed only when all of these are true:

- The process is `flutter.exe`, `dart.exe`, or `git.exe`.
- The process was created by the failed verification attempt, or it is clearly
  a stale child left behind by an earlier Flutter command.
- The process ID was recorded before termination.
- The command is narrowly targeted by process ID.

Use a targeted command shape like this after approval:

```powershell
Stop-Process -Id <recorded-process-id> -Force
```

Do not use broad process-name termination unless every matching process has
been individually identified as part of the failed verification attempt.

If a stale lock has been verified and approved for removal, use the exact path:

```powershell
Remove-Item -LiteralPath "C:\flutter\bin\cache\<verified-lock-file>" -Force
```

Do not remove directories, SDK cache contents, build outputs, or source files.

### When to stop and ask for manual approval

Stop and ask for approval when:

- A cleanup target is outside `C:\flutter\bin\cache`.
- The process owner or purpose is unclear.
- The stale process is not clearly linked to Flutter verification.
- Multiple terminals, IDEs, or other workers may be running Flutter commands.
- `git -C C:\flutter status --short` reports SDK repository corruption.
- Network, Firebase, emulator, or credential setup is needed to proceed.
- A proposed fix changes ACLs under `C:\flutter` or `%APPDATA%`; this is
  machine-level maintenance and must be explicitly approved by the user.

## Do not do

- Do not delete `C:\flutter`, `C:\flutter\bin\cache`, `.dart_tool`, `build`,
  platform folders, user data, or generated files to fix a hang.
- Do not run `Stop-Process -Name git -Force`, `Stop-Process -Name flutter -Force`,
  or similar broad kills without narrowing to verified process IDs.
- Do not treat a network or sandbox failure from `flutter pub get` as an app
  regression.
- Do not update `.specify/memory/constitution.md` verification baselines until
  fresh command evidence exists.
- Do not mix real app test failures into this toolchain recovery plan; create
  or update a separate Spec Kit feature if a named app regression is found.
