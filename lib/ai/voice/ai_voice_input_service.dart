// ignore_for_file: deprecated_member_use

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AiVoiceLocale {
  const AiVoiceLocale({
    required this.localeId,
    required this.name,
  });

  final String localeId;
  final String name;
}

class AiVoiceTranscript {
  const AiVoiceTranscript({
    required this.text,
    required this.isFinal,
  });

  final String text;
  final bool isFinal;
}

class AiVoiceInputError {
  const AiVoiceInputError({
    required this.message,
    required this.isPermanent,
  });

  final String message;
  final bool isPermanent;

  bool get isPermissionDenied =>
      message == 'error_permission' ||
      message == 'error_speech_recognizer_disabled';
}

typedef AiVoiceStatusCallback = void Function(String status);
typedef AiVoiceErrorCallback = void Function(AiVoiceInputError error);
typedef AiVoiceResultCallback = void Function(AiVoiceTranscript transcript);

abstract class AiVoiceInputService {
  Future<bool> initialize({
    required AiVoiceStatusCallback onStatus,
    required AiVoiceErrorCallback onError,
  });

  Future<List<AiVoiceLocale>> locales();

  Future<void> listen({
    required AiVoiceResultCallback onResult,
    String? localeId,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 8),
  });

  Future<void> stop();

  Future<void> cancel();

  bool get isListening;
}

class SpeechToTextVoiceInputService implements AiVoiceInputService {
  SpeechToTextVoiceInputService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize({
    required AiVoiceStatusCallback onStatus,
    required AiVoiceErrorCallback onError,
  }) {
    return _speech.initialize(
      onStatus: onStatus,
      onError: (SpeechRecognitionError error) {
        onError(
          AiVoiceInputError(
            message: error.errorMsg,
            isPermanent: error.permanent,
          ),
        );
      },
      options: [SpeechToText.androidNoBluetooth],
    );
  }

  @override
  Future<List<AiVoiceLocale>> locales() async {
    final locales = await _speech.locales();
    return locales
        .map(
          (locale) => AiVoiceLocale(
            localeId: locale.localeId,
            name: locale.name,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> listen({
    required AiVoiceResultCallback onResult,
    String? localeId,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 8),
  }) {
    // speech_to_text 7.3.0 keeps listenFor/pauseFor as deprecated named
    // parameters while SpeechListenOptions does not expose them in docs.
    return _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(
          AiVoiceTranscript(
            text: result.recognizedWords,
            isFinal: result.finalResult,
          ),
        );
      },
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId,
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
