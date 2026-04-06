// ════════════════════════════════════════════════════════════════════════════
// close_button_widget.dart — light/dark aware
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';

class AssistantCloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const AssistantCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // card(context) → dark: #1A1A2E  light: #EFEBFB
          color: AiColors.card(context),
          border: Border.all(color: AiColors.cardBord(context), width: 1.5),
        ),
        child: Icon(
          Icons.close_rounded,
          // textSub(context) → dark: #7A7A9E  light: #6B6B8A
          color: AiColors.textSub(context),
          size: 22,
        ),
      ),
    );
  }
}
