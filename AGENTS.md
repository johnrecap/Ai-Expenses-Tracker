<!-- SPECKIT START -->
Current Spec Kit plan: specs/083-vps-pilot-cutover-readiness/plan.md

For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan above.

All future implementation plans, bug-fix plans, review follow-up plans,
feature plans, roadmap execution plans, and detailed planning requests must be
created as Spec Kit artifacts under `specs/<number>-<feature>/` with at least
`spec.md`, `plan.md`, and `tasks.md`. Do not create standalone executable plans
under `docs/`, `docs/superpowers/plans/`, or chat-only form unless the user
explicitly asks for read-only analysis rather than an implementation plan.

Before creating or updating any executable Spec Kit plan, run one consolidated
clarification pass with the user whenever scope, defaults, UX behavior, data
rules, backend/deployment setup, or verification expectations are ambiguous.
Ask all known questions at once, wait for the user's answer, then document the
answers or explicit assumptions inside the Spec Kit artifacts. Do not create
`spec.md`, `plan.md`, or `tasks.md` first and ask piecemeal questions later,
unless the user explicitly says to proceed with assumptions.

Persistent deferred/future work file: docs/implementation_plans/deferred-and-advanced-work.md

When the user asks to inspect bugs, propose new features, review changes, or
create a new plan, read the deferred/future work file too. In the response or
new Speckit plan, briefly remind the user which relevant deferred items from
that file should be considered later, without mixing them into the current
implementation unless the user explicitly asks for them.

If any new deferred, blocked, advanced, or later-stage task is discovered while
working, add it to the deferred/future work file automatically without waiting
for the user to ask. Keep each entry concise, group it under the most relevant
heading, and avoid duplicating an existing item. This applies whenever creating
plans, reviewing code, debugging, implementing features, running verification,
or finding a task that depends on external setup such as Firebase, Cloudflare,
Play Store, keystores, device QA, billing, ads, or production credentials.

Local Flutter/Dart verification constraint: in this Windows/Codex environment,
raw sandboxed `C:\flutter\bin\flutter.bat` commands can hang and leave orphaned
`git.exe` processes because Flutter writes SDK cache/lock state outside the
workspace. Run Flutter verification/build commands outside the sandbox with the
approved `C:\flutter\bin\flutter.bat` command path. For direct Dart CLI commands,
pass the global `--suppress-analytics` option before the Dart subcommand to avoid
the local telemetry-session access-denied failure. If orphaned Git metadata
processes remain, clean only `git.exe` processes whose command line contains
`core.hooksPath=NUL`, `core.fsmonitor=false`, and one of `rev-parse HEAD`,
`remote -v`, or `status --porcelain`.
<!-- SPECKIT END -->
