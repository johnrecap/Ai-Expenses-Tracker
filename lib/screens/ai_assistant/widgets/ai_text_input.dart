import 'dart:async';

import 'package:expenses_tracker/ai/voice/ai_voice_input_controller.dart';
import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/ai_voice_button.dart';
import 'package:flutter/material.dart';

class AiTextInput extends StatefulWidget {
  const AiTextInput({
    required this.controller,
    required this.onSubmit,
    required this.onClear,
    required this.isLoading,
    this.inputKey,
    this.voiceController,
    super.key,
  });

  final Key? inputKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final bool isLoading;
  final AiVoiceInputController? voiceController;

  @override
  State<AiTextInput> createState() => _AiTextInputState();
}

class _AiTextInputState extends State<AiTextInput> {
  StreamSubscription<AiVoiceInputState>? _voiceSubscription;
  String? _voiceBaseText;
  String _lastAppliedTranscript = '';
  AiVoiceInputStatus? _lastVoiceStatus;

  @override
  void initState() {
    super.initState();
    _subscribeToVoiceController();
  }

  @override
  void didUpdateWidget(covariant AiTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceController != widget.voiceController) {
      _voiceSubscription?.cancel();
      _voiceSubscription = null;
      _voiceBaseText = null;
      _lastAppliedTranscript = '';
      _lastVoiceStatus = null;
      _subscribeToVoiceController();
    }
  }

  @override
  void dispose() {
    _voiceSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToVoiceController() {
    final voiceController = widget.voiceController;
    if (voiceController == null) return;
    _voiceSubscription = voiceController.stream.listen(_handleVoiceState);
  }

  void _handleVoiceState(AiVoiceInputState state) {
    if (state.status == AiVoiceInputStatus.listening &&
        _lastVoiceStatus != AiVoiceInputStatus.listening) {
      _voiceBaseText = widget.controller.text;
      _lastAppliedTranscript = '';
    }

    final transcript = state.bestTranscript.trim();
    if (transcript.isEmpty || transcript == _lastAppliedTranscript) {
      _lastVoiceStatus = state.status;
      return;
    }

    _voiceBaseText ??= widget.controller.text;
    final base = _voiceBaseText!.trim();
    final nextText = base.isEmpty ? transcript : '$base $transcript';
    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _lastAppliedTranscript = transcript;
    _lastVoiceStatus = state.status;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.inputKey,
      controller: widget.controller,
      minLines: 2,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: context.l10n.aiInputExampleHint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.voiceController != null)
              StreamBuilder<AiVoiceInputState>(
                stream: widget.voiceController!.stream,
                initialData: widget.voiceController!.state,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? const AiVoiceInputState();
                  return AiVoiceButton(
                    state: state,
                    onStart: widget.voiceController!.startListening,
                    onStop: widget.voiceController!.stopListening,
                  );
                },
              ),
            IconButton(
              onPressed: widget.isLoading ? null : widget.onClear,
              icon: const Icon(Icons.close),
              tooltip: context.l10n.clear,
            ),
            IconButton(
              onPressed: widget.isLoading ? null : widget.onSubmit,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              tooltip: context.l10n.parse,
            ),
          ],
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 144),
      ),
    );
  }
}
