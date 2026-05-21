# Research: Gemini AI Provider Integration

## Decision 1: Start With Gemini 2.5 Flash Through A Backend Gateway

**Decision**: Use Gemini 2.5 Flash as the first real provider for text AI parsing, but call it only from a backend gateway controlled by the app owner.

**Rationale**: Gemini 2.5 Flash is appropriate for low-cost/free-tier experimentation and supports structured output patterns suitable for the existing AI JSON parser. A mobile Flutter app cannot safely contain provider API keys, so the gateway protects secrets and allows usage limits.

**Alternatives Considered**:

- **Direct Flutter-to-Gemini call**: Rejected because the API key would be recoverable from the client.
- **OpenAI first**: Rejected for this phase because the user explicitly wants to start with free Gemini usage.
- **OpenRouter free models first**: Kept as a fallback/experimentation option because free model availability and limits may vary by model.
- **Local-only model first**: Rejected for MVP because the current app targets multiple platforms and local model packaging would add large binaries and device constraints.

**Official references checked**:

- Gemini API pricing and free-tier page: https://ai.google.dev/gemini-api/docs/pricing
- Gemini API rate limits page: https://ai.google.dev/gemini-api/docs/rate-limits
- Gemini structured output documentation: https://ai.google.dev/gemini-api/docs/structured-output

## Decision 2: Provider Contract Must Return Strict JSON Matching Existing Parser

**Decision**: The gateway must return one JSON object with fields compatible with `AiResponseParser`: `intent`, `amount`, `category`, `categoryId`, `date`, `paymentMethod`, `currency`, `description`, `confidence`, `needsConfirmation`, `clarifyingQuestion`, plus supported search/summary/advice fields.

**Rationale**: The app already has a strict parser and confirmation-first Cubit. Keeping the same contract avoids changing the safety model and reduces implementation risk.

**Alternatives Considered**:

- **Let Gemini return free-form text and parse locally**: Rejected because it weakens safety and makes tests unstable.
- **Create a new response model unrelated to current AI models**: Rejected because it duplicates parser logic and increases UI changes.

## Decision 3: Gateway Owns Quota, Provider Selection, And Fallback

**Decision**: The gateway enforces per-user/day request limits, provider timeout, normalized error responses, and fallback attempts.

**Rationale**: Free provider limits are operational constraints, not UI concerns. Centralizing them server-side makes the app safer and lets future provider changes happen without mobile updates.

**Alternatives Considered**:

- **Client-only quota**: Rejected because it can be bypassed and does not protect API cost.
- **No fallback**: Rejected for future expansion, but MVP can ship with fallback disabled while keeping the interface ready.

## Decision 4: Use Existing AI Action Logging With Small Extensions

**Decision**: Extend the current AI action log path to store provider/model/status metadata and normalized failure reasons.

**Rationale**: The app already records AI previews and confirmations under user-owned Firestore paths. Extending it is simpler than creating a separate logging domain for MVP.

**Alternatives Considered**:

- **Separate analytics-only collection**: Rejected for MVP because it duplicates user/action identity and adds rules complexity.
- **No logging**: Rejected because free-tier quota and AI quality cannot be managed without usage visibility.

## Decision 5: Production Rollout Requires Billing And Privacy Review

**Decision**: Treat free API usage as development/early validation only. Before production rollout, recheck provider terms, free/paid limits, privacy behavior, billing, and abuse controls.

**Rationale**: AI provider pricing and free quota limits are temporally unstable. Production apps need predictable quota, privacy posture, and failure handling.

**Alternatives Considered**:

- **Assume free tier is enough for all users**: Rejected because free limits can change and may not be suitable for production traffic.
