# Feature Specification: AI Usage Quota Surface

**Feature Branch**: `028-ai-usage-quota-surface`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User wants Free AI usage to be limited and understandable, with app fallback when AI is unavailable or quota is exhausted.

## User Scenarios & Testing

### User Story 1 - User Sees Remaining AI Usage (Priority: P1)

A Free user can see how many AI text parses, receipt scans, and advice requests remain today.

**Why this priority**: Users must understand the Free plan without feeling the app is randomly failing.

**Independent Test**: Seed quota fixture with remaining counts and confirm AI Assistant, Settings, and Free/Premium screen show the same values.

**Acceptance Scenarios**:

1. **Given** the user has 5 text parses per day and used 2, **When** they open AI usage, **Then** it shows 3 text parses remaining.
2. **Given** the user has no receipt scans remaining, **When** they tap receipt AI, **Then** the app shows quota exhausted and keeps manual expense entry available.

---

### User Story 2 - AI Failures Do Not Break Core App (Priority: P2)

The user can continue manual expense tracking, local reports, local repeated expense detection, and local predictions even if AI quota or provider availability fails.

**Why this priority**: The app must remain useful on the Free plan and without a paid backend.

**Independent Test**: Force Worker unavailable and quota exhausted states; confirm non-AI features still work.

**Acceptance Scenarios**:

1. **Given** the AI Worker is down, **When** the user opens Add Expense, **Then** manual form entry works normally.
2. **Given** AI advice quota is exhausted, **When** the user opens reports, **Then** local summaries and charts still render.

---

### User Story 3 - Quota Prompts Are Honest (Priority: P3)

Users see separate messages for unclear input, quota exhausted, provider outage, and unsupported action.

**Why this priority**: Wrong messaging creates support issues and may look like a fake upsell.

**Independent Test**: Simulate each error type and verify the UI message and available actions.

**Acceptance Scenarios**:

1. **Given** Gemini/Worker returns quota exhausted, **When** AI action fails, **Then** the prompt says daily limit reached and shows reset timing when available.
2. **Given** provider returns an outage error, **When** AI action fails, **Then** the prompt says AI is temporarily unavailable and does not push Premium as the fix.

### Edge Cases

- Worker response may not include fresh usage data.
- Offline app usage may show stale quota until the next successful Worker response.
- Rewarded ad credits must not fake backend quota unless Worker accepts the credit path.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST display daily Free limits and remaining usage for text parse, receipt scan, and AI advice where available.
- **FR-002**: AI quota data MUST come from trusted Worker responses or a documented cache; UI must mark stale values.
- **FR-003**: AI quota exhausted MUST not block manual add expense, local reports, local predictions, or repeated expense detection.
- **FR-004**: AI error UI MUST distinguish unclear input, missing required fields, quota exhausted, provider outage, network failure, and unsupported intent.
- **FR-005**: Free plan defaults MUST remain text parse 5/day, receipt scan 3/day, advice 3/day unless Worker policy changes.
- **FR-006**: Quota reset timing MUST be shown when available and hidden when unknown.
- **FR-007**: Rewarded credits MUST be shown only when the backend/policy supports them.

### Key Entities

- **AiUsageSnapshot**: Per-action usage count, limit, remaining count, reset time, stale flag.
- **AiQuotaError**: Normalized error type and user-safe message.
- **AiActionType**: `text_parse`, `receipt_extraction`, `financial_advice`.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A user can identify remaining Free AI usage in under 5 seconds from Settings or the AI Assistant.
- **SC-002**: 100% of simulated quota/provider/unclear-input failures show distinct messages in tests.
- **SC-003**: Manual expense creation still succeeds when all AI actions are unavailable.
- **SC-004**: Settings and Free/Premium usage displays match the latest available Worker usage snapshot.

## Assumptions

- Cloudflare Worker remains the current free AI gateway.
- Flutter does not store Gemini API keys.
- Local deterministic services remain available without AI provider calls.
