# Quickstart: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

## 1. Review Current Deferred Backlog

Open:

```powershell
Get-Content docs\implementation_plans\deferred-and-advanced-work.md
```

Confirm it includes:

- Old Speckit status cleanup as a near-term project maintenance item.
- Home navigation tests and Settings widget tests.
- Arabic PDF font already added, with visual/manual PDF QA still deferred.

## 2. Audit Historical Open Tasks

List unchecked tasks:

```powershell
rg -n "^- \[ \] T" specs -g tasks.md
```

For each task, classify it:

- `complete`: newer plan/test/file proves it is done.
- `superseded`: newer plan handled the same scope differently.
- `blocked`: real device, Firebase deploy, keystore, AdMob, Play Store, billing, or production credential required.
- `open`: still actionable locally.

Update task files with concise evidence notes. Do not delete old specs.

## 3. Add Home Widget Navigation Tests

Target paths:

```text
test/home/
test/helpers/
lib/screens/home/
```

Cover at least:

- Home View All opens Expenses.
- Settings icon opens Settings or a testable settings route.
- Budget manage opens Budget.
- Retention prompt action opens the intended local flow.
- Logout/menu confirmation opens before sign-out where applicable.

Use fakes and provider wrappers. Do not initialize real Firebase or platform plugins.

## 4. Add Settings Widget Smoke Tests

Target paths:

```text
test/settings/
test/helpers/
lib/screens/settings/
```

Cover at least:

- Currency section renders and can trigger save through fake SettingsCubit/repository.
- Default payment section renders.
- Notification controls render without plugin calls.
- Security/AI/monetization/privacy/support sections render honest states.
- Support action states that expense data is not attached.

## 5. Verification

Run:

```powershell
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test --reporter expanded --concurrency=1 --timeout 45s test\home test\settings
C:\flutter\bin\flutter.bat test --reporter expanded --concurrency=1 --timeout 45s
```

If Flutter commands hang inside the sandbox, rerun through the approved external execution path and record that environment issue.

## 6. Update Status

After implementation:

- Mark completed tasks in `specs/040-spec-cleanup-tests-backlog/tasks.md`.
- Update old historical task files only when evidence is clear.
- Update `docs/implementation_plans/deferred-and-advanced-work.md` for any new deferred item discovered.
- Leave release/device/Firebase/AdMob/Play Store items deferred unless explicitly requested.
