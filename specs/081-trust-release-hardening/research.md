# Research: Trust Release Hardening

## Decision: Clear saved conversion rates when base currency changes

**Rationale**: Current rates are keyed by source currency only. If the base changes from `EGP` to `USD`, the app cannot prove that `USD: 50` still means a valid conversion into the new base. Clearing rates and timestamp prevents wrong totals.

**Alternatives considered**:

- Store `exchangeRateBaseCurrency` in settings. Stronger provenance, but it requires settings schema/rules/entity changes and migration.
- Keep old rates and rely on next daily refresh. Rejected because it can produce wrong totals for the rest of the day.

## Decision: Daily freshness must include target coverage

**Rationale**: A same-day timestamp is not enough if the user adds a new supported currency or if a saved target rate is invalid. The refresh service should consider supported non-base currencies and valid positive finite rates.

**Alternatives considered**:

- Refresh every app start. Rejected because it violates the once-daily cache design and adds unnecessary network dependency.
- Refresh only when users manually press retry. Rejected because the app already owns automatic daily refresh.

## Decision: Account deletion must be reauth-gated before data deletion

**Rationale**: Firebase Auth can reject sensitive operations with `requires-recent-login`. Running data deletion before that check risks removing Firestore data while leaving the auth account active.

**Alternatives considered**:

- Delete Auth first, then data. Rejected because losing auth can prevent client-side Firestore deletion under user-scoped rules.
- Keep current retry flow. Rejected because it can delete data twice and still relies on a failed Auth delete to discover reauth.
- Move deletion to a trusted backend. Best long-term option, but still deferred because it requires backend setup and production validation.

## Decision: Keep incomplete paid/destructive features gated

**Rationale**: Premium purchase, restore execution, wallets, transfers, and backup restore are partially built foundations. Users should not be able to start unverified payment or destructive restore flows.

**Alternatives considered**:

- Hide all incomplete surfaces. Rejected where a visible coming-soon/readiness row helps set expectation.
- Enable local-only Premium. Rejected because permanent entitlement must be verified by a trusted backend.

## Decision: Fix docs as part of hardening

**Rationale**: The repo is used by human and AI implementers. Broken license references or mojibake can mislead future work and make analysis lower quality.

**Alternatives considered**:

- Leave docs cleanup for a later plan. Rejected because this plan explicitly consolidates the review findings.
