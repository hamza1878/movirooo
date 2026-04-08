// lib/features/booking/location_input_controller.dart
// ─────────────────────────────────────────────────────────────────
// ChangeNotifier that holds:
//   • origin     (departure)  LocationPoint?
//   • destination             LocationPoint?
//   • search history          List<LocationPoint>
//
// Exposes:
//   • pricingParams → ready-to-send Map for the FastAPI endpoint
//   • pythonTuples  → debug string "(lat, lng) / (lat, lng)"
//   • isReady       → both points are set
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:moviroo/pages/search/models/location_point.dart';
import 'package:moviroo/pages/search/services/geocoding_service.dart';

class LocationInputController extends ChangeNotifier {
  LocationPoint? _origin;
  LocationPoint? _destination;
  List<LocationPoint> _history = [];

  // ── Getters ───────────────────────────────────────────────────
  LocationPoint? get origin      => _origin;
  LocationPoint? get destination => _destination;
  List<LocationPoint> get history => List.unmodifiable(_history);

  bool get isReady => _origin != null && _destination != null;

  // ── Setters ───────────────────────────────────────────────────
  void setOrigin(LocationPoint point) {
    _origin = point;
    _addHistory(point);
    notifyListeners();
  }

  void setDestination(LocationPoint point) {
    _destination = point;
    _addHistory(point);
    notifyListeners();
  }

  void clearOrigin() {
    _origin = null;
    notifyListeners();
  }

  void clearDestination() {
    _destination = null;
    notifyListeners();
  }

  void swapPoints() {
    final tmp = _origin;
    _origin = _destination;
    _destination = tmp;
    notifyListeners();
  }

  // ── History ───────────────────────────────────────────────────
  Future<void> loadHistory() async {
    _history = await GeocodingService.instance.getHistory();
    notifyListeners();
  }

  void _addHistory(LocationPoint point) {
    _history.removeWhere((p) => p.lat == point.lat && p.lng == point.lng);
    _history.insert(0, point);
    if (_history.length > 10) _history.removeLast();
    GeocodingService.instance.saveToHistory(point);
  }

  Future<void> clearHistory() async {
    await GeocodingService.instance.clearHistory();
    _history = [];
    notifyListeners();
  }

  // ── Pricing ───────────────────────────────────────────────────
  /// Returns the Map body ready for POST /price/estimate or /price/quick
  Map<String, dynamic> get pricingParams {
    assert(isReady, 'Both origin and destination must be set before calling pricingParams');
    return {
      'lat_origin': _origin!.lat,
      'lon_origin': _origin!.lng,
      'lat_dest':   _destination!.lat,
      'lon_dest':   _destination!.lng,
    };
  }

  /// Python-style debug string matching the format used in main.py:
  /// "point1 = (36.848097, 10.217551)\npoint2 = (36.420177, 10.553902)"
  String get pythonTuples {
    if (!isReady) return '—';
    return 'point1 = ${_origin!.asTuple}\n'
           'point2 = ${_destination!.asTuple}';
  }

  /// Short one-liner e.g. "(36.85, 10.22) → (36.42, 10.55)"
  String get shortSummary {
    if (!isReady) return '—';
    return '${_origin!.asTuple} → ${_destination!.asTuple}';
  }
}