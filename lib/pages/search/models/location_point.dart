// lib/models/location_point.dart
// ─────────────────────────────────────────────────────────────────
// Represents a user-selected map point: coordinates + display name.
// Used as the canonical type exchanged between map picker, search
// sheet, and the pricing engine.
// ─────────────────────────────────────────────────────────────────

import 'package:latlong2/latlong.dart';

class LocationPoint {
  final double lat;
  final double lng;

  /// Human-readable name shown in input fields (e.g. "Ariana Ville")
  final String name;

  /// Full address line returned by reverse-geocoding (optional)
  final String? address;

  const LocationPoint({
    required this.lat,
    required this.lng,
    required this.name,
    this.address,
  });

  LatLng get latLng => LatLng(lat, lng);

  /// Compact Python-style tuple string for passing to the pricing API
  /// Returns e.g. "(36.848097, 10.217551)"
  String get asTuple => '($lat, $lng)';

  /// Both points as Python-style variables ready to paste / send to API
  static String pricingParams(LocationPoint origin, LocationPoint destination) =>
      'lat_origin=${origin.lat}, lon_origin=${origin.lng}, '
      'lat_dest=${destination.lat}, lon_dest=${destination.lng}';

  @override
  String toString() => '$name [$lat, $lng]';

  @override
  bool operator ==(Object other) =>
      other is LocationPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'name': name,
        'address': address,
      };

  factory LocationPoint.fromJson(Map<String, dynamic> j) => LocationPoint(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        name: j['name'] as String,
        address: j['address'] as String?,
      );
}