import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    // TODO: _speechToText.listen(onResult: ...) or record package
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    // TODO: stop and get audio file, then call widget.onSend(audioPath)
    widget.onSend('🎤 Voice message');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // ── Text field pill ────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: _isRecording
                  // Recording indicator
                  ? SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Icon(Icons.graphic_eq_rounded,
                              color: AppColors.primaryPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Recording...',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontSize: 14,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    )
                  // Normal text field
                  : TextField(
                      controller: widget.controller,
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(fontSize: 14),
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.subtext(context),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Send / Mic button ──────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _hasText
                // ── Send ──
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: () => widget.onSend(widget.controller.text),
                    child: _ActionButton(
                      color: AppColors.primaryPurple,
                      icon: Icons.send_rounded,
                    ),
                  )
                // ── Mic (tap to send / hold to record) ──
                : GestureDetector(
                    key: const ValueKey('mic'),
                    onTap: () => widget.onSend('🎤 Voice message'),
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: _ActionButton(
                      color: _isRecording
                          ? Colors.red
                          : AppColors.primaryPurple,
                      icon: _isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable circular action button ───────────────────────
class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _ActionButton({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.40),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}