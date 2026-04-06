// ════════════════════════════════════════════════════════════════════════════
// ai_assistant_controller.dart
// All business logic: state transitions, simulated AI responses
// Swap the "simulate" methods with real speech_to_text + TTS later
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'ai_assistant_state.dart';

// ── Real speech packages (uncomment when ready) ──────────────────────────
//
// pubspec.yaml:
//   dependencies:
//     speech_to_text: ^6.6.0        # microphone → text
//     flutter_tts: ^4.0.2           # text → speech
//
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:flutter_tts/flutter_tts.dart';
//
// ios/Runner/Info.plist:
//   <key>NSSpeechRecognitionUsageDescription</key>
//   <string>Used for voice commands</string>
//   <key>NSMicrophoneUsageDescription</key>
//   <string>Used for voice commands</string>
//
// android/app/src/main/AndroidManifest.xml:
//   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
//   <uses-permission android:name="android.permission.INTERNET"/>
// ──────────────────────────────────────────────────────────────────────────

class AiAssistantController extends ChangeNotifier {
  AssistantModel _model = const AssistantModel();
  AssistantModel get model => _model;

  // ── Real speech objects (uncomment when using real packages) ─────────────
  // final SpeechToText _stt = SpeechToText();
  // final FlutterTts   _tts = FlutterTts();
  // bool _sttAvailable = false;

  // Simulated AI responses list
  static const _responses = [
    (
      text: '"Welcome! Where is your next destination?"',
      highlighted: 'destination?"',
    ),
    (
      text: 'you missing saying your date for go move',
      highlighted: 'move',
    ),
    (
      text: '"Sure! I found 3 rides near Tunis Carthage."',
      highlighted: 'Tunis Carthage."',
    ),
    (
      text: '"Your booking is confirmed. Have a safe trip!"',
      highlighted: 'safe trip!"',
    ),
  ];
  int _responseIndex = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called when user taps the mic button
  Future<void> toggleListening() async {
    if (_model.state == AssistantState.listening) {
      await _stopListening();
    } else if (_model.state == AssistantState.idle) {
      await _startListening();
    }
    // If saying → ignore tap (AI is speaking)
  }

  void close() {
    _model = const AssistantModel();
    notifyListeners();
  }

  // ── Internal flow ─────────────────────────────────────────────────────────

  Future<void> _startListening() async {
    _setModel(_model.copyWith(
      state: AssistantState.listening,
      transcript: '',
      highlighted: '',
    ));

    // ── REAL implementation ────────────────────────────────────────────────
    // _sttAvailable = await _stt.initialize();
    // if (!_sttAvailable) return;
    // _stt.listen(
    //   onResult: (result) {
    //     _setModel(_model.copyWith(
    //       transcript: '"${result.recognizedWords}"',
    //     ));
    //     if (result.finalResult) _stopListening();
    //   },
    //   localeId: 'en_US',
    // );

    // ── SIMULATED: auto-stop after 2.5 s ──────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 2500));
    if (_model.state == AssistantState.listening) {
      await _stopListening();
    }
  }

  Future<void> _stopListening() async {
    // _stt.stop();

    // Transition to SAYING and show AI response
    final response = _responses[_responseIndex % _responses.length];
    _responseIndex++;

    _setModel(_model.copyWith(
      state: AssistantState.saying,
      transcript: response.text,
      highlighted: response.highlighted,
    ));

    await _speak(response.text);
  }

  Future<void> _speak(String text) async {
    // ── REAL TTS ───────────────────────────────────────────────────────────
    // await _tts.setLanguage('en-US');
    // await _tts.setPitch(1.0);
    // await _tts.setSpeechRate(0.5);
    // await _tts.speak(text);
    // await _tts.awaitSpeakCompletion(true);
    // _setModel(_model.copyWith(state: AssistantState.idle));

    // ── SIMULATED: wait for text length ───────────────────────────────────
    final duration = Duration(milliseconds: 800 + text.length * 35);
    await Future.delayed(duration);
    if (_model.state == AssistantState.saying) {
      _setModel(_model.copyWith(state: AssistantState.idle));
    }
  }

  void _setModel(AssistantModel m) {
    _model = m;
    notifyListeners();
  }
}
