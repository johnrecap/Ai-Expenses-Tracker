# Internal Release Gate

Use this as the single owner-facing gate before Android internal testing or any
public release candidate. It consolidates the release checks currently spread
across:

- `docs/qa/production-device-qa.md`
- `docs/release/play-store-checklist.md`
- `docs/release/android-release.md`
- `docs/ai/production-ai-setup.md`
- `docs/monetization/manual-qa.md`

Do not approve a public release until every P0 item has pass/fail evidence.
Manual expense tracking must remain usable even if AI, ads, notifications, or
premium surfaces are disabled for the release.

## Source Document Audit

| Source | Keep as owner | Duplicates found | Missing or conflicting checks | Gate decision |
| --- | --- | --- | --- | --- |
| `docs/qa/production-device-qa.md` | Detailed manual device scenarios | Auth, expenses, reports, export, AI, ads, premium, app lock, notifications | Does not separate P0 blockers from optional feature failures | Keep as detailed journey reference; this file owns go/no-go |
| `docs/release/play-store-checklist.md` | Store listing and policy preflight | Signing, Firebase, AI URL, AdMob, artifact inspection | Does not capture clean-device evidence or per-journey smoke results | Keep for Play Store upload; this file owns internal release approval |
| `docs/release/android-release.md` | Signing/build command reference | AI URL, AdMob app id, artifact inspection | Build commands are examples only; no pass/fail sign-off table | Keep as build reference; this file records evidence |
| `docs/ai/production-ai-setup.md` | AI gateway setup and Worker smoke reference | AI URL, gateway mode, provider failure, quota, secret scan | Contains mojibake Arabic sample text in examples; use this gate's Arabic smoke prompt for owner evidence | Keep as AI setup reference; this file owns AI release status |
| `docs/monetization/manual-qa.md` | Ads, rewarded credit, and premium manual QA | Test ads, consent, premium no-ad behavior | Explicitly debug/internal oriented; production AdMob approval needs blocker status | Keep as monetization reference; this file owns production ad gate |

## Release Candidate Header

| Field | Value |
| --- | --- |
| Release candidate name/version |  |
| Artifact type (`apk`/`aab`) |  |
| Artifact path |  |
| Artifact size |  |
| Build date/time |  |
| Package id | `com.saeeddevstudio.ai_expenses_tracker` |
| Version code/name |  |
| Signing fingerprint |  |
| Device model |  |
| Android version |  |
| Firebase project |  |
| Tester |  |
| Gate started |  |
| Gate completed |  |

## Go/No-Go Blocker Matrix

| Priority | Blocker | Blocks | Required evidence | Status | Owner notes |
| --- | --- | --- | --- | --- | --- |
| P0 | Artifact is unsigned, debug-signed, wrong package id, or wrong version | Public release and internal release if not intentionally debug QA | Artifact inspection output and installed package details |  |  |
| P0 | Firebase Auth fails for Google or email/password on signed artifact | Public release | Login/logout/re-login evidence for both providers or provider-specific blocker |  |  |
| P0 | Firestore rules reject core user-owned writes or allow cross-user access | Public release | Real-user smoke for settings, expenses, categories, budgets, recurring, saving goals, and AI action logs |  |  |
| P0 | Core finance flow fails: create expense, edit/delete expense, Home totals, Reports totals, budget progress | Public release | Screenshots or notes showing expected totals and no permission errors |  |  |
| P0 | `AI_GATEWAY_URL` is missing while release claims production AI support | Public release with AI enabled | Build defines/evidence and device AI gateway status |  |  |
| P0 | Unintended Google test AdMob app/ad unit IDs in public-release artifact | Public release with ads enabled | Manifest/config inspection, ad unit review, or explicit ads-disabled sign-off |  |  |
| P0 | Account deletion or reauthentication is misleading, incomplete, or leaves user data accessible | Public release | Delete-account journey evidence or documented release limitation |  |  |
| P1 | Export, app lock, or notifications fail but free manual tracking works | Feature approval | Journey-specific pass/fail evidence and release note decision |  |  |
| P1 | AI provider failure, quota exhaustion, receipt, or advice state is unclear | AI feature approval | Device evidence that manual entry still works and errors are honest |  |  |
| P1 | Consent, premium no-ad, rewarded credit, or interstitial behavior is ambiguous | Ads/premium approval | Monetization manual QA evidence |  |  |
| P2 | Store listing, privacy/data safety, screenshots, content rating, or support email missing | Public store upload | Play Console checklist evidence |  |  |

