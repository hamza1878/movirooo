// ════════════════════════════════════════════════════════════════════════════
// mic_button_widget.dart
// The central glowing mic button
// Tap → toggles listening on/off
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';
import 'ai_assistant_state.dart';

class MicButtonWidget extends StatelessWidget {
  final AssistantState state;
  final VoidCallback onTap;

  const MicButtonWidget({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state != AssistantState.idle;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Gradient: lighter center → deeper edge
          gradient: RadialGradient(
            colors: isActive
                ? [AiColors.purpleLight, AiColors.micBg]
                : [AiColors.micBg, AiColors.purpleDim],
          ),
          boxShadow: [
            // Main outer glow
            BoxShadow(
              color: AiColors.purple.withOpacity(isActive ? 0.55 : 0.28),
              blurRadius: isActive ? 40 : 20,
              spreadRadius: isActive ? 6 : 2,
            ),
            // Inner highlight
            BoxShadow(
              color: AiColors.purpleLight.withOpacity(0.20),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: const Icon(
          Icons.mic_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}
