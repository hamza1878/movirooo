// ════════════════════════════════════════════════════════════════════════════
// transcript_card_widget.dart — light/dark aware
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';

class TranscriptCardWidget extends StatelessWidget {
  final String text;
  final String highlighted;

  const TranscriptCardWidget({
    super.key,
    required this.text,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(text),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          // card(context) → dark: #1A1A2E  light: #EFEBFB
          color: AiColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AiColors.cardBord(context)),
        ),
        child: _buildRichText(context),
      ),
    );
  }

  Widget _buildRichText(BuildContext context) {
    // textPrimary(context) → dark: #EEEEF5  light: #1A1A2E
    final baseStyle = TextStyle(
      color: AiColors.textPrimary(context),
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );

    if (highlighted.isEmpty || !text.contains(highlighted)) {
      return Text(text, textAlign: TextAlign.center, style: baseStyle);
    }

    final parts = text.split(highlighted);
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: highlighted,
          style: const TextStyle(
            // textHighlight is static — same purple in both modes
            color: AiColors.textHighlight,
            fontWeight: FontWeight.w700,
          ),
        ));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}
