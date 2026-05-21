# Implementation Plan: AI Voice Assistant

**Branch**: `[022-ai-voice-assistant]` | **Date**: 2026-05-17 | **Spec**: `specs/022-ai-voice-assistant/spec.md`

## Summary

Add voice dictation to the AI Assistant using native device speech recognition. Voice produces editable text and then reuses the existing AI parsing/preview/confirmation flow.

## Technical Context

**Language/Version**: Dart 3.x, Flutter.  
**Primary Dependencies**: `speech_to_text ^7.3.0`, existing `AiAssistantSheet`, `AiTextInput`, `AiAssistantCubit`.  
**Storage**: Optional voice preference in `UserSettings`; transcript itself is not persisted unless user confirms an AI action.  
**Testing**: Unit tests for voice controller state, widget tests for button state, manual device QA for speech plugin.  
**Target Platform**: Android/iOS primarily; macOS/web where package supports it; graceful unavailable on unsupported platforms.  
**Project Type**: Flutter feature integration.  
**Performance Goals**: Start listening within 2 seconds after permission is available.  
**Constraints**: Voice must not bypass AI confirmation; platform speech recognition may enforce timeouts.  
**Scale/Scope**: One active AI Assistant sheet session.

## Constitution Check

- **AI Safety**: Pass. Voice only fills text; mutations still require preview confirmation.
- **Change Scope**: Pass. Adds voice layer without replacing AI service.
- **Settings Pattern**: Pass. Optional voice preferences should use `SettingsRepository`.

## Project Structure

```text
lib/ai/voice/
├── ai_voice_input_controller.dart       # new Cubit/controller
├── ai_voice_input_state.dart            # new state model
└── ai_voice_input_service.dart          # new abstraction

lib/screens/ai_assistant/widgets/
├── ai_text_input.dart
└── ai_voice_button.dart                 # new

android/app/src/main/AndroidManifest.xml
ios/Runner/Info.plist
macos/Runner/DebugProfile.entitlements   # if macOS supported
macos/Runner/Release.entitlements        # if macOS supported

test/ai/
├── ai_voice_input_controller_test.dart
└── ai_voice_button_test.dart
```

**Structure Decision**: Put speech service/controller under `lib/ai/voice` so the AI Assistant UI depends on an abstraction and tests can fake recognition results.

## Research

### Decision: Use native `speech_to_text` first
**Rationale**: The package exposes device speech recognition and supports Android, iOS, macOS, web, and Windows build/speech support in varying degrees. It is suited for commands and short phrases, which matches expense dictation.  
**Source**: Pub.dev states `speech_to_text` targets commands/short phrases and documents platform support and permissions.

### Decision: Do not promise true continuous listening
**Rationale**: The plugin documentation notes Android can stop after short pauses and continuous recognition is not currently a native guaranteed use case.  
**Product behavior**: Use longer `listenFor`, practical `pauseFor`, preserve partial text, and allow restart/continue.

### Decision: No paid cloud STT in this plan
**Rationale**: The user wants free-first behavior and no unnecessary API consumption. A cloud/offline advanced STT plan can be added later.

## Data Model

### AiVoiceInputState
- `status`: idle, initializing, listening, pausedByPlatform, stopped, unavailable, permissionDenied, failure.
- `partialTranscript`.
- `finalTranscript`.
- `localeId`.
- `errorMessage`.
- `isManualStop`.

### VoiceSettings
- `preferredLocaleId`: nullable.
- `listenForSeconds`: default 60 where platform allows.
- `pauseForSeconds`: default practical value, with documented platform limitations.
- `autoRestartOnPlatformStop`: default false or guarded true after UX review.

## Verification

```text
flutter pub get
flutter analyze
flutter test test/ai/ai_voice_input_controller_test.dart test/ai/ai_voice_button_test.dart
flutter test
```

Manual QA is required on a real Android phone because emulators/devices differ in speech recognition availability.

## Implementation Notes

- `speech_to_text ^7.3.0` was selected from pub.dev as the latest stable release available on 2026-05-17.
- The voice controller uses device speech recognition only. It fills the editable AI text input and does not call AI parsing or mutate data by itself.
- Voice settings are deferred until Plan 021 exposes a settings surface for this feature.
