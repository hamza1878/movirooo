import 'dart:math';
import 'package:flutter/material.dart';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.activeColor = const Color(0xFF6C63FF),
    this.inactiveColor = const Color(0xFF9E9E9E),
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;
  late Animation<double> _waveAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnim = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isListening
        ? widget.activeColor
        : widget.inactiveColor;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring (only when listening)
          if (widget.isListening)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                  ),
                ),
              ),
            ),

          // Second pulse ring
          if (widget.isListening)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value * 0.85,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.10),
                  ),
                ),
              ),
            ),

          // Waveform bars (only when listening)
          if (widget.isListening)
            AnimatedBuilder(
              animation: _waveAnim,
              builder: (_, __) => _WaveformBars(
                phase: _waveAnim.value,
                color: color,
              ),
            ),

          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: widget.isListening ? 80 : 72,
            height: widget.isListening ? 80 : 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isListening ? color : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(widget.isListening ? 0.5 : 0.2),
                  blurRadius: widget.isListening ? 20 : 8,
                  spreadRadius: widget.isListening ? 4 : 1,
                ),
              ],
              border: Border.all(
                color: color,
                width: widget.isListening ? 0 : 2,
              ),
            ),
            child: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none_rounded,
              color: widget.isListening ? Colors.white : color,
              size: widget.isListening ? 36 : 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  final double phase;
  final Color color;
  static const int barCount = 5;

  const _WaveformBars({required this.phase, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: CustomPaint(
        painter: _WaveformPainter(phase: phase, color: color),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double phase;
  final Color color;

  _WaveformPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final barCount = 5;
    final spacing = 10.0;
    final totalWidth = barCount * 4.0 + (barCount - 1) * spacing;
    final startX = (size.width - totalWidth) / 2;
    final centerY = size.height / 2;
    final maxHeight = 18.0;

    for (int i = 0; i < barCount; i++) {
      final x = startX + i * (4 + spacing) + 2;
      final heightFactor = (sin(phase + i * 0.9) * 0.5 + 0.5);
      final barH = maxHeight * 0.3 + maxHeight * 0.7 * heightFactor;

      canvas.drawLine(
        Offset(x, centerY - barH),
        Offset(x, centerY + barH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.phase != phase || old.color != color;
}