## Environment Preflight

| Check | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| Release keystore exists locally and is outside source control | `android/key.properties` points to a private keystore; no keystore is committed |  |  |
| Artifact is release/internal and not debug-signed | Signing fingerprint matches upload/release certificate |  |  |
| Package id is final | `com.saeeddevstudio.ai_expenses_tracker` |  |  |
| Firebase project is production-like | Correct app id, package id, SHA-1/SHA-256, Auth providers, Firestore rules/indexes |  |  |
| Worker URL is final for AI-enabled release | `AI_GATEWAY_URL` points to the intended Cloudflare Worker route |  |  |
| Provider/model values are intentional | `AI_PROVIDER` and `AI_MODEL` are recorded |  |  |
| Ads state is explicit | Production AdMob ids configured, or ads intentionally disabled |  |  |
| Test accounts are ready | Google and email/password accounts available; no personal data in notes |  |  |
| Privacy and data safety disclosures match build behavior | Auth, Firestore, camera, microphone, notifications, local auth, ads, and AI gateway covered |  |  |

## Clean-Device Startup Smoke

Record these before feature smoke starts.

| Step | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| Install the release candidate on a clean Android device | Install succeeds without using debug-only setup |  |  |
| Launch app from a clean state | No startup crash; onboarding/auth gate appears |  |  |
| Complete first-run language/currency/reminder flow if shown | Settings are saved and Home can load after auth |  |  |
| Restart app | Startup state persists; no infinite loading screen |  |  |
| Record device and artifact metadata | Header table above is complete |  |  |

## Firebase Auth Smoke

| Provider | Steps | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- | --- |
| Email/password | Register or sign in, land on Home, sign out, sign in again | Same user-owned settings and expenses load without permission errors |  |  |
| Google | Sign in, land on Home, sign out, sign in again | Google provider works with final package id and signing fingerprints |  |  |
| Cross-provider safety | Switch accounts after logout | Previous user's data does not appear for the next user |  |  |
| Failure messaging | Try invalid credentials or cancelled Google flow | App shows honest recoverable state, not a stuck loader |  |  |

## Firestore Write Smoke

Use a real signed-in user on the release candidate. Record one pass/fail row per
path because Firestore rules can reject one path while others pass.

| User-owned path / feature | Create | Read after restart | Update | Delete / archive | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- | --- | --- | --- |
| Settings/profile/local preferences |  |  |  |  |  |  |
| Expenses |  |  |  |  |  |  |
| Categories |  |  |  | Archive if hard delete is not supported |  |  |
| Monthly budgets |  |  |  |  |  |  |
| Category budgets |  |  |  |  |  |  |
| Recurring expenses / subscriptions |  |  |  |  |  |  |
| Saving goals |  |  |  |  |  |  |
| AI action logs / quota metadata |  |  |  |  |  |  |

## Core Finance Smoke

| Journey | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| Add a basic expense manually | Home transaction list and totals update |  |  |
| Edit the expense | Updated amount/category/payment/date persist after restart |  |  |
| Delete the expense | Expense is removed once; no duplicate delete errors |  |  |
| Add mixed-currency expenses | Home and Reports show converted totals or explicit missing-rate metadata |  |  |
| Monthly budget | Budget spent/remaining matches converted app totals |  |  |
| Reports week/month | Totals, top category, charts, and comparison match current expenses |  |  |
| Export CSV/PDF | Export opens share sheet and rows/totals are understandable |  |  |

## AI Gateway Readiness

If production AI is advertised, this section is P0. If AI is intentionally
disabled or internal-only, record that decision here and keep manual entry
available.

| Check | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| `AI_GATEWAY_URL` provided | Artifact uses a real Cloudflare Worker URL, not mock-only mode |  |  |
| Gateway mode visible/confirmed | Device behavior confirms provider-backed AI path |  |  |
| Arabic parse | Prompt `دفعت 120 جنيه مواصلات امبارح` creates an editable draft with amount/category/date |  |  |
| Missing data handling | Ambiguous prompt leaves unknown fields editable instead of blocking the user |  |  |
| Receipt flow | Receipt/image flow returns a reviewable draft or honest unavailable state |  |  |
| Advice flow | Advice appears or fails with a clear recoverable message |  |  |
| Provider failure | Gateway/provider error does not break manual tracking |  |  |
| Quota exhausted | Quota state is honest; rewarded/premium behavior matches config |  |  |
| Secret exposure | No provider API key is in Flutter source, docs, logs, screenshots, or committed fixtures |  |  |

