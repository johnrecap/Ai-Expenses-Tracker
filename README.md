# Expense Tracker

Flutter expense tracker with authenticated, user-owned finance data, Bloc state
management, Firebase Auth, a legacy Firestore data path, an in-progress
VPS/PostgreSQL local-first migration, AI safety boundaries, and Spec Kit
documentation for each implementation slice.

## Current Scope

- Firebase Authentication with email/password and Google Sign-In through
  `AuthRepository` and `AuthBloc`.
- User-scoped Firestore data remains the default legacy store while Plan 082
  migrates app-owned data to local-first repositories synced through a VPS API.
- Expense tracking with categories, payment methods, currencies, advanced
  filters, weekly/monthly reports, exports, recurring expenses, subscription
  summaries, saving goals, and offline pending-write feedback.
- Settings, first-run onboarding, and a replayable guided product tour for the
  main finance workflow.
- Local app protection with PIN and optional biometric unlock.
- AI Assistant flows that parse text, voice transcripts, and receipt images
  into editable previews before any confirmed app mutation.
- Cloudflare Worker AI gateway support for Gemini-backed parse, receipt, and
  advice calls when `AI_GATEWAY_URL` is configured; otherwise the Flutter app
  uses deterministic local fallback behavior.
- Free/Premium monetization foundation with test-ID-safe ads, quota surfaces,
  consent abstractions, and future purchase-verification hooks.

## Architecture

- Flutter and Dart 3.x.
- Bloc/Cubit for state management.
- Local repository package in `packages/expense_repository`.
- Firebase Core and Firebase Auth remain the identity layer.
- Cloud Firestore remains the default legacy data store and migration/backfill
  source until cutover.
- `server/` contains the new Fastify/TypeScript VPS API with Firebase ID-token
  verification, Drizzle/PostgreSQL schema, sync/account/migration endpoints,
  health checks, backup restore smoke tooling, and privacy-safe observability.
- `packages/expense_repository` owns repository interfaces plus runtime modes:
  `firebaseLegacy`, `vpsLocalFirst`, and `migrationComparison`.
- Local-first migration code lives under
  `packages/expense_repository/lib/src/local` and `src/sync`; Flutter screens
  still consume repository interfaces rather than local tables or HTTP clients.
- Cloudflare Worker in `workers/ai-gateway` for the current free-plan AI gateway.
- Optional legacy/future Firebase Functions code in `functions/`; it is not the
  current free-plan AI path.
- English/Arabic localization through ARB files and `flutter_localizations`.
- Spec Kit plans under `specs/<number>-<feature>/`.

## Setup

Install Flutter, configure platform Firebase files for your environment, then:

```sh
flutter pub get
flutter run
```

The data runtime defaults to Firebase legacy mode. To run the local-first VPS
migration path during development:

```sh
flutter run --dart-define=REPOSITORY_RUNTIME_MODE=vpsLocalFirst
```

To compare legacy Firebase expenses with migrated local data for pilot users:

```sh
flutter run --dart-define=REPOSITORY_RUNTIME_MODE=migrationComparison
```

For real AI gateway calls, pass the Worker URL at runtime:

```sh
flutter run --dart-define=AI_GATEWAY_URL=https://your-worker.example
```

Never store provider API keys, production AdMob IDs, keystores, or purchase
verification secrets in Flutter source. Keep provider keys in backend secrets
such as the Cloudflare Worker environment.

## VPS API Development

```sh
cd server
npm ci
npm run typecheck
npm test
npm run dev
```

Server environment values are documented in `server/.env.example` and the VPS
runbook. PostgreSQL credentials and Firebase Admin private keys must stay in
ignored environment files or server secret storage.

Useful backend commands:

```sh
cd server
npm run db:generate
npm run db:migrate
npm run backfill:firestore -- --user <firebaseUid>
npm run verify:migration -- <source.json> <target.json>
npm run backup:restore-check
```

`backup:restore-check` requires `DATABASE_URL` and a separate
`RESTORE_DATABASE_URL`; it refuses to restore into the production URL.

## Verification

Use the command set that matches the files changed:

```sh
flutter pub get
flutter analyze
flutter test --reporter expanded --concurrency=1 --timeout 45s
```

For localization changes:

```sh
flutter gen-l10n
flutter analyze --no-pub
```

For Plan 082 VPS backend changes:

```sh
cd server
npm run typecheck
npm test
```

For Cloudflare Worker AI gateway changes:

```sh
cd workers/ai-gateway
npm run typecheck
npm test
```

For optional Firebase Functions work only:

```sh
cd functions
npm test
npm run build
```

For Firestore security/index readiness:

```sh
cd functions
npm run test:rules
```

The rules command uses the Firebase Firestore emulator. Inspect
`firestore.rules`, `firestore.indexes.json`, and `firebase.json`, then deploy
and smoke test only with the intended Firebase project.

## Production Boundaries

The repository intentionally keeps several release-stage tasks out of source:

- Android release keystore and `android/key.properties`.
- Production AdMob app and ad unit IDs.
- Backend purchase verification and permanent Premium entitlement restore.
- Real Firebase deploy/smoke testing and production-device QA.
- Real VPS staging backfill, PostgreSQL restore drills, protected metrics, and
  rollback exercises.
- Play Store privacy/data safety, screenshots, support email, and policy assets.

Track those items in
`docs/implementation_plans/deferred-and-advanced-work.md`.

## Documentation

- Current architecture and conventions:
  `.specify/memory/constitution.md`
- Feature specs and execution history: `specs/`
- Persistent deferred backlog:
  `docs/implementation_plans/deferred-and-advanced-work.md`
- Historical analysis:
  `docs/project_analysis_and_ai_roadmap.md`

## License

Distributed under the MIT License. See `LICENSE` for more information.
