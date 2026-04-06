// ════════════════════════════════════════════════════════════════════════════
// waveform_widget.dart
// The animated pink/purple sound bars shown below the mic
// Animates when listening or saying, static when idle
// ════════════════════════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';
import 'ai_assistant_state.dart';

class WaveformWidget extends StatefulWidget {
  final AssistantState state;
  const WaveformWidget({super.key, required this.state});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(WaveformWidget old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.state != AssistantState.idle) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _WaveformPainter(
          progress: _ctrl.value,
          state: widget.state,
        ),
        size: const Size(120, 40),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final AssistantState state;

  // Bar heights pattern (mirrors left/right from centre)
  static const _barPattern = [0.25, 0.45, 0.70, 0.95, 1.0, 0.95, 0.70, 0.45, 0.25];

  _WaveformPainter({required this.progress, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final active = state != AssistantState.idle;
    final barCount = _barPattern.length;
    final barW = 4.0;
    final totalW = barCount * barW + (barCount - 1) * 4.0;
    final startX = (size.width - totalW) / 2;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barW
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < barCount; i++) {
      // Animate each bar with a phase offset
      double heightFraction = _barPattern[i];
      if (active) {
        final phase = progress * 2 * math.pi + i * 0.5;
        heightFraction = (_barPattern[i] * (0.5 + 0.5 * math.sin(phase))).clamp(0.15, 1.0);
      }

      final barH = size.height * heightFraction;
      final x = startX + i * (barW + 4.0) + barW / 2;
      final yTop = (size.height - barH) / 2;
      final yBot = yTop + barH;

      // Gradient colour: pink → purple based on position
      final t = i / (barCount - 1);
      final color = Color.lerp(AiColors.pink, AiColors.purple, t)!
          .withOpacity(active ? 0.90 : 0.40);

      paint.color = color;
      canvas.drawLine(Offset(x, yTop), Offset(x, yBot), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.state != state;
}
