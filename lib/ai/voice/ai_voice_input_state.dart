import 'package:equatable/equatable.dart';

enum AiVoiceInputStatus {
  idle,
  initializing,
  listening,
  pausedByPlatform,
  stopped,
  unavailable,
  permissionDenied,
  failure,
}

class AiVoiceInputState extends Equatable {
  const AiVoiceInputState({
    this.status = AiVoiceInputStatus.idle,
    this.partialTranscript = '',
    this.finalTranscript = '',
    this.localeId,
    this.errorMessage,
    this.isManualStop = false,
  });

  final AiVoiceInputStatus status;
  final String partialTranscript;
  final String finalTranscript;
  final String? localeId;
  final String? errorMessage;
  final bool isManualStop;

  bool get canStart =>
      status == AiVoiceInputStatus.idle ||
      status == AiVoiceInputStatus.stopped ||
      status == AiVoiceInputStatus.pausedByPlatform ||
      status == AiVoiceInputStatus.failure;

  bool get canStop => status == AiVoiceInputStatus.listening;

  bool get hasTranscript =>
      partialTranscript.trim().isNotEmpty || finalTranscript.trim().isNotEmpty;

  String get bestTranscript =>
      finalTranscript.trim().isNotEmpty ? finalTranscript : partialTranscript;

  AiVoiceInputState copyWith({
    AiVoiceInputStatus? status,
    String? partialTranscript,
    String? finalTranscript,
    String? localeId,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isManualStop,
  }) {
    return AiVoiceInputState(
      status: status ?? this.status,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      finalTranscript: finalTranscript ?? this.finalTranscript,
      localeId: localeId ?? this.localeId,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isManualStop: isManualStop ?? this.isManualStop,
    );
  }

  @override
  List<Object?> get props => [
        status,
        partialTranscript,
        finalTranscript,
        localeId,
        errorMessage,
        isManualStop,
      ];
}
