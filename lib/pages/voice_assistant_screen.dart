import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

// ─────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────
const String kBackendUrl = 'http://192.168.1.17:8000';

// ─────────────────────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────────────────────
const Color kBg         = Color(0xFF0A0D1A);
const Color kBgCard     = Color(0xFF12172B);
const Color kPurple     = Color(0xFF7B6FF0);
const Color kPurpleGlow = Color(0xFF9D94F5);
const Color kPink       = Color(0xFFE06FD8);
const Color kTextSub    = Color(0xFF6B7299);
const Color kTextMain   = Color(0xFFE8EAF6);

// ─────────────────────────────────────────────────────────────
// Debug logger — visible dans le terminal flutter run
// ─────────────────────────────────────────────────────────────
void _log(String tag, Object? msg) {
  // ignore: avoid_print
  print('\n╔══ [MOVIROO/$tag] ══════════════════════════');
  // ignore: avoid_print
  print('║  $msg');
  // ignore: avoid_print
  print('╚═══════════════════════════════════════════\n');
}

void _logJson(String tag, Map<String, dynamic> json) {
  final encoder = const JsonEncoder.withIndent('  ');
  // ignore: avoid_print
  print('\n╔══ [MOVIROO/$tag] ══════════════════════════');
  for (final line in encoder.convert(json).split('\n')) {
    // ignore: avoid_print
    print('║  $line');
  }
  // ignore: avoid_print
  print('╚═══════════════════════════════════════════\n');
}

// ─────────────────────────────────────────────────────────────
// Phase
// ─────────────────────────────────────────────────────────────
enum VoicePhase {
  idle,
  recording,
  uploading,
  question,
  waitAnswer,
  result,
  search,
  error,
}

// ─────────────────────────────────────────────────────────────
// API Service
// ─────────────────────────────────────────────────────────────
class _ApiService {
  static Future<Map<String, dynamic>> transcribe(String filePath) {
    _log('API', 'POST /transcribe  →  $filePath');
    return _sendFile(Uri.parse('$kBackendUrl/transcribe'), filePath);
  }

  static Future<Map<String, dynamic>> answer(
    String filePath, {
    required String field,
    required String language,
    String? destination,
    String? departure,
    String? date,
    String? time,
  }) {
    final params = {
      'field': field,
      'language': language,
      if (destination != null) 'destination': destination,
      if (departure  != null) 'departure':   departure,
      if (date       != null) 'date':         date,
      if (time       != null) 'time':         time,
    };
    _log('API', 'POST /answer  →  field=$field  params=$params');
    final uri = Uri.parse('$kBackendUrl/answer')
        .replace(queryParameters: params);
    return _sendFile(uri, filePath);
  }

  static Future<Map<String, dynamic>> _sendFile(Uri uri, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('Audio file not found: $filePath');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final body     = await streamed.stream.bytesToString();

    _log('API', 'HTTP ${streamed.statusCode}  ←  ${uri.path}');

    if (streamed.statusCode == 200) {
      final decoded = json.decode(body) as Map<String, dynamic>;
      _logJson('API RAW RESPONSE', decoded);
      return decoded;
    }

    Map<String, dynamic> err = {};
    try { err = json.decode(body); } catch (_) {}
    throw Exception(err['detail'] ?? 'Server error ${streamed.statusCode}');
  }
}

// ─────────────────────────────────────────────────────────────
// VoiceAssistantScreen
// ─────────────────────────────────────────────────────────────
class VoiceAssistantScreen extends StatefulWidget {
  final void Function(Map<String, String?> booking)? onBookingConfirmed;
  final void Function(String query)? onSearchQuery;

