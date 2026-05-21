# Data Model: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

## SpecTaskStatus

Represents one task line in a historical Speckit `tasks.md`.

Fields:

- `specId`: Spec folder id such as `023-free-premium-ads`.
- `taskId`: Task id such as `T019`.
- `title`: Task title from the task line.
- `currentState`: `open`, `complete`, `superseded`, or `blocked`.
- `evidence`: Short reference to the plan, test, file, or doc proving the state.
- `blocker`: Optional note for device QA, Firebase setup, keystore, Play Store, production credentials, or manual verification.
- `updatedInPlan`: The plan that updated the status, expected to be `040-spec-cleanup-tests-backlog`.

Validation:

- A task cannot be marked complete without evidence.
- A task cannot be marked blocked without a blocker reason.
- Superseded tasks must reference the newer spec or plan.

## DeferredWorkItem

Represents a durable future-work entry in `docs/implementation_plans/deferred-and-advanced-work.md`.

Fields:

- `heading`: Existing group heading.
- `summary`: One concise bullet.
- `reason`: Optional context when needed.
- `status`: `deferred`, `blocked`, `advanced`, or `near-term`.

Validation:

- Do not duplicate an existing bullet with different wording.
- Keep entries concise.
- External setup items must remain clearly separated from local implementation tasks.

## HomeNavigationCoverage

Represents one Home action covered by widget tests.

Fields:

- `actionName`: User-visible action or menu entry.
- `expectedOutcome`: Route, dialog, callback, or visible screen.
- `requiredProviders`: Fake providers needed for the widget test.
- `coverageStatus`: `covered`, `not_covered`, or `blocked`.

Validation:

- Tests must not require real Firebase, AdMob, Cloudflare, notifications, speech, camera, or local auth.
- Sensitive actions such as logout must assert confirmation before dispatch.

## SettingsControlCoverage

Represents one Settings section/control covered by widget tests.

Fields:

- `sectionName`: Profile, currency, payment, notifications, security, AI, monetization, privacy, or support.
- `expectedOutcome`: Renders, persists through Cubit, opens safe UI, or shows unavailable/support message.
- `requiredProviders`: Fake Cubit/repository/provider dependencies.
- `coverageStatus`: `covered`, `not_covered`, or `blocked`.

Validation:

- Controls that are not production-ready must show honest unavailable messaging.
- Tests must not call real platform plugins.

## VerificationResult

Represents local verification after implementation.

Fields:

- `command`: Analyzer/test command or documented manual blocker.
- `scope`: `targeted`, `full`, `manual`, or `blocked`.
- `result`: `pass`, `fail`, or `not_run`.
- `notes`: Short explanation.

Validation:

- Implementation cannot be marked complete if analyzer or targeted tests fail.
- Device/build QA can remain `not_run` only with an explicit blocker and deferred backlog entry.
