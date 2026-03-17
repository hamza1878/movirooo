import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class VoiceMessageBubble extends StatefulWidget {
  final bool isMe;
  final String time;
  final Duration duration;

  const VoiceMessageBubble({
    super.key,
    required this.isMe,
    required this.time,
    this.duration = const Duration(seconds: 12),
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _progress = 0.0;
  late AnimationController _waveController;

  // Fake waveform bar heights
  final List<double> _bars = const [
    0.3, 0.6, 0.4, 0.9, 0.5, 0.7, 0.3, 1.0, 0.6, 0.4,
    0.8, 0.5, 0.3, 0.7, 0.9, 0.4, 0.6, 0.3, 0.8, 0.5,
    0.7, 0.4, 0.6, 0.9, 0.3, 0.5, 0.8, 0.4, 0.7, 0.6,
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() => _progress = _waveController.value);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isPlaying = false;
            _progress = 0.0;
          });
          _waveController.reset();
        }
      });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _waveController.forward(from: _progress);
      // TODO: play actual audio file
    } else {
      _waveController.stop();
      // TODO: pause audio
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _currentTime {
    final elapsed = Duration(
      milliseconds:
          (widget.duration.inMilliseconds * _progress).round(),
    );
    return _isPlaying || _progress > 0
        ? _formatDuration(elapsed)
        : _formatDuration(widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isMe
        ? AppColors.primaryPurple
        : AppColors.surface(context);
    final contentColor = widget.isMe ? Colors.white : AppColors.text(context);
    final activeColor = widget.isMe ? Colors.white : AppColors.primaryPurple;
    final inactiveColor = widget.isMe
        ? Colors.white.withOpacity(0.35)
        : AppColors.subtext(context).withOpacity(0.4);

    return Align(
      alignment:
          widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
            bottomRight: Radius.circular(widget.isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Play / Pause button ──────────────────────────
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryPurple.withOpacity(0.12),
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: widget.isMe ? Colors.white : AppColors.primaryPurple,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Waveform + timer ─────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Waveform bars
                SizedBox(
                  width: 140,
                  height: 28,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(_bars.length, (i) {
                      final barProgress = i / _bars.length;
                      final isActive = barProgress <= _progress;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          height: _bars[i] * 22,
                          decoration: BoxDecoration(
                            color: isActive ? activeColor : inactiveColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 4),

                // Duration + time
                Row(
                  children: [
                    Text(
                      _currentTime,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontSize: 11,
                        color: contentColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Text(
                      widget.time,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontSize: 11,
                        color: contentColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}