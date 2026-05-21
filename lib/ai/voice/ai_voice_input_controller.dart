import 'package:bloc/bloc.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_service.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AiVoiceInputController extends Cubit<AiVoiceInputState> {
  AiVoiceInputController({
    required AiVoiceInputService service,
    String? preferredLocaleId,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 8),
  })  : _service = service,
        _preferredLocaleId = preferredLocaleId,
        _listenFor = listenFor,
        _pauseFor = pauseFor,
        super(const AiVoiceInputState());

  final AiVoiceInputService _service;
  String? _preferredLocaleId;
  final Duration _listenFor;
  final Duration _pauseFor;
  bool _initialized = false;
  bool _manualStopRequested = false;

  Future<void> startListening() async {
    if (!state.canStart) return;

    emit(
      state.copyWith(
        status: AiVoiceInputStatus.initializing,
        partialTranscript: '',
        finalTranscript: '',
        clearErrorMessage: true,
        isManualStop: false,
      ),
    );

    try {
      final available = _initialized ||
          await _service.initialize(
            onStatus: _handleStatus,
            onError: _handleError,
          );
      _initialized = available;
      if (!available) {
        if (state.status == AiVoiceInputStatus.permissionDenied) return;
        emit(
          state.copyWith(
            status: AiVoiceInputStatus.unavailable,
            errorMessage:
                'Speech recognition is not available. You can still type.',
          ),
        );
        return;
      }

      final localeId = await _resolveLocaleId();
      _manualStopRequested = false;
      emit(
        state.copyWith(
          status: AiVoiceInputStatus.listening,
          localeId: localeId,
          clearErrorMessage: true,
          isManualStop: false,
        ),
      );
      await _service.listen(
        onResult: _handleTranscript,
        localeId: localeId,
        listenFor: _listenFor,
        pauseFor: _pauseFor,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AiVoiceInputStatus.failure,
          errorMessage: 'Could not start voice input. Please type instead.',
        ),
      );
    }
  }

  Future<void> stopListening() async {
    if (!state.canStop && !_service.isListening) return;
    _manualStopRequested = true;
    try {
      await _service.stop();
    } finally {
      emit(
        state.copyWith(
          status: AiVoiceInputStatus.stopped,
          finalTranscript: state.bestTranscript,
          partialTranscript: state.bestTranscript,
          isManualStop: true,
        ),
      );
    }
  }

  Future<void> cancelListening() async {
    _manualStopRequested = true;
    try {
      await _service.cancel();
    } finally {
      emit(
        state.copyWith(
          status: AiVoiceInputStatus.idle,
          partialTranscript: '',
          finalTranscript: '',
          clearErrorMessage: true,
          isManualStop: true,
        ),
      );
    }
  }

  void setPreferredLocaleId(String? preferredLocaleId) {
    _preferredLocaleId = preferredLocaleId;
  }

  Future<String?> _resolveLocaleId() async {
    final preferredLocaleId = _preferredLocaleId;
    if (preferredLocaleId == null || preferredLocaleId.trim().isEmpty) {
      return null;
    }
    final locales = await _service.locales();
    final match = locales.where((locale) {
      return locale.localeId.toLowerCase() == preferredLocaleId.toLowerCase();
    }).toList();
    return match.isEmpty ? null : match.first.localeId;
  }

  void _handleTranscript(AiVoiceTranscript transcript) {
    final text = transcript.text.trim();
    if (text.isEmpty) return;
    emit(
      state.copyWith(
        status: transcript.isFinal
            ? AiVoiceInputStatus.stopped
            : AiVoiceInputStatus.listening,
        partialTranscript: text,
        finalTranscript: transcript.isFinal ? text : state.finalTranscript,
        clearErrorMessage: true,
        isManualStop: _manualStopRequested,
      ),
    );
  }

  void _handleStatus(String status) {
    if (status == SpeechToText.listeningStatus) {
      emit(state.copyWith(status: AiVoiceInputStatus.listening));
      return;
    }
    if (status == SpeechToText.notListeningStatus ||
        status == SpeechToText.doneStatus) {
      if (state.status == AiVoiceInputStatus.listening) {
        emit(
          state.copyWith(
            status: _manualStopRequested
                ? AiVoiceInputStatus.stopped
                : AiVoiceInputStatus.pausedByPlatform,
            finalTranscript: state.bestTranscript,
            partialTranscript: state.bestTranscript,
            errorMessage: _manualStopRequested
                ? null
                : 'Listening paused by the device. Tap the mic to continue.',
            clearErrorMessage: _manualStopRequested,
            isManualStop: _manualStopRequested,
          ),
        );
      }
    }
  }

  void _handleError(AiVoiceInputError error) {
    final hasText = state.hasTranscript;
    final nextStatus = error.isPermissionDenied
        ? AiVoiceInputStatus.permissionDenied
        : hasText
            ? AiVoiceInputStatus.pausedByPlatform
            : AiVoiceInputStatus.failure;
    emit(
      state.copyWith(
        status: nextStatus,
        finalTranscript: state.bestTranscript,
        partialTranscript: state.bestTranscript,
        errorMessage: error.isPermissionDenied
            ? 'Microphone or speech permission is denied. Enable it in device settings or keep typing.'
            : 'Voice input stopped. You can tap the mic again or keep typing.',
        isManualStop: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (_service.isListening || state.canStop) {
      await _service.cancel();
    }
    return super.close();
  }
}
