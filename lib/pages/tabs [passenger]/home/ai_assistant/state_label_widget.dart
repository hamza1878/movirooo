// ════════════════════════════════════════════════════════════════════════════
// state_label_widget.dart
// Shows  "LISTENING..."  or  "SAYING..."  below the waveform
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';
import 'ai_assistant_state.dart';

class StateLabelWidget extends StatelessWidget {
  final AssistantState state;
  const StateLabelWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == AssistantState.idle) return const SizedBox.shrink();

    final isListening = state == AssistantState.listening;
    final label = isListening ? 'LISTENING...' : 'SAYING...';
    final color = isListening ? AiColors.labelListening : AiColors.labelSaying;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        label,
        key: ValueKey(label),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
      ),
    );
  }
}
