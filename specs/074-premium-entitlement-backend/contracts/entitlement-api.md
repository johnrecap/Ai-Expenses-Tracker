# Contract: Premium Entitlement Verification API

## Overview

Premium entitlement is server-owned. Flutter may start purchase or restore
flows only when a trusted backend is configured, and it must not grant Premium
from a client-side store callback alone.

Recommended first implementation: Cloudflare Worker endpoint colocated with the
existing AI gateway operations surface. Firebase Functions remains acceptable if
the release owner chooses Firebase for store verification, but secrets must stay
outside Flutter either way.

## Common Headers

```http
Authorization: Bearer <Firebase ID token>
Content-Type: application/json
Idempotency-Key: <client-generated-id>
```

`Authorization` is required for every protected endpoint. The backend derives
`userId` from the Firebase token and must ignore any request body user id that
does not match the authenticated user.

## Endpoint: POST /entitlements/verifyPurchase

### Request

```json
{
  "platform": "google_play",
  "productId": "premium_monthly",
  "purchaseToken": "store-purchase-token",
  "transactionId": "optional-store-transaction-id",
  "clientRequestId": "uuid"
}
```

### Success Response

```json
{
  "ok": true,
  "verificationStatus": "verified",
  "entitlement": {
    "userId": "firebase-user-id",
    "productId": "premium_monthly",
    "tier": "premium",
    "status": "active",
    "source": "google_play",
    "expiresAt": "2026-06-20T00:00:00.000Z",
    "graceUntil": null,
    "lastVerifiedAt": "2026-05-20T00:00:00.000Z",
    "serverRevision": "revision-id"
  },
  "recoveryMessage": null
}
```

### Failure Response

```json
{
  "ok": false,
  "verificationStatus": "invalid_receipt",
  "entitlement": {
    "userId": "firebase-user-id",
    "productId": null,
    "tier": "free",
    "status": "free",
    "source": "server",
    "expiresAt": null,
    "graceUntil": null,
    "lastVerifiedAt": "2026-05-20T00:00:00.000Z",
    "serverRevision": "revision-id"
  },
  "errorCode": "invalid_receipt",
  "recoveryMessage": "We could not verify that purchase. You were not charged by Expense Tracker."
}
```

## Endpoint: POST /entitlements/restore

### Request

```json
{
  "platform": "google_play",
  "purchaseTokens": ["store-purchase-token"],
  "clientRequestId": "uuid"
}
```

### Response Rules

- Return the best active entitlement if any token verifies.
- Return `tier: free` with `verificationStatus: not_found` when no verified
  purchases exist.
- Do not expose raw store API responses.

## Endpoint: GET /entitlements/current

Returns the latest server-owned entitlement for the authenticated user. Flutter
uses this for refresh on app start, manual refresh, and after verify/restore.

## Entitlement Status Values

- `free`: No verified Premium entitlement exists.
- `active`: Premium is currently active and verified.
- `grace_period`: Store entitlement is expired but still inside a server-approved grace period.
- `expired`: Subscription expired and is no longer active.
- `refunded`: Store refunded the purchase.
- `revoked`: Store or server revoked access.
- `unavailable`: Backend could not verify current state; Flutter should keep core Free behavior usable and avoid granting new Premium.

## Verification Status Values

- `verified`: Receipt verified and server entitlement is active or grace-period.
- `restored`: Restore found a verified entitlement.
- `not_found`: Restore found no active entitlement.
- `invalid_receipt`: Receipt/token was malformed, stale, mismatched, or rejected by the store.
- `expired`: Store reports the subscription expired.
- `refunded`: Store reports refund.
- `revoked`: Store reports revocation.
- `backend_unavailable`: Backend/store verification is temporarily unavailable.

## Security Rules

- Store API credentials, signing secrets, and webhook secrets must never be sent
  to Flutter or committed to source.
- Backend writes are idempotent by `Idempotency-Key` and authenticated user id.
- Entitlement writes must be auditable by server timestamp and source.
- Premium ad suppression in Flutter depends only on verified server entitlement
  state, not local purchase callbacks.
