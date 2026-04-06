// ════════════════════════════════════════════════════════════════════════════
// ai_assistant_state.dart
// State model for the AI Travel Assistant
// ════════════════════════════════════════════════════════════════════════════

/// The 3 visual states shown in the screenshot
enum AssistantState {
  idle,       // mic idle, no animation
  listening,  // "LISTENING..." — user is speaking
  saying,     // "SAYING..."   — AI is responding
}

/// Holds the current state + transcript text
class AssistantModel {
  final AssistantState state;
  final String transcript;   // what was heard / said
  final String highlighted;  // purple highlighted word(s) in transcript

  const AssistantModel({
    this.state = AssistantState.idle,
    this.transcript = '',
    this.highlighted = '',
  });

  AssistantModel copyWith({
    AssistantState? state,
    String? transcript,
    String? highlighted,
  }) =>
      AssistantModel(
        state: state ?? this.state,
        transcript: transcript ?? this.transcript,
        highlighted: highlighted ?? this.highlighted,
      );
}