## AdMob, Premium, And Consent Readiness

| Check | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| Android AdMob app id | Production id configured for public ads, or ads explicitly disabled |  |  |
| Ad unit ids | No unintended Google test ad ids in public-release config |  |  |
| Consent behavior | Consent unavailable/denied states collapse ad slots safely |  |  |
| Banner placement | Ads do not cover Home, Expenses, Reports, or navigation content |  |  |
| Interstitial safety | Interstitials never interrupt auth, app lock, add expense entry, AI preview, purchase, or restore |  |  |
| Rewarded credits | Credit is added only after reward callback; failures do not grant credits |  |  |
| Premium no-ad behavior | Verified Premium entitlement suppresses ad requests |  |  |
| Purchase state | No real charge starts until entitlement backend is ready |  |  |

## Account, Security, And Device Features

| Journey | Expected | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- |
| App-local display name | Name can be changed and persists without depending on Google profile |  |  |
| Account deletion warning | Warning is clear before destructive action |  |  |
| Reauthentication | Deletion flow requires valid recent auth when Firebase requires it |  |  |
| Data deletion | User-scoped Firestore data is removed or release limitation is documented |  |  |
| Logout | Confirmation appears before sign-out |  |  |
| App lock | PIN/biometric protects resume; PIN/biometric details are not logged |  |  |
| Notifications | Permission request, daily reminder, and weekly digest settings persist |  |  |
| Offline recovery | Offline create/reconnect does not lose or duplicate user data |  |  |

## Verification Command References

These are references for the parent/owner agent to run later. Do not paste
secrets or private user data into command output records.

| Working directory | Command | Purpose | Pass/Fail | Evidence / notes |
| --- | --- | --- | --- | --- |
| Repo root | `flutter analyze --no-pub` | Static Dart/Flutter analysis without package refresh |  |  |
| Repo root | `flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s` | Full Flutter regression suite when the local toolchain is healthy |  |  |
| Repo root | Targeted Flutter tests for changed release-critical areas | Faster validation for Auth, Settings, Home, Reports, AI, Export, and Account flows |  |  |
| `workers/ai-gateway` | `npm run typecheck` | Worker TypeScript/config validation |  |  |
| `workers/ai-gateway` | `npm test` | Worker AI gateway behavior and error contracts |  |  |
| `functions` | `npm test` | Firebase Functions unit tests |  |  |
| `functions` | `npm run test:rules` | Firestore rules emulator tests; `npm test` alone is not enough for rules |  |  |
| Repo root | `rg "AI_GATEWAY_URL|AdMob|test ad|Firebase smoke|release gate" docs specs` | Documentation consistency scan |  |  |

## External Manual Sign-Off

| External task | Required before | Owner initials/date | Evidence link or notes |
| --- | --- | --- | --- |
| Release/upload keystore created and protected outside source control | Public/internal release candidate |  |  |
| Signed artifact inspected for package id, version, manifest, and signing fingerprint | Any owner-approved artifact |  |  |
| Firebase Auth providers enabled for final package id and SHA fingerprints | Public release |  |  |
| Firestore rules and indexes deployed | Public release |  |  |
| Real-user Firebase smoke completed | Public release |  |  |
| Cloudflare Worker deployed with provider secret | Production AI enabled |  |  |
| Real `AI_GATEWAY_URL` included in release artifact | Production AI enabled |  |  |
| Production AdMob app/ad unit ids configured, or ads disabled | Public release with monetization surface |  |  |
| Play Store privacy/data safety/content rating completed | Store upload |  |  |
| Clean-device QA completed | Public release |  |  |

## Final Decision

| Decision | Value |
| --- | --- |
| Internal testing approved? |  |
| Public release approved? |  |
| Features intentionally disabled |  |
| P0 blockers remaining |  |
| P1/P2 limitations accepted |  |
| Owner initials/date |  |

