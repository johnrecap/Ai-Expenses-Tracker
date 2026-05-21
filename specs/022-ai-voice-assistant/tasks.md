# Tasks: AI Voice Assistant

**Input**: `specs/022-ai-voice-assistant/spec.md`, `plan.md`  
**Implementation Intent**: Add speech dictation to AI Assistant while preserving text preview and confirmation safety.

## Phase 1: Dependency And Platform Setup

- [X] T001 Add speech dependency to `pubspec.yaml`.

  **Why**: The app needs a native speech recognition bridge.
  **Steps**:
  1. Add `speech_to_text` with the latest stable version compatible with current Dart/Flutter.
  2. Run `flutter pub get`.
  3. Record version in implementation notes.
  **Done when**: Package resolves without changing unrelated dependencies.

- [X] T002 Add Android speech permissions in `android/app/src/main/AndroidManifest.xml`.

  **Why**: Android requires microphone and speech recognition visibility permissions.
  **Steps**:
  1. Add `android.permission.RECORD_AUDIO`.
  2. Confirm `android.permission.INTERNET` already exists or add if needed because platform recognition may use remote services.
  3. Add recognition service `<queries>` for Android 30+.
  4. Add Bluetooth permissions only if headset support is explicitly included.
  **Done when**: Android build can request microphone/speech recognition.

- [X] T003 Add iOS speech permission descriptions in `ios/Runner/Info.plist`.

  **Why**: iOS requires clear user-facing reasons for microphone and speech recognition.
  **Steps**:
  1. Add `NSSpeechRecognitionUsageDescription`.
  2. Add `NSMicrophoneUsageDescription`.
  3. Use concise copy tied to expense dictation.
  **Done when**: iOS permission dialog is configured.

## Phase 2: Voice Service And State

- [X] T004 Create `AiVoiceInputState` in `lib/ai/voice/ai_voice_input_state.dart`.

  **Why**: UI needs clear status and transcript fields.
  **Steps**:
  1. Define enum statuses.
  2. Add partial/final transcript, locale, error, and manual-stop flag.
  3. Add helpers `canStart`, `canStop`, `hasTranscript`.
  **Done when**: State can represent all voice UX paths.

- [X] T005 Create `AiVoiceInputService` abstraction in `lib/ai/voice/ai_voice_input_service.dart`.

  **Why**: Tests should not depend on real microphone APIs.
  **Steps**:
  1. Define methods `initialize`, `locales`, `listen`, `stop`, `cancel`, `isListening`.
  2. Define callbacks for partial/final result, status, and error.
  3. Add a real `SpeechToTextVoiceInputService` wrapping `speech_to_text`.
  **Done when**: Controller can be tested with a fake service.

- [X] T006 Create `AiVoiceInputController` in `lib/ai/voice/ai_voice_input_controller.dart`.

  **Why**: Voice state belongs outside widgets and should survive simple rebuilds.
  **Steps**:
  1. Initialize speech once per sheet/session.
  2. Start listening with preferred locale when available.
  3. Use longer `listenFor` and practical `pauseFor` options.
  4. Preserve partial text on error/platform stop.
  5. Allow manual stop and cancel.
  6. Expose final transcript to the text field.
  **Done when**: Controller tests pass with fake service.

- [X] T007 Add controller tests in `test/ai/ai_voice_input_controller_test.dart`.

  **Why**: Voice plugin behavior is hard to automate; controller logic must be reliable.
  **Steps**:
  1. Test initialization success and unavailable state.
  2. Test permission denied maps to permissionDenied.
  3. Test partial transcript updates.
  4. Test platform stop preserves text.
  5. Test manual stop marks transcript final.
  **Done when**: Controller behavior is covered without microphone.

## Phase 3: AI Assistant UI

- [X] T008 Create `AiVoiceButton` in `lib/screens/ai_assistant/widgets/ai_voice_button.dart`.

  **Why**: The mic control should be reusable and focused.
  **Steps**:
  1. Show mic icon when idle.
  2. Show stop/pulse/listening state when active.
  3. Disable while initializing.
  4. Show tooltip/status for unavailable or permission denied.
  5. Keep button dimensions stable.
  **Done when**: Widget can render every voice state.

- [X] T009 Integrate voice button into `AiTextInput`.

  **Why**: Voice should fill the existing AI input field, not create a separate flow.
  **Steps**:
  1. Add optional voice controller/callback params to `AiTextInput`.
  2. When transcript changes, update `TextEditingController.text`.
  3. Preserve typed text and append/replace based on clear UX rule.
  4. Keep parse button behavior unchanged.
  **Done when**: Dictated text can be edited and submitted normally.

- [X] T010 Wire voice controller in `AiAssistantSheet`.

  **Why**: The sheet owns the text controller and can coordinate voice with AI parsing.
  **Steps**:
  1. Create voice controller/service in sheet state.
  2. Dispose it safely.
  3. Stop listening before submitting parse if needed.
  4. Show a small status message for permission/unavailable errors.
  **Done when**: Voice input is usable in the existing AI Assistant sheet.

- [X] T011 Add voice settings placeholder or section if Plan 021 is complete.

  **Why**: Users may need language and listening behavior controls.
  **Steps**:
  1. Add preferred speech locale selector if available locales can be read.
  2. Add explanatory text that platform timeouts may still apply.
  3. Persist preference via `SettingsRepository` only if UserSettings extension is included.
  **Done when**: Voice preferences are visible or explicitly deferred.

## Phase 4: Tests And QA

- [X] T012 Add widget tests in `test/ai/ai_voice_button_test.dart`.

  **Why**: Button state should not regress.
  **Steps**:
  1. Test idle icon.
  2. Test listening icon/state.
  3. Test disabled initializing state.
  4. Test unavailable message.
  **Done when**: Widget tests pass.

- [X] T013 Run targeted verification.

  **Commands**:
  ```text
  flutter test test/ai/ai_voice_input_controller_test.dart test/ai/ai_voice_button_test.dart
  flutter analyze
  ```
  **Done when**: Voice code passes automated checks.
  **Status note (Plan 040 cleanup)**: Superseded by later parent verification;
  voice controller/button tests are part of the passing Flutter suite.

- [ ] T014 Manual Android device QA.

  **Status note (Plan 040 cleanup)**: Still open because speech recognition
  requires real Android permission/runtime behavior.

  **Why**: Speech recognition is platform and device dependent.
  **Steps**:
  1. Install app on real Android phone.
  2. Grant microphone permission.
  3. Dictate "صرفت 100 جنيه امبارح على المواصلات".
  4. Pause briefly mid-sentence and continue.
  5. Stop manually.
  6. Parse text and confirm preview.
  7. Deny permission and verify manual typing still works.
  **Done when**: Real device behavior is documented.

- [ ] T015 Update quick notes in `docs/implementation_plans/` or the feature folder after QA.

  **Status note (Plan 040 cleanup)**: Still open until manual voice QA is run.

  **Why**: Future workers need to know platform limitations.
  **Steps**:
  1. Record Android pause behavior observed.
  2. Record iOS permission behavior if tested.
  3. Record any device-specific recognition setup needed.
  **Done when**: Voice limitations are not hidden from future implementation.
