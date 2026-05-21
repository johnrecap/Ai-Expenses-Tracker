# Feature Specification: AI Production Reliability

**Feature Branch**: `038-ai-production-reliability`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Make the AI Assistant reliable in production: real gateway configuration, quota errors, category resolution, fallback behavior, and device QA.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Real AI Works When Configured (Priority: P1)

As a signed-in user, I want the AI Assistant to parse natural Arabic expense text using the real gateway when the app is built with the gateway URL.

**Why this priority**: Without `AI_GATEWAY_URL`, the app uses mock AI. Production needs a reliable real-provider path.

**Independent Test**: Build/run with the Worker URL, sign in, enter Arabic text, receive structured preview with amount/category/date/payment method, and confirm only after review.

**Acceptance Scenarios**:

1. **Given** a valid signed-in user and configured Worker URL, **When** the user enters "صرفت 100 جنيه امبارح على المواصلات", **Then** the AI returns a preview with required fields.
2. **Given** the AI result is incomplete, **When** parsing fails validation, **Then** the user sees clarification/error without any write.
3. **Given** the user confirms preview, **When** expense is saved, **Then** the write goes through existing expense flow and is marked AI-sourced.

---

### User Story 2 - AI Fails Safely (Priority: P1)

As a user, I need manual tracking, local reports, repeated expense detection, and local prediction to keep working when the AI provider or quota is unavailable.

**Why this priority**: The app must not depend on paid/backend AI availability for core value.

**Independent Test**: Simulate quota exhausted/provider unavailable and verify manual expense entry and local insights still work.

**Acceptance Scenarios**:

1. **Given** AI quota is exhausted, **When** user opens Add Expense manually, **Then** manual flow works normally.
2. **Given** provider returns 5xx or timeout, **When** AI is requested, **Then** user sees a friendly unavailable message and no data mutation occurs.
3. **Given** AI advice is unavailable, **When** local spending summary exists, **Then** local fallback advice or local reports remain available.

---

### User Story 3 - AI Category Matching Is Trustworthy (Priority: P2)

As a user, I want AI category suggestions to match my actual categories or clearly ask to create a new category.

**Why this priority**: Incorrect categories reduce data quality and user trust.

**Independent Test**: Run Arabic category phrases against existing active categories, archived categories, aliases, and no-match cases.

**Acceptance Scenarios**:

1. **Given** an active "Transport" category exists, **When** user says "مواصلات" or "أوبر", **Then** AI preview selects the matching category.
2. **Given** only an archived matching category exists, **When** AI detects that category, **Then** it does not auto-select the archived category and suggests a safe alternative or asks confirmation.
3. **Given** no matching category exists, **When** AI proposes a category, **Then** creation is previewed and only happens after confirmation.

### Edge Cases

- User token missing or expired must show authentication-related AI error, not generic crash.
- Worker quota metadata may be missing; the app should mark usage stale rather than guessing.
- Receipt images must be compressed and not persisted unnecessarily.
- Voice transcript must only fill input; it must not execute AI actions without user request/confirmation.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: AI gateway mode MUST be enabled only by explicit `AI_GATEWAY_URL` build configuration.
- **FR-002**: Flutter client MUST never contain Gemini/provider API keys.
- **FR-003**: AI requests MUST include Firebase Auth ID token when using the gateway.
- **FR-004**: AI add/update/delete MUST always show preview and require confirmation.
- **FR-005**: Quota/provider/auth errors MUST map to friendly UI states and never block manual flows.
- **FR-006**: AI category resolution MUST use active categories, aliases, and recent hints before suggesting creation.
- **FR-007**: AI usage state MUST update from trusted Worker metadata when available and mark stale when unavailable.
- **FR-008**: Device QA MUST cover real Worker parse, quota failure, provider failure, and manual fallback.

### Key Entities

- **AiProviderConfig**: Build-time endpoint/provider/model/timeout/fallback configuration.
- **AiGatewayRequest**: Authenticated structured request sent to Worker.
- **AiUsageStatus**: Current per-user quota and availability metadata.
- **AiCategoryResolution**: Result of matching AI category text to existing active categories or suggestions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Real gateway AI parse succeeds on a signed-in device for Arabic expense text.
- **SC-002**: 100% of AI mutation intents require a visible confirmation before repository write.
- **SC-003**: Manual expense entry and local reports work when AI provider is disabled, quota exhausted, or unavailable.
- **SC-004**: Secret scans show zero AI provider keys in client-side code.

## Assumptions

- Cloudflare Worker remains the gateway for free-plan production AI.
- Gemini 2.5 Flash is the initial provider model.
- Paid/premium AI expansion can be layered later on the same gateway contract.
