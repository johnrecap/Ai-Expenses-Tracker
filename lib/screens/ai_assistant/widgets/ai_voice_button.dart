import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:flutter/material.dart';

class AiVoiceButton extends StatelessWidget {
  const AiVoiceButton({
    required this.state,
    required this.onStart,
    required this.onStop,
    super.key,
  });

  final AiVoiceInputState state;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInitializing = state.status == AiVoiceInputStatus.initializing;
    final isListening = state.status == AiVoiceInputStatus.listening;
    final isBlocked = state.status == AiVoiceInputStatus.permissionDenied ||
        state.status == AiVoiceInputStatus.unavailable;
    final color = isListening
        ? theme.colorScheme.error
        : isBlocked
            ? theme.disabledColor
            : theme.colorScheme.primary;
    final tooltip = _tooltipForState(state);

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: isInitializing || isBlocked
            ? null
            : isListening
                ? onStop
                : onStart,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isInitializing
              ? const SizedBox(
                  key: ValueKey('voice-loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isListening ? Icons.stop_circle_outlined : Icons.mic_none,
                  key: ValueKey(isListening ? 'voice-stop' : 'voice-mic'),
                  color: color,
                ),
        ),
        tooltip: tooltip,
      ),
    );
  }

  String _tooltipForState(AiVoiceInputState state) {
    switch (state.status) {
      case AiVoiceInputStatus.initializing:
        return 'Preparing voice input';
      case AiVoiceInputStatus.listening:
        return 'Stop listening';
      case AiVoiceInputStatus.pausedByPlatform:
        return 'Continue voice input';
      case AiVoiceInputStatus.permissionDenied:
        return 'Microphone permission denied';
      case AiVoiceInputStatus.unavailable:
        return 'Speech recognition unavailable';
      case AiVoiceInputStatus.failure:
        return 'Retry voice input';
      case AiVoiceInputStatus.idle:
      case AiVoiceInputStatus.stopped:
        return 'Start voice input';
    }
  }
}
