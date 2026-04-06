// ════════════════════════════════════════════════════════════════════════════
// ai_assistant_page.dart — light/dark aware
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_colors.dart';
import 'ai_assistant_controller.dart';
import 'ai_assistant_state.dart';
import 'close_button_widget.dart';
import 'mic_button_widget.dart';
import 'pulse_rings_widget.dart';
import 'state_label_widget.dart';
import 'transcript_card_widget.dart';
import 'waveform_widget.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _ctrl = AiAssistantController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = _ctrl.model;

    return Scaffold(
      // ── bg(context) → dark: #0A0A1A  light: #F2F0FA ──────────────────
      backgroundColor: AiColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            const Spacer(flex: 2),
            _MicSection(state: model.state, onMicTap: _ctrl.toggleListening),
            const Spacer(flex: 2),
            WaveformWidget(state: model.state),
            const SizedBox(height: 14),
            StateLabelWidget(state: model.state),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TranscriptCardWidget(
                text: model.transcript,
                highlighted: model.highlighted,
              ),
            ),
            const Spacer(flex: 3),
            AssistantCloseButton(
              onTap: () {
                _ctrl.close();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _DecoCircle(),
          Text(
            'AI TRAVEL ASSISTANT',
            style: TextStyle(
              // textSub(context) → dark: #7A7A9E  light: #6B6B8A
              color: AiColors.textSub(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          _DecoCircle(),
        ],
      ),
    );
  }
}

class _DecoCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // card(context) → dark: #1A1A2E  light: #EFEBFB
        color: AiColors.card(context),
        border: Border.all(color: AiColors.cardBord(context)),
      ),
    );
  }
}

// ── Mic + rings ───────────────────────────────────────────────────────────
class _MicSection extends StatelessWidget {
  final AssistantState state;
  final VoidCallback onMicTap;
  const _MicSection({required this.state, required this.onMicTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PulseRingsWidget(state: state),
          MicButtonWidget(state: state, onTap: onMicTap),
        ],
      ),
    );
  }
}
