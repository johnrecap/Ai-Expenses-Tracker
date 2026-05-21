# Feature Specification: AI Voice Assistant

**Feature Branch**: `[022-ai-voice-assistant]`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User wants to talk to the AI Assistant, with a longer listening grace period so it does not stop while speaking.

## User Scenarios & Testing

### User Story 1 - Dictate Expense Text Into AI Assistant (Priority: P1)

As a user, I want to tap a microphone button, speak Arabic or English expense text, see the transcript in the AI input, and then review the normal AI preview.

**Why this priority**: Voice is a faster input method, but it must reuse the existing safe preview flow.

**Independent Test**: Tap microphone, say "صرفت 100 جنيه امبارح على المواصلات", stop listening, and verify the text appears in the AI input and can be parsed into a preview.

**Acceptance Scenarios**:

1. **Given** microphone permission is granted, **When** the user speaks an expense, **Then** the recognized text fills the AI text field.
2. **Given** the user stops manually, **When** transcription has partial text, **Then** the partial text remains editable.
3. **Given** the user confirms AI preview, **Then** the expense is created only after the existing confirmation flow.

---

### User Story 2 - Longer Practical Listening Session (Priority: P1)

As a user, I want the app to keep listening long enough for a natural sentence and not stop immediately when I pause briefly.

**Why this priority**: Expense phrases in Arabic can include amount, date, category, payment method, and description; short pauses are common.

**Independent Test**: Start voice input, pause briefly between amount and category, continue speaking, and verify the transcript still captures the full sentence where the platform allows it.

**Acceptance Scenarios**:

1. **Given** platform speech recognition supports timeouts, **When** listening starts, **Then** the app uses a long `listenFor` duration and practical `pauseFor` setting.
2. **Given** Android stops after a short platform-enforced pause, **When** the user is still in active mic mode, **Then** the app keeps the transcript and offers restart/continue instead of losing the sentence.
3. **Given** speech recognition is unavailable, **When** the user taps mic, **Then** the app shows a clear fallback and keeps manual typing available.

---

### User Story 3 - Voice Settings And Permissions (Priority: P2)

As a user, I want to understand and control speech permissions and preferred recognition language.

**Why this priority**: Speech recognition depends on device permissions and installed languages.

## Requirements

### Functional Requirements

- **FR-001**: AI Assistant MUST include a microphone control that starts/stops speech recognition.
- **FR-002**: Voice transcript MUST populate the same text input used by typed AI commands.
- **FR-003**: Voice input MUST never directly save, update, or delete data; it only produces text for the existing AI preview flow.
- **FR-004**: The app MUST request and handle microphone/speech permissions on supported platforms.
- **FR-005**: The app MUST configure a longer practical listening session using available speech recognition options.
- **FR-006**: The app MUST preserve partial transcript when recognition stops unexpectedly.
- **FR-007**: The app MUST support at least Arabic Egypt and English recognition when available on the device.
- **FR-008**: The app MUST show unavailable/permission-denied states without blocking manual text entry.
- **FR-009**: The app MUST document platform limitations: native speech recognition is not guaranteed continuous and Android may stop after short pauses.

### Key Entities

- **VoiceInputState**: idle, initializing, listening, pausedByPlatform, stopped, unavailable, permissionDenied, failure.
- **VoiceTranscript**: partial text, final text, locale, confidence if provided, updatedAt.
- **VoiceSettings**: preferred locale, listen duration, pause behavior, auto-restart preference.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 95% of successful speech sessions keep the recognized text editable after stop.
- **SC-002**: Manual typing remains available in 100% of permission-denied/unavailable voice states.
- **SC-003**: A standard Arabic expense sentence can be dictated and parsed into preview on a supported Android device.
- **SC-004**: No voice path bypasses AI preview confirmation.

## Assumptions

- Use device/native speech recognition first; no paid cloud speech API is introduced in this plan.
- Continuous always-on listening is out of scope because native `speech_to_text` is designed for short phrases and platform timeouts apply.
- The app can add a future cloud/offline speech engine in a separate paid or advanced plan.
