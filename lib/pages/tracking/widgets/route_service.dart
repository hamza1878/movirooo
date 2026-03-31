import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMins;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMins,
  });
}

class RouteService {
  static Future<RouteResult?> getRoute(LatLng from, LatLng to) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final route = data['routes'][0];

      // Decode GeoJSON coordinates → LatLng list
      final coords = route['geometry']['coordinates'] as List;
      final points = coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      return RouteResult(
        points: points,
        distanceKm: (route['distance'] as num) / 1000,
        durationMins: ((route['duration'] as num) / 60).round(),
      );
    } catch (e) {
      return null;
    }
  }
}