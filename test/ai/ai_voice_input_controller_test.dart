import 'package:expenses_tracker/ai/voice/ai_voice_input_controller.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_service.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  group('AiVoiceInputController', () {
    test('initializes and starts listening', () async {
      final service = _FakeVoiceInputService();
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();

      expect(service.initializeCalled, isTrue);
      expect(service.listenCalled, isTrue);
      expect(controller.state.status, AiVoiceInputStatus.listening);
      expect(controller.state.localeId, isNull);

      await controller.close();
    });

    test('maps unavailable initialization to unavailable state', () async {
      final service = _FakeVoiceInputService(available: false);
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();

      expect(controller.state.status, AiVoiceInputStatus.unavailable);
      expect(controller.state.errorMessage, contains('not available'));

      await controller.close();
    });

    test('maps permission error to permissionDenied state', () async {
      final service = _FakeVoiceInputService(
        available: false,
        initializationError: const AiVoiceInputError(
          message: 'error_permission',
          isPermanent: true,
        ),
      );
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();

      expect(controller.state.status, AiVoiceInputStatus.permissionDenied);
      expect(controller.state.errorMessage, contains('permission'));

      await controller.close();
    });

    test('updates partial transcript while listening', () async {
      final service = _FakeVoiceInputService();
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();
      service.emitTranscript('صرفت 100 جنيه', isFinal: false);

      expect(controller.state.status, AiVoiceInputStatus.listening);
      expect(controller.state.partialTranscript, 'صرفت 100 جنيه');
      expect(controller.state.finalTranscript, isEmpty);

      await controller.close();
    });

    test('platform stop preserves transcript for continuation', () async {
      final service = _FakeVoiceInputService();
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();
      service.emitTranscript('spent 100 on transport', isFinal: false);
      service.emitStatus(SpeechToText.notListeningStatus);

      expect(controller.state.status, AiVoiceInputStatus.pausedByPlatform);
      expect(controller.state.bestTranscript, 'spent 100 on transport');
      expect(controller.state.errorMessage, contains('Tap the mic'));

      await controller.close();
    });

    test('manual stop marks transcript final', () async {
      final service = _FakeVoiceInputService();
      final controller = AiVoiceInputController(service: service);

      await controller.startListening();
      service.emitTranscript('cash 50 food', isFinal: false);
      await controller.stopListening();

      expect(controller.state.status, AiVoiceInputStatus.stopped);
      expect(controller.state.finalTranscript, 'cash 50 food');
      expect(controller.state.isManualStop, isTrue);

      await controller.close();
    });

    test('uses preferred locale only when available', () async {
      final service = _FakeVoiceInputService(
        availableLocales: const [
          AiVoiceLocale(localeId: 'en_US', name: 'English'),
          AiVoiceLocale(localeId: 'ar_EG', name: 'Arabic Egypt'),
        ],
      );
      final controller = AiVoiceInputController(
        service: service,
        preferredLocaleId: 'ar_EG',
      );

      await controller.startListening();

      expect(service.localeId, 'ar_EG');
      expect(controller.state.localeId, 'ar_EG');

      await controller.close();
    });
  });
}

class _FakeVoiceInputService implements AiVoiceInputService {
  _FakeVoiceInputService({
    this.available = true,
    this.initializationError,
    this.availableLocales = const [],
  });

  final bool available;
  final AiVoiceInputError? initializationError;
  final List<AiVoiceLocale> availableLocales;

  late AiVoiceStatusCallback _onStatus;
  late AiVoiceErrorCallback _onError;
  late AiVoiceResultCallback _onResult;
  bool initializeCalled = false;
  bool listenCalled = false;
  bool _isListening = false;
  String? localeId;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize({
    required AiVoiceStatusCallback onStatus,
    required AiVoiceErrorCallback onError,
  }) async {
    initializeCalled = true;
    _onStatus = onStatus;
    _onError = onError;
    if (initializationError != null) {
      _onError(initializationError!);
    }
    return available;
  }

  @override
  Future<List<AiVoiceLocale>> locales() async => availableLocales;

  @override
  Future<void> listen({
    required AiVoiceResultCallback onResult,
    String? localeId,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 8),
  }) async {
    listenCalled = true;
    this.localeId = localeId;
    _onResult = onResult;
    _isListening = true;
    _onStatus(SpeechToText.listeningStatus);
  }

  @override
  Future<void> stop() async {
    _isListening = false;
    _onStatus(SpeechToText.doneStatus);
  }

  @override
  Future<void> cancel() async {
    _isListening = false;
    _onStatus(SpeechToText.notListeningStatus);
  }

  void emitTranscript(String text, {required bool isFinal}) {
    _onResult(AiVoiceTranscript(text: text, isFinal: isFinal));
  }

  void emitStatus(String status) {
    _isListening = status == SpeechToText.listeningStatus;
    _onStatus(status);
  }
}
