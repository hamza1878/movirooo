import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_assistant_state.dart';

class AiAssistantController extends ChangeNotifier {
  // ─────────────────────────────────────────────
  // CONFIGURATION
  // ─────────────────────────────────────────────

  static const String _apiBase = 'http://192.168.1.18:8000';

  String language;
  
  // ✅ Stocker le contexte de manière sécurisée
  BuildContext? _context;
  
  // ✅ Setter sécurisé avec vérification
  void attachToContext(BuildContext context) {
    _context = context;
  }
  
  // ✅ Nettoyage explicite
  void detachFromContext() {
    _context = null;
  }

  AiAssistantController({
    this.language = 'EN',
  });

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  AssistantModel _model = const AssistantModel();
  AssistantModel get model => _model;

  final List<Map<String, dynamic>> _conversationHistory = [];

  // ─────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────

  Future<void> toggleListening() async {
    if (_model.state == AssistantState.listening) {
      await _stopListening();
    } else if (_model.state == AssistantState.idle) {
      await _startListening();
    }
  }

  void setLanguage(String lang) {
    language = lang.toUpperCase();
    _conversationHistory.clear();
    notifyListeners();
  }

  void close() {
    _model = const AssistantModel();
    _conversationHistory.clear();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // LISTENING FLOW
  // ─────────────────────────────────────────────

  Future<void> _startListening() async {
    _setModel(_model.copyWith(
      state: AssistantState.listening,
      transcript: '',
      highlighted: '',
    ));

    // Simule l'écoute — à remplacer par STT réel (speech_to_text)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (_model.state == AssistantState.listening) {
      await _stopListening();
    }
  }

  Future<void> _stopListening() async {
    // ✅ Vérification sécurisée du contexte
    if (_context == null || !_context!.mounted) {
      _setModel(_model.copyWith(state: AssistantState.idle));
      return;
    }
    
    // Récupère la saisie utilisateur via dialog modal
    final userText = await _getUserInput();

    // Si l'utilisateur annule ou saisit rien → retour idle
    if (userText.trim().isEmpty) {
      _setModel(_model.copyWith(state: AssistantState.idle));
      return;
    }

    // Appel API dialog MOVIROO
    final botResponse = await _callDialogApi(userText.trim());

    _setModel(_model.copyWith(
      state: AssistantState.saying,
      transcript: botResponse.question,
      highlighted: botResponse.highlighted,
    ));

    await _speak(botResponse.question);
  }

  // ─────────────────────────────────────────────
  // USER INPUT DIALOG - VERSION SÉCURISÉE
  // ─────────────────────────────────────────────

