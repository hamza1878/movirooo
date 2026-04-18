class NavigationCommand {
  final String rawText;
  final String? destination;
  final String? origin;
  final String? time;
  final CommandType type;

  NavigationCommand({
    required this.rawText,
    this.destination,
    this.origin,
    this.time,
    required this.type,
  });

  /// Parse a voice phrase in French, English, or Arabic
  factory NavigationCommand.parse(String text) {
    final lower = text.toLowerCase().trim();

    // --- Destination keywords ---
    // FR: "aller à", "veux aller à", "destination", "vers", "à"
    // EN: "go to", "navigate to", "take me to", "directions to"
    // AR: "روح", "اذهب", "وجهة"
    final List<RegExp> destinationPatterns = [
      // French
      RegExp(r'(?:aller|allez|veux aller|je veux aller|je vais|partir)\s+(?:à|au|aux|vers|pour|a)\s+(.+?)(?:\s+from|\s+de|\s+depuis|\s+demain|\s+ghodwa|\s*$)', caseSensitive: false),
      RegExp(r'(?:destination|vers|direction)\s+(.+?)(?:\s+from|\s+de|\s+depuis|\s+demain|\s+ghodwa|\s*$)', caseSensitive: false),
      // English
      RegExp(r'(?:go to|navigate to|take me to|directions to|i want to go to)\s+(.+?)(?:\s+from|\s+tomorrow|\s*$)', caseSensitive: false),
      // Fallback: last noun after "à/to/a"
      RegExp(r'(?:à|au|to|a)\s+([a-zA-Zà-ÿ\s]{3,30}?)(?:\s+from|\s+de|\s*$)', caseSensitive: false),
    ];

    // --- Origin keywords ---
    final List<RegExp> originPatterns = [
      RegExp(r'(?:from|de|depuis|en partant de|partant de)\s+([a-zA-Zà-ÿ\s]{3,30})(?:\s|$)', caseSensitive: false),
    ];

    // --- Time keywords ---
    final List<RegExp> timePatterns = [
      RegExp(r"(demain|ghodwa|ghoudwa|ce soir|maintenant|tout de suite|tout à l'heure|dans une heure|tomorrow|tonight|now|later|next week)", caseSensitive: false),
    ];

    String? destination;
    String? origin;
    String? time;

    // Extract destination
    for (final RegExp pattern in destinationPatterns) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        destination = _cleanCapture(match.group(1));
        if (destination != null && destination.length > 2) break;
      }
    }

    // Extract origin
    for (final RegExp pattern in originPatterns) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        origin = _cleanCapture(match.group(1));
        if (origin != null && origin.length > 2) break;
      }
    }

    // Extract time
    for (final RegExp pattern in timePatterns) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        time = _cleanCapture(match.group(1));
        break;
      }
    }

    // Determine command type
    CommandType type = CommandType.unknown;
    if (lower.contains('aller') || lower.contains('allez') || lower.contains('go to') ||
        lower.contains('navigate') || lower.contains('directions') || lower.contains('destination')) {
      type = CommandType.navigate;
    } else if (lower.contains('météo') || lower.contains('weather')) {
      type = CommandType.weather;
    } else if (lower.contains('arrêt') || lower.contains('stop') || lower.contains('annuler')) {
      type = CommandType.stop;
    } else if (destination != null) {
      type = CommandType.navigate;
    }

    return NavigationCommand(
      rawText: text,
      destination: destination,
      origin: origin,
      time: time,
      type: type,
    );
  }

  static String? _cleanCapture(String? raw) {
    if (raw == null) return null;
    return raw
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String get summary {
    if (type == CommandType.navigate) {
      final parts = <String>[];
      if (destination != null) parts.add('📍 Destination: $destination');
      if (origin != null) parts.add('🚀 Départ: $origin');
      if (time != null) parts.add('🕐 Quand: $time');
      return parts.join('\n');
    }
    return rawText;
  }

  bool get hasDestination => destination != null && destination!.isNotEmpty;
}

enum CommandType { navigate, weather, stop, unknown }