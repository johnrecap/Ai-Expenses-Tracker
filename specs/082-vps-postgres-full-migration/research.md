# Research: VPS PostgreSQL Full Migration

## Decision: Use PostgreSQL on the VPS as the primary server database

**Rationale**: The app is financial and relational: users own expenses, categories, budgets, recurring rules, goals, wallets, transfers, settings, AI logs, and exchange-rate data. PostgreSQL gives constraints, indexes, transactions, numeric precision, JSONB for flexible settings, and mature backup/restore tooling.

**Alternatives considered**:

- **Firestore only**: rejected because the user wants a full migration and current cost/read-scaling concerns remain.
- **MongoDB**: rejected because finance/reporting queries and relational consistency are a better fit for PostgreSQL.
- **PocketBase/Appwrite self-hosted**: rejected as the primary path because the app needs explicit sync, finance schema control, and long-term backend workflows.
- **Supabase self-hosted**: possible but heavier than a custom API when the VPS already has PostgreSQL and aaPanel.

## Decision: Keep Firebase Auth and verify ID tokens on the VPS

**Rationale**: The app already supports Google and email/password through `AuthRepository`, and `getIdToken()` already exists. The backend can trust Firebase only after server-side token verification and can map `uid` to `users.firebase_uid`.

**Alternatives considered**:

- **Move auth to custom JWT/password backend**: rejected because it increases risk, loses Google auth continuity, and creates account migration work that the user did not request.
- **Keep Firestore Security Rules for data access**: rejected after cutover because app data is no longer primarily stored in Firestore.

## Decision: Use Fastify + Drizzle + Zod for backend implementation

**Rationale**: The repo already has TypeScript in Cloudflare Worker and Functions. Fastify is lightweight, explicit, and good for REST/sync APIs. Drizzle keeps SQL and migrations visible, which is valuable for finance. Zod provides request/response validation that can also inform contract tests.

**Alternatives considered**:

- **NestJS + Prisma**: acceptable if a larger team wants a heavier framework, but not recommended as the first migration because it adds structure and runtime abstraction before the backend needs it.
- **Express + raw SQL**: workable but weaker validation/plugin structure and more manual boilerplate.
- **Direct Flutter-to-PostgreSQL**: rejected for security and operational reasons; database credentials must never ship in Flutter.

## Decision: Use Drift/SQLite for local-first Flutter storage

**Rationale**: The app needs offline creation/editing, reactive local reads, reports, filters, and sync metadata. Drift supports relational local data and generated type-safe queries while keeping Flutter screens fast.

**Alternatives considered**:

- **SharedPreferences/Hive only**: rejected because the domain is relational and query-heavy.
- **Keep Firestore offline cache**: rejected because it keeps Firestore as the data platform.
- **No local DB, direct API calls**: rejected because it would not solve offline UX or repeated network/history reads.

## Decision: Generic sync endpoints before resource-specific APIs

**Rationale**: Existing Flutter code already has repository interfaces. A generic pull/push sync engine reduces endpoint sprawl and supports offline changes across many entities consistently. Resource-specific APIs can be added later for admin/reporting needs.

**Alternatives considered**:

- **CRUD endpoint for every entity first**: simpler conceptually but duplicates sync logic and increases conflict/tombstone inconsistency risk.
- **Realtime WebSockets**: not needed for expense tracking MVP and adds VPS operational complexity.

## Decision: Keep Cloudflare Worker AI gateway

**Rationale**: The Worker already isolates AI provider keys, verifies Firebase tokens, and handles AI quota/error normalization. The migration should not mix data-platform cutover with provider-gateway rewrites.

**Alternatives considered**:

- **Move AI gateway to VPS now**: deferred because it expands risk and is not required for data migration.
- **Call AI provider from Flutter**: rejected permanently because provider keys must not be stored in app code.

## Decision: Backfill is idempotent and staged

**Rationale**: Production migration can fail mid-user or mid-entity. Scripts must be safe to rerun and must compare counts, ids, timestamps, and key field hashes before cutover.

**Alternatives considered**:

- **One-time manual SQL import only**: rejected because it is hard to audit and unsafe to retry.
- **Client-side migration after login only**: possible for small data but rejected as the main path because it depends on user devices, network, and app version adoption.