  Future<String> _getUserInput() async {
    // ✅ Vérifications multiples de sécurité
    if (_context == null) {
      debugPrint('❌ Erreur: Contexte null dans _getUserInput');
      return '';
    }
    
    if (!_context!.mounted) {
      debugPrint('❌ Erreur: Contexte non monté dans _getUserInput');
      return '';
    }

    try {
      return await showDialog<String>(
            context: _context!,
            barrierDismissible: false,
            builder: (ctx) {
              String input = '';
              return AlertDialog(
                title: Text(_inputTitle()),
                content: TextField(
                  autofocus: true,
                  onChanged: (v) => input = v,
                  onSubmitted: (v) => Navigator.pop(ctx, v),
                  decoration: InputDecoration(
                    hintText: _inputHint(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, ''),
                    child: Text(_cancelLabel()),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, input),
                    child: Text(_confirmLabel()),
                  ),
                ],
              );
            },
          ) ??
          '';
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'affichage du dialog: $e');
      return '';
    }
  }

  // ─────────────────────────────────────────────
  // API CALL → POST /dialog
  // ─────────────────────────────────────────────

  Future<_DialogResponse> _callDialogApi(String userText) async {
    try {
      // Ajout au contexte de conversation
      _conversationHistory.add({
        'role': 'user',
        'text': userText,
      });

      final response = await http
          .post(
            Uri.parse('$_apiBase/dialog'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'text': userText,
              'lang': language,
              'history': _conversationHistory,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Ajout réponse assistant à l'historique
        _conversationHistory.add({
          'role': 'assistant',
          'text': data['question'] ?? '',
        });

        // Si la réservation est complète → on peut notifier l'UI
        final isComplete = data['complete'] ?? false;
        if (isComplete) {
          _onBookingComplete(data['result']);
        }

        return _DialogResponse(
          question: data['question'] ?? _fallbackQuestion(),
          highlighted: data['highlighted'] ?? '',
          isComplete: isComplete,
        );
      } else {
        debugPrint('MOVIROO API error: ${response.statusCode} — ${response.body}');
        return _DialogResponse(
          question: _fallbackQuestion(),
          highlighted: '',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('MOVIROO network error: $e');
      return _DialogResponse(question: _networkErrorMessage(), highlighted: '');
    } catch (e) {
      debugPrint('MOVIROO unexpected error: $e');
      return _DialogResponse(question: _fallbackQuestion(), highlighted: '');
    }
  }

  // ─────────────────────────────────────────────
  // BOOKING COMPLETE CALLBACK
  // ─────────────────────────────────────────────

  void _onBookingComplete(Map<String, dynamic>? result) {
    if (result == null) return;
    debugPrint(
      'MOVIROO booking complete — '
      'dest=${result['destination']} '
      'dep=${result['departure']} '
      'date=${result['date']} '
      'time=${result['time']}',
    );
    // TODO : naviguer vers l'écran de confirmation de réservation
    // Option sécurisée pour la navigation:
    if (_context != null && _context!.mounted) {
      Navigator.pushNamed(_context!, '/booking-confirm', arguments: result);
    }
  }

  // ─────────────────────────────────────────────
  // SPEAK (simulé — remplacer par flutter_tts)
  // ─────────────────────────────────────────────

  Future<void> _speak(String text) async {
    // Durée proportionnelle à la longueur du texte
    final duration = Duration(milliseconds: 800 + text.length * 30);
    await Future.delayed(duration);

    if (_model.state == AssistantState.saying) {
      _setModel(_model.copyWith(state: AssistantState.idle));
    }
  }

  // ─────────────────────────────────────────────
  // LABELS MULTILINGUES
  // ─────────────────────────────────────────────

  String _fallbackQuestion() {
    const fallbacks = {
      'FR': 'Où souhaitez-vous aller ?',
      'EN': 'Where would you like to go?',
      'AR': 'إلى أين تريد الذهاب؟',
      'TN': 'Wein tebghi temchi?',
    };
    return fallbacks[language] ?? fallbacks['EN']!;
  }

  String _networkErrorMessage() {
    const messages = {
      'FR': 'Connexion impossible. Veuillez réessayer.',
      'EN': 'Connection failed. Please try again.',
      'AR': 'فشل الاتصال. حاول مرة أخرى.',
      'TN': 'Mafamach connexion. 3awd el-kalem.',
    };
    return messages[language] ?? messages['EN']!;
  }

  String _inputTitle() {
    const titles = {
      'FR': 'Votre demande',
      'EN': 'Your request',
      'AR': 'طلبك',
      'TN': 'Chnou tebghi?',
    };
    return titles[language] ?? titles['EN']!;
  }

  String _inputHint() {
    const hints = {
      'FR': 'ex: taxi vers Tunis demain matin',
      'EN': 'e.g. taxi to Tunis tomorrow morning',
      'AR': 'مثال: تاكسي إلى تونس غدا صباحا',
      'TN': 'ex: taxi lel tunis ghodwa sbeh',
    };
    return hints[language] ?? hints['EN']!;
  }

  String _cancelLabel() {
    const labels = {
      'FR': 'Annuler',
      'EN': 'Cancel',
      'AR': 'إلغاء',
      'TN': 'Batel',
    };
    return labels[language] ?? labels['EN']!;
  }

  String _confirmLabel() {
    const labels = {
      'FR': 'Envoyer',
      'EN': 'Send',
      'AR': 'إرسال',
      'TN': 'Yalla',
    };
    return labels[language] ?? labels['EN']!;
  }

  // ─────────────────────────────────────────────
  // MODEL UPDATE
  // ─────────────────────────────────────────────

  void _setModel(AssistantModel m) {
    _model = m;
    notifyListeners();
  }
  
  @override
  void dispose() {
    detachFromContext(); // ✅ Nettoyage sécurisé
    super.dispose();
  }
}

// ─────────────────────────────────────────────
// RESPONSE MODEL
// ─────────────────────────────────────────────

class _DialogResponse {
  final String question;
  final String highlighted;
  final bool isComplete;

  const _DialogResponse({
    required this.question,
    required this.highlighted,
    this.isComplete = false,
  });
}