  const VoiceAssistantScreen({
    super.key,
    this.onBookingConfirmed,
    this.onSearchQuery,
  });

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {

  // ── Services ──────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts    _tts      = FlutterTts();

  // ── State ─────────────────────────────────────────────────
  VoicePhase _phase      = VoicePhase.idle;
  String     _statusMsg  = 'Tap to speak';
  String     _transcript = '';
  String     _language   = 'fr';

  // ── Booking ───────────────────────────────────────────────
  String?      _destination;
  String?      _departure;
  String?      _date;
  String?      _time;
  List<String> _missingFields   = [];
  String?      _currentField;
  String?      _confirmationText;
  String?      _searchQuery;

  // ── Timer ─────────────────────────────────────────────────
  Duration _elapsed = Duration.zero;
  Timer?   _timer;
  String?  _audioPath;
  static const int kMaxSeconds = 60;

  // ── Animations ────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _waveCtrl;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _ring1Anim;
  late Animation<double>   _ring2Anim;
  late Animation<double>   _ring3Anim;

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _log('INIT', 'VoiceAssistantScreen mounted — backend: $kBackendUrl');

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _ring1Anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl,
          curve: const Interval(0.0,  0.7,  curve: Curves.easeOut)),
    );
    _ring2Anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl,
          curve: const Interval(0.15, 0.85, curve: Curves.easeOut)),
    );
    _ring3Anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl,
          curve: const Interval(0.3,  1.0,  curve: Curves.easeOut)),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _initTts();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _tts.stop();
    _timer?.cancel();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // TTS
  // ─────────────────────────────────────────────────────────
  Future<void> _initTts() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      _log('TTS', 'Speech finished → starting answer recording');
      if (_phase == VoicePhase.question) _startAnswerRecording();
    });
  }

  Future<void> _speak(String text, String lang) async {
    final locale = switch (lang) {
      'ar' => 'ar-SA',
      'en' => 'en-US',
      _    => 'fr-FR',
    };
    _log('TTS', 'speak  lang=$locale  →  "$text"');
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  // ─────────────────────────────────────────────────────────
  // Permissions & paths
  // ─────────────────────────────────────────────────────────
  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;
    _setError('Microphone permission denied.');
    return false;
  }

  Future<String> _newAudioPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/mv_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  // ─────────────────────────────────────────────────────────
  // Recording
  // ─────────────────────────────────────────────────────────
  Future<void> _startRecording({bool isAnswer = false}) async {
    if (!await _checkPermission()) return;

    _audioPath = await _newAudioPath();
    _log('REC', '${isAnswer ? 'ANSWER' : 'INITIAL'} recording started → $_audioPath');

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: _audioPath!,
    );

    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _elapsed += const Duration(seconds: 1));
      if (_elapsed.inSeconds >= kMaxSeconds) {
        _log('REC', 'Max duration reached (${kMaxSeconds}s) — auto stop');
        if (isAnswer) _stopAndAnswer(); else _stopAndTranscribe();
      }
    });

    setState(() {
      _phase     = isAnswer ? VoicePhase.waitAnswer : VoicePhase.recording;
      _statusMsg = isAnswer ? 'ANSWERING...' : 'SAYING...';
      if (!isAnswer) {
        _transcript       = '';
        _destination      = null;
        _departure        = null;
        _date             = null;
        _time             = null;
        _missingFields    = [];
        _confirmationText = null;
        _searchQuery      = null;
      }
    });
  }

  Future<void> _startAnswerRecording() => _startRecording(isAnswer: true);

  Future<void> _stopAndTranscribe() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) { _setError('Recording failed.'); return; }
    _audioPath = path;
    _log('REC', 'Initial recording stopped → $path');
    setState(() { _phase = VoicePhase.uploading; _statusMsg = 'PROCESSING...'; });
    try {
      final result = await _ApiService.transcribe(_audioPath!);
      await _handleResult(result);
    } catch (e) {
      _log('ERROR', e);
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _stopAndAnswer() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) { _setError('Answer not recorded.'); return; }
    _audioPath = path;
    _log('REC', 'Answer recording stopped → $path  field=$_currentField');
    setState(() { _phase = VoicePhase.uploading; _statusMsg = 'PROCESSING...'; });
    try {
      final result = await _ApiService.answer(
        _audioPath!,
        field:       _currentField ?? 'destination',
        language:    _language,
        destination: _destination,
        departure:   _departure,
        date:        _date,
        time:        _time,
      );
      await _handleResult(result);
    } catch (e) {
      _log('ERROR', e);
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────
  // Handle result  ← MAIN DEBUG POINT
  // ─────────────────────────────────────────────────────────
  Future<void> _handleResult(Map<String, dynamic> result) async {
    // ── Print raw server response ──────────────────────────
    _logJson('RESULT RAW', result);

    _transcript = result['text']     as String? ?? '';
    _language   = (result['language'] as String? ?? 'fr').substring(0, 2);
    final intent = result['intent']  as String? ?? 'search';

    _log('RESULT',
      'text     = "$_transcript"\n'
      '║  language = $_language\n'
      '║  intent   = $intent',
    );

    // ── SEARCH intent ──────────────────────────────────────
    if (intent == 'search') {
      final query = result['search_query'] as String? ?? _transcript;
      _log('SEARCH', 'query = "$query"');

      setState(() { _searchQuery = query; _phase = VoicePhase.search; _statusMsg = 'RESULT'; });
      widget.onSearchQuery?.call(query);
      await _speak(query, _language);
      return;
    }

    // ── BOOKING intent ─────────────────────────────────────
    _destination      = result['destination']  as String?;
    _departure        = result['departure']    as String?;
    _date             = result['date']         as String?;
    _time             = result['time']         as String?;
    _missingFields    = List<String>.from(result['missing_fields'] ?? []);
    _confirmationText = result['confirmation'] as String?;

    _log('BOOKING ENTITIES',
      'destination    = $_destination\n'
      '║  departure      = $_departure\n'
      '║  date           = $_date\n'
      '║  time           = $_time\n'
      '║  missing_fields = $_missingFields\n'
      '║  confirmation   = $_confirmationText',
    );

    final nextQ = result['next_question'] as Map<String, dynamic>?;

    // ── All fields complete → confirmed ────────────────────
    if (_missingFields.isEmpty && _confirmationText != null) {
      final booking = {
        'destination': _destination,
        'departure':   _departure,
        'date':        _date,
        'time':        _time,
      };
      _logJson('BOOKING CONFIRMED ✅', booking.map((k, v) => MapEntry(k, v ?? 'null')));

      setState(() { _phase = VoicePhase.result; _statusMsg = 'CONFIRMED'; });
      widget.onBookingConfirmed?.call(booking);
      await _speak(_confirmationText!, _language);
      return;
    }

    // ── Missing fields → ask next question ─────────────────
    if (nextQ != null) {
      _currentField = nextQ['field'] as String?;
      final question = nextQ['question'] as String? ?? '';

      _log('NEXT QUESTION',
        'field    = $_currentField\n'
        '║  question = "$question"',
      );

      setState(() { _phase = VoicePhase.question; _statusMsg = question; });
      await _speak(question, _language);
    } else {
      _log('WARN', 'missing_fields=$_missingFields but next_question is null — check backend');
    }
  }

  void _setError(String msg) {
    _log('ERROR', msg);
    setState(() { _phase = VoicePhase.error; _statusMsg = msg; });
  }

  void _reset() {
    _log('RESET', 'User reset — back to idle');
    setState(() {
      _phase            = VoicePhase.idle;
      _statusMsg        = 'Tap to speak';
      _transcript       = '';
      _destination      = null;
      _departure        = null;
      _date             = null;
      _time             = null;
      _missingFields    = [];
      _confirmationText = null;
      _searchQuery      = null;
      _currentField     = null;
      _elapsed          = Duration.zero;
    });
  }

  void _onMicTap() {
    _log('TAP', 'phase=$_phase');
    if (_phase == VoicePhase.uploading || _phase == VoicePhase.question) return;
    if (_phase == VoicePhase.recording)  { _stopAndTranscribe(); return; }
    if (_phase == VoicePhase.waitAnswer) { _stopAndAnswer();     return; }
    _startRecording();
  }

  // ─────────────────────────────────────────────────────────
  // BUILD  (identique à l'original)
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildCenter()),
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(Icons.arrow_back_rounded, onTap: () => Navigator.maybePop(context)),
        const Text(
          'AI TRAVEL ASSISTANT',
          style: TextStyle(
            color: kTextMain, fontSize: 13,
            fontWeight: FontWeight.w600, letterSpacing: 2.5,
          ),
        ),
        _circleBtn(Icons.more_horiz_rounded),
      ],
    ),
  );

  Widget _circleBtn(IconData icon, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kBgCard,
        border: Border.all(color: kPurple.withOpacity(0.2)),
      ),
      child: Icon(icon, color: kTextSub, size: 18),
    ),
  );

  Widget _buildCenter() {
    final isActive = _phase == VoicePhase.recording ||
                     _phase == VoicePhase.waitAnswer ||
                     _phase == VoicePhase.question;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300, height: 300,
          child: Stack(alignment: Alignment.center, children: [
            _staticRing(280, kPurple.withOpacity(0.07)),
            _staticRing(225, kPurple.withOpacity(0.11)),
            if (isActive) ...[
              _animatedRing(_ring1Anim, 210),
              _animatedRing(_ring2Anim, 210),
              _animatedRing(_ring3Anim, 210),
            ],
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  kPurple.withOpacity(0.18), Colors.transparent,
                ]),
              ),
            ),
            GestureDetector(
              onTap: _onMicTap,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: isActive ? _pulseAnim.value : 1.0, child: child,
                ),
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF9D8FF5), Color(0xFF6C5CE7)],
                    ),
                    boxShadow: [
                      BoxShadow(color: kPurple.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                      BoxShadow(color: kPurple.withOpacity(0.2), blurRadius: 60, spreadRadius: 15),
                    ],
                  ),
                  child: _buildMicIcon(),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        _buildWaveform(),
        const SizedBox(height: 14),
        Text(
          _phaseLabel(),
          style: const TextStyle(
            color: kPurpleGlow, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        _buildMessageBubble(),
      ],
    );
  }

  Widget _staticRing(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 1),
    ),
  );

  Widget _animatedRing(Animation<double> anim, double maxSize) =>
      AnimatedBuilder(
        animation: anim,
        builder: (_, __) {
          final v = anim.value;
          return Container(
            width: maxSize * v, height: maxSize * v,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: kPurple.withOpacity((1 - v) * 0.4), width: 1.5,
              ),
            ),
          );
        },
      );

  Widget _buildMicIcon() {
    if (_phase == VoicePhase.uploading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
      );
    }
    if (_phase == VoicePhase.question) {
      return const Icon(Icons.volume_up_rounded, color: Colors.white, size: 44);
    }
    return const Icon(Icons.mic_rounded, color: Colors.white, size: 44);
  }

  Widget _buildWaveform() {
    const bars = [0.4, 0.7, 1.0, 0.6, 0.9, 0.5, 0.8, 0.45, 0.75, 0.55];
    final isActive = _phase == VoicePhase.recording ||
                     _phase == VoicePhase.waitAnswer ||
                     _phase == VoicePhase.question;
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(bars.length, (i) {
          return AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) {
              final h = isActive
                  ? bars[i] * (0.5 + 0.5 *
                      (_waveCtrl.value * (i % 2 == 0 ? 1.0 : -1.0)).abs())
                  : 0.3;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3,
                height: 32 * h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [kPink, kPurple],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _phaseLabel() => switch (_phase) {
    VoicePhase.recording  => 'SAYING...',
    VoicePhase.waitAnswer => 'SAYING...',
    VoicePhase.uploading  => 'PROCESSING...',
    VoicePhase.question   => 'SAYING...',
    VoicePhase.result     => 'CONFIRMED',
    VoicePhase.search     => 'RESULT',
    VoicePhase.error      => 'ERROR',
    _                     => 'READY',
  };

  Widget _buildMessageBubble() {
    final (String text, Color highlight) = switch (_phase) {
      VoicePhase.idle       => ('"Welcome! Where is your next destination?"', kPink),
      VoicePhase.recording  => ('Recording... ${_elapsed.inSeconds}s',        Colors.redAccent),
      VoicePhase.waitAnswer => ('Answering... ${_elapsed.inSeconds}s',         Colors.redAccent),
      VoicePhase.uploading  => ('Processing your voice...',                    kPurpleGlow),
      VoicePhase.question   => (_statusMsg,                                    kPink),
      VoicePhase.result     => (_confirmationText ?? 'Booking confirmed!',     Colors.greenAccent),
      VoicePhase.search     => (_searchQuery ?? _transcript,                   Colors.blueAccent),
      VoicePhase.error      => (_statusMsg,                                    Colors.redAccent),
    };

    final words    = text.split(' ');
    final lastWord = words.isNotEmpty ? words.last : '';
    final rest     = words.length > 1 ? words.sublist(0, words.length - 1).join(' ') : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPurple.withOpacity(0.15)),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 15, height: 1.5, color: kTextMain),
          children: [
            if (rest.isNotEmpty) TextSpan(text: rest),
            if (rest.isNotEmpty && lastWord.isNotEmpty) const TextSpan(text: ' '),
            if (lastWord.isNotEmpty)
              TextSpan(
                text: lastWord,
                style: TextStyle(color: highlight, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea() => Padding(
    padding: const EdgeInsets.only(bottom: 32, top: 8),
    child: Column(
      children: [
        if (_phase == VoicePhase.result) ...[
          _buildResultRows(),
          const SizedBox(height: 16),
        ],
        GestureDetector(
          onTap: _reset,
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBgCard,
              border: Border.all(color: kPurple.withOpacity(0.25)),
            ),
            child: const Icon(Icons.close_rounded, color: kTextSub, size: 22),
          ),
        ),
      ],
    ),
  );

  Widget _buildResultRows() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kBgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kPurple.withOpacity(0.15)),
    ),
    child: Column(children: [
      _resultRow('From', _departure,   Icons.trip_origin_rounded),
      _resultRow('To',   _destination, Icons.location_on_rounded),
      _resultRow('Date', _date,        Icons.calendar_today_rounded),
      _resultRow('Time', _time,        Icons.schedule_rounded),
    ]),
  );

  Widget _resultRow(String label, String? val, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 15, color: kPurple),
      const SizedBox(width: 10),
      Text('$label  ', style: const TextStyle(color: kTextSub, fontSize: 13)),
      Expanded(
        child: Text(
          val ?? '—',
          style: TextStyle(
            color: val != null ? kTextMain : kTextSub,
            fontSize: 13,
            fontWeight: val != null ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    ]),
  );
}