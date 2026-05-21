<!-- SPECKIT START -->
Current Spec Kit plan: specs/081-trust-release-hardening/plan.md

For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan above.

All future implementation plans, bug-fix plans, review follow-up plans,
feature plans, roadmap execution plans, and detailed planning requests must be
created as Spec Kit artifacts under `specs/<number>-<feature>/` with at least
`spec.md`, `plan.md`, and `tasks.md`. Do not create standalone executable plans
under `docs/`, `docs/superpowers/plans/`, or chat-only form unless the user
explicitly asks for read-only analysis rather than an implementation plan.

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
<!-- SPECKIT END -->
