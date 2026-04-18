import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/voice_service.dart';
import '../models/navigation_command.dart';
import '../widgets/voice_button.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final VoiceService _voiceService = VoiceService();

  bool _isListening = false;
  bool _isInitialized = false;
  String _interimText = '';
  NavigationCommand? _lastCommand;
  final List<NavigationCommand> _history = [];
  String _statusMessage = 'Appuyez sur le micro pour parler';
  String? _selectedLocale;

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _purpleLight = Color(0xFFEEEDFE);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final granted = await _requestMicPermission();
    if (!granted) {
      setState(() => _statusMessage = '⚠️ Permission micro refusée');
      return;
    }

    final ok = await _voiceService.initialize();
    setState(() {
      _isInitialized = ok;
      _selectedLocale = _voiceService.activeLocale;
      _statusMessage = ok
          ? 'Prêt · Langue: ${_friendlyLocale(_selectedLocale)}'
          : '⚠️ Reconnaissance vocale non disponible';
    });
  }

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      _showToast('❌ Service non initialisé', isError: true);
      return;
    }

    if (_isListening) {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = 'Traitement en cours…';
      });
    } else {
      setState(() {
        _isListening = true;
        _interimText = '';
        _statusMessage = '🎤 En écoute… Parlez maintenant';
      });

      await _voiceService.startListening(
        localeId: _selectedLocale,
        onResult: (text, isFinal) {
          setState(() => _interimText = text);

          if (isFinal && text.trim().isNotEmpty) {
            _processCommand(text.trim());
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = _interimText.isEmpty
                  ? 'Aucune parole détectée. Réessayez.'
                  : 'Prêt · Langue: ${_friendlyLocale(_selectedLocale)}';
            });
          }
        },
      );
    }
  }

  void _processCommand(String text) {
    final command = NavigationCommand.parse(text);

    setState(() {
      _lastCommand = command;
      _history.insert(0, command);
      if (_history.length > 10) _history.removeLast();
      _statusMessage = 'Prêt · Langue: ${_friendlyLocale(_selectedLocale)}';
    });

    // Show toast with the recognized text
    _showToast('🗣️ "$text"', isError: false);

    // Show navigation toast if destination found
    if (command.hasDestination) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _showToast(
          '📍 Navigation → ${command.destination}'
          '${command.origin != null ? '\n🚀 De: ${command.origin}' : ''}'
          '${command.time != null ? '\n🕐 ${command.time}' : ''}',
          isError: false,
          duration: Toast.LENGTH_LONG,
        );
      });
    }
  }

  void _showToast(String message, {
    bool isError = false,
    Toast duration = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration == Toast.LENGTH_LONG ? 4 : 2,
      backgroundColor: isError
          ? const Color(0xFFC0392B)
          : const Color(0xFF2D2D2D),
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  String _friendlyLocale(String? locale) {
    if (locale == null) return 'Auto';
    if (locale.startsWith('fr')) return '🇫🇷 Français';
    if (locale.startsWith('ar')) return '🇹🇳 Arabe';
    if (locale.startsWith('en')) return '🇬🇧 English';
    return locale;
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  // ───────────────────────────── UI ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildListeningCard(),
                  const SizedBox(height: 20),
                  if (_lastCommand != null) _buildCommandCard(_lastCommand!),
                  const SizedBox(height: 20),
                  if (_history.isNotEmpty) _buildHistory(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.navigation_rounded, color: _purple, size: 24),
          SizedBox(width: 8),
          Text(
            'Voice Navigator',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Locale picker
        PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: _purple),
          tooltip: 'Changer la langue',
          itemBuilder: (ctx) {
            return _voiceService.availableLocales.map((locale) {
              return PopupMenuItem(
                value: locale.localeId,
                child: Text(
                  '${_friendlyLocale(locale.localeId)} (${locale.localeId})',
                  style: TextStyle(
                    fontWeight: locale.localeId == _selectedLocale
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList();
          },
          onSelected: (id) {
            setState(() => _selectedLocale = id);
            _voiceService.setLocale(id);
            _showToast('Langue: ${_friendlyLocale(id)}');
          },
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? Colors.red
                  : _isInitialized
                      ? Colors.green
                      : Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Suggestion chips
          if (!_isListening) ...[
            const Text(
              'Essayez de dire :',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildChip('Je veux aller à Tunisia'),
                _buildChip('Je veux aller ghodwa à Tunisia from Hammamet'),
                _buildChip('Navigate to Sousse'),
                _buildChip('Aller à Tunis depuis Sfax'),
              ],
            ),
            const SizedBox(height: 28),
          ],

          // Interim text box
          if (_interimText.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _purple.withOpacity(0.3)),
              ),
              child: Text(
                '"$_interimText"',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3C3489),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (_isListening && _interimText.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'En écoute…',
                style: TextStyle(
                  fontSize: 15,
                  color: _purple.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Mic button
          VoiceButton(
            isListening: _isListening,
            onTap: _toggleListening,
            activeColor: _purple,
            inactiveColor: const Color(0xFF9E9E9E),
          ),

          const SizedBox(height: 16),
          Text(
            _isListening ? 'Appuyez pour arrêter' : 'Appuyez pour parler',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return GestureDetector(
      onTap: () => _processCommand(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _purpleLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _purple.withOpacity(0.3)),
        ),
        child: Text(
          '"$text"',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF534AB7),
          ),
        ),
      ),
    );
  }

  Widget _buildCommandCard(NavigationCommand command) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route_rounded, color: _purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Dernière commande',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Raw text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${command.rawText}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ),
          ),

          if (command.hasDestination) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on_rounded, 'Destination',
                command.destination!, Colors.red),
          ],
          if (command.origin != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.my_location_rounded, 'Départ',
                command.origin!, Colors.blue),
          ],
          if (command.time != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time_rounded, 'Quand',
                command.time!, Colors.orange),
          ],

          if (command.hasDestination) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showToast(
                    '🗺️ Lancement navigation vers ${command.destination}…'),
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: const Text('Lancer la navigation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF555555),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        ...(_history.skip(1).take(5).map((cmd) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHistoryItem(cmd),
            ))),
      ],
    );
  }

  Widget _buildHistoryItem(NavigationCommand cmd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cmd.rawText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
          ),
          if (cmd.hasDestination) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cmd.destination!,
                style: const TextStyle(
                    fontSize: 11,
                    color: _purple,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAction(Icons.refresh_rounded, 'Réinitialiser', () {
            setState(() {
              _interimText = '';
              _lastCommand = null;
              _history.clear();
            });
          }),
          _buildQuickAction(Icons.language_rounded, _friendlyLocale(_selectedLocale), () {
            // handled by appbar menu
          }),
          _buildQuickAction(Icons.settings_rounded, 'Paramètres', () {
            _showToast('⚙️ Paramètres à venir');
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
