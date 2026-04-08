// lib/services/geocoding_service.dart
// ─────────────────────────────────────────────────────────────────
// Reverse-geocoding  : lat/lng  →  human-readable name
// Forward geocoding  : text query → list of LocationPoints
// Recent history     : persist & retrieve last N picks (SharedPrefs)
//
// Uses Nominatim (OpenStreetMap) — no API key required.
// Rate-limit: 1 req/s max per OSM policy (add caching as needed).
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_point.dart';

class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  static const _historyKey = 'moviroo_location_history';
  static const _maxHistory = 10;

  final _client = http.Client();

  // ── Reverse geocoding ─────────────────────────────────────────
  /// Converts (lat, lng) → LocationPoint with a human-readable name.
  /// Falls back to coordinate string on error.
  Future<LocationPoint> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=$lat&lon=$lng&accept-language=fr',
      );
      final res = await _client.get(uri, headers: _headers);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final address = body['address'] as Map<String, dynamic>? ?? {};

      // Build a concise name: neighbourhood / road / city
      final name = _buildName(address);
      final fullAddress = body['display_name'] as String? ?? name;

      return LocationPoint(lat: lat, lng: lng, name: name, address: fullAddress);
    } catch (_) {
      // Graceful fallback
      return LocationPoint(
        lat: lat,
        lng: lng,
        name: '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
      );
    }
  }

  // ── Forward / autocomplete search ─────────────────────────────
  /// Returns up to [limit] location suggestions for [query],
  /// biased toward Tunisia by default.
  Future<List<LocationPoint>> search(
    String query, {
    int limit = 5,
    String countryCode = 'tn',
  }) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=jsonv2&q=${Uri.encodeComponent(query)}'
        '&countrycodes=$countryCode&limit=$limit&accept-language=fr',
      );
      final res = await _client.get(uri, headers: _headers);
      if (res.statusCode != 200) return [];

      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        final lat = double.tryParse(m['lat']?.toString() ?? '') ?? 0;
        final lng = double.tryParse(m['lon']?.toString() ?? '') ?? 0;
        final displayName = m['display_name'] as String? ?? '';
        // Short name = first segment before first comma
        final name = displayName.split(',').first.trim();
        return LocationPoint(
          lat: lat,
          lng: lng,
          name: name,
          address: displayName,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Recent history ────────────────────────────────────────────
  Future<List<LocationPoint>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((s) {
          try {
            return LocationPoint.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<LocationPoint>()
        .toList();
  }

  Future<void> saveToHistory(LocationPoint point) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];

    // Remove duplicate lat/lng if present
    final updated = raw.where((s) {
      try {
        final p = LocationPoint.fromJson(
            jsonDecode(s) as Map<String, dynamic>);
        return p.lat != point.lat || p.lng != point.lng;
      } catch (_) {
        return true;
      }
    }).toList();

    updated.insert(0, jsonEncode(point.toJson()));
    if (updated.length > _maxHistory) updated.removeLast();

    await prefs.setStringList(_historyKey, updated);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Helpers ───────────────────────────────────────────────────
  static const _headers = {
    'User-Agent': 'MovirooApp/1.0 (contact@moviroo.tn)',
    'Accept-Language': 'fr',
  };

  String _buildName(Map<String, dynamic> address) {
    // Priority: neighbourhood > suburb > road > village > town > city
    final candidates = [
      address['neighbourhood'],
      address['suburb'],
      address['road'],
      address['village'],
      address['town'],
      address['city'],
      address['county'],
      address['state'],
    ];
    final parts = candidates
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .take(2)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Localisation';
  }
}