# Implementation Plan: Production Readiness Gate

**Branch**: `064-production-readiness-gate` | **Date**: 2026-05-20 | **Spec**: `specs/064-production-readiness-gate/spec.md`  
**Input**: Feature specification from `specs/064-production-readiness-gate/spec.md`

## Summary

Create a production readiness gate that turns the current deferred release blockers into one executable internal-release checklist. This is mostly documentation, scripts, and verification wiring: it should not change app behavior unless a release safety check needs a small visible diagnostic.

## Technical Context

**Language/Version**: Dart 3.x, Flutter, PowerShell for local verification helpers  
**Primary Dependencies**: Existing Firebase/Auth/Firestore, Cloudflare Worker config, AdMob config, docs/qa runbooks  
**Storage**: Markdown checklist and optional local verification output under `docs/qa/`  
**Testing**: Manual real-device QA plus existing Flutter/Worker/Functions verification commands  
**Target Platform**: Android internal/release builds first  
**Project Type**: Mobile app release-readiness workflow  
**Performance Goals**: Checklist completion under 60 minutes for one clean-device pass  
**Constraints**: No secrets in source; no production deploy from automation unless owner explicitly runs it  
**Scale/Scope**: One release candidate at a time

## Constitution Check

- Spec Kit artifacts under `specs/064-production-readiness-gate/`: PASS.
- Production secrets remain outside Flutter source: PASS.
- Manual finance tracking remains available when AI/ads fail: PASS.
- Firebase deploy and real-device QA remain explicit external actions: PASS.

## Project Structure

```text
docs/qa/production-device-qa.md
docs/release/play-store-checklist.md
docs/release/android-release.md
docs/ai/production-ai-setup.md
docs/monetization/manual-qa.md
tools/verification/
firebase.json
firestore.rules
firestore.indexes.json
workers/ai-gateway/
functions/
```

## Implementation Strategy

1. Consolidate the current release docs into one owner-facing gate checklist.
2. Add explicit pass/fail evidence fields for every critical journey.
3. Add a release-blocker matrix for Firebase, Auth, AI gateway, AdMob, account deletion, and Play Store policy.
4. Add optional local commands for preflight checks without deploying anything.
5. Keep all production credentials and deployment execution manual.

## Risks

- A checklist can go stale. Mitigation: link every item to the owning doc/spec and update it after release-affecting plans.
- Some checks require real external setup. Mitigation: mark them as external blockers, not local code failures.

## Deferred Items Considered

Relevant deferred items: release keystore, Firebase smoke, Google SHA setup, AI gateway URL, AdMob production IDs, account deletion validation, App Check, Play Store policy, and clean-device QA.

