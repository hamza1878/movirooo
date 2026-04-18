// 
import 'package:flutter/material.dart';
import 'package:moviroo/pages/voice_assistant_screen.dart';

void main() {
  runApp(const MovirooApp());
}

class MovirooApp extends StatelessWidget {
  const MovirooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOVIROO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B6FF0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: VoiceAssistantScreen(
        // ── Callback : réservation complète ──────────────
        onBookingConfirmed: (booking) {
          // ignore: avoid_print
          print('\n🚕 ══ BOOKING CONFIRMED ══════════════════');
          // ignore: avoid_print
          print('   destination : ${booking['destination']}');
          // ignore: avoid_print
          print('   departure   : ${booking['departure']}');
          // ignore: avoid_print
          print('   date        : ${booking['date']}');
          // ignore: avoid_print
          print('   time        : ${booking['time']}');
          // ignore: avoid_print
          print('═════════════════════════════════════════\n');
        },

        // ── Callback : intent = search ────────────────────
        onSearchQuery: (query) {
          // ignore: avoid_print
          print('\n🔍 ══ SEARCH QUERY ═══════════════════════');
          // ignore: avoid_print
          print('   query : $query');
          // ignore: avoid_print
          print('═════════════════════════════════════════\n');
        },
      ),
    );
  }
}