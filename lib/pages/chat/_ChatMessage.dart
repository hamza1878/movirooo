import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_VoiceMessageBubble.dart';

class ChatMessage {
  final String id;
  final String text;
  final String? translatedText;
  final bool isMe;
  final String time;
  final bool isArabic;
  final bool isVoice;

  const ChatMessage({
    required this.id,
    required this.text,
    this.translatedText,
    required this.isMe,
    required this.time,
    this.isArabic = false,
    this.isVoice = false,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTranslation;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTranslation = true,
  });

  @override
  Widget build(BuildContext context) {
    // ── Voice message ──────────────────────────────────────
    if (message.isVoice) {
      return VoiceMessageBubble(
        isMe: message.isMe,
        time: message.time,
      );
    }

    // ── Text message ───────────────────────────────────────
    final isMe = message.isMe;
    final bubbleColor = isMe
        ? AppColors.primaryPurple
        : AppColors.surface(context);
    final textColor = isMe ? Colors.white : AppColors.text(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: textColor,
                fontSize: 14,
              ),
            ),
            if (showTranslation && message.translatedText != null) ...[
              const SizedBox(height: 6),
              Divider(color: textColor.withOpacity(0.2), height: 1),
              const SizedBox(height: 6),
              Text(
                message.translatedText!,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: textColor.withOpacity(0.75),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                message.time,
                style: AppTextStyles.bodySmall(context).copyWith(
                  fontSize: 10,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}