// ════════════════════════════════════════════════════════════════════════════
// pulse_rings_widget.dart  — light/dark aware
// ════════════════════════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';
import 'ai_assistant_state.dart';

class PulseRingsWidget extends StatefulWidget {
  final AssistantState state;
  const PulseRingsWidget({super.key, required this.state});

  @override
  State<PulseRingsWidget> createState() => _PulseRingsWidgetState();
}

class _PulseRingsWidgetState extends State<PulseRingsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(PulseRingsWidget old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.state != AssistantState.idle) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Resolve context-aware colors here (not inside painter)
    final colors = (
      AiColors.ring1(context),
      AiColors.ring2(context),
      AiColors.ring3(context),
      AiColors.ring4(context),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => CustomPaint(
        painter: _RingsPainter(
          pulse: _pulse.value,
          state: widget.state,
          colors: colors,
        ),
        child: const SizedBox(width: 280, height: 280),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double pulse;
  final AssistantState state;
  final (Color, Color, Color, Color) colors;

  _RingsPainter({
    required this.pulse,
    required this.state,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final active = state != AssistantState.idle;
    final baseR = math.min(cx, cy);

    final rings = [
      (1.00, colors.$1, active ? 0.55 : 0.30, 1.0),
      (0.82, colors.$2, active ? 0.60 : 0.35, 1.2),
      (0.64, colors.$3, active ? 0.70 : 0.40, 1.5),
      (0.48, colors.$4, active ? 0.85 : 0.50, 2.0),
    ];

    for (final (frac, color, opacity, strokeW) in rings) {
      final r = baseR * frac * (active ? pulse : 1.0);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }

    if (active) {
      canvas.drawCircle(
        Offset(cx, cy),
        baseR * 0.38,
        Paint()
          ..color = AiColors.purpleGlow
              .withOpacity(0.18 * (pulse - 0.97) / 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.pulse != pulse || old.state != state || old.colors != colors;
}
