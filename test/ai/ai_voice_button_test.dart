import 'package:expenses_tracker/ai/voice/ai_voice_input_state.dart';
import 'package:expenses_tracker/screens/ai_assistant/widgets/ai_voice_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiVoiceButton', () {
    testWidgets('shows idle microphone icon', (tester) async {
      var started = false;
      await tester.pumpWidget(
        _VoiceButtonHarness(
          state: const AiVoiceInputState(),
          onStart: () => started = true,
        ),
      );

      expect(find.byIcon(Icons.mic_none), findsOneWidget);

      await tester.tap(find.byType(IconButton));

      expect(started, isTrue);
    });

    testWidgets('shows stop icon while listening', (tester) async {
      var stopped = false;
      await tester.pumpWidget(
        _VoiceButtonHarness(
          state: const AiVoiceInputState(
            status: AiVoiceInputStatus.listening,
          ),
          onStop: () => stopped = true,
        ),
      );

      expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);

      await tester.tap(find.byType(IconButton));

      expect(stopped, isTrue);
    });

    testWidgets('disables button while initializing', (tester) async {
      var started = false;
      await tester.pumpWidget(
        _VoiceButtonHarness(
          state: const AiVoiceInputState(
            status: AiVoiceInputStatus.initializing,
          ),
          onStart: () => started = true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(IconButton));

      expect(started, isFalse);
    });

    testWidgets('exposes unavailable tooltip', (tester) async {
      await tester.pumpWidget(
        const _VoiceButtonHarness(
          state: AiVoiceInputState(
            status: AiVoiceInputStatus.unavailable,
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));

      expect(tooltip.message, 'Speech recognition unavailable');
    });
  });
}

class _VoiceButtonHarness extends StatelessWidget {
  const _VoiceButtonHarness({
    required this.state,
    this.onStart,
    this.onStop,
  });

  final AiVoiceInputState state;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AiVoiceButton(
            state: state,
            onStart: onStart ?? () {},
            onStop: onStop ?? () {},
          ),
        ),
      ),
    );
  }
}
