import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../theme/app_colors.dart';
import 'widgets/map_tile_builder.dart' hide darkModeTileBuilder;
import 'widgets/route_service.dart';
import 'widgets/map_zoom_button.dart';
import 'widgets/map_marker.dart';
import 'widgets/map_live_badge.dart';
import 'widgets/map_eta_badge.dart';

class MapPreviewWidget extends StatefulWidget {
  const MapPreviewWidget({super.key});

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  final MapController _mapController = MapController();

  final LatLng _pickup  = const LatLng(36.848097, 10.217551); // Ariana
  final LatLng _dropoff = const LatLng(36.420177, 10.553902); // Hammamet

  double _zoom = 9;
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  List<LatLng> _routePoints = [];
  double       _distanceKm  = 0;
  int          _durationMins = 0;
  bool         _loadingRoute = true;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final result = await RouteService.getRoute(_pickup, _dropoff);
    if (!mounted) return;
    setState(() {
      _routePoints  = result?.points      ?? [_pickup, _dropoff];
      _distanceKm   = result?.distanceKm  ?? 0;
      _durationMins = result?.durationMins ?? 0;
      _loadingRoute = false;
    });
  }

  void _zoomIn() {
    if (_zoom >= _maxZoom) return;
    setState(() => _zoom++);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  void _zoomOut() {
    if (_zoom <= _minZoom) return;
    setState(() => _zoom--);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
const tileUrl = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── MAP ──────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  (_pickup.latitude  + _dropoff.latitude)  / 2,
                  (_pickup.longitude + _dropoff.longitude) / 2,
                ),
                initialZoom: _zoom,
                minZoom: _minZoom,
                maxZoom: _maxZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                         InteractiveFlag.pinchZoom |
                         InteractiveFlag.doubleTapZoom,
                ),
                onPositionChanged: (camera, _) => _zoom = camera.zoom!,
              ),
              children: [

                // Tuile OSM + filtre violet dark
             TileLayer(
  urlTemplate: tileUrl,
  userAgentPackageName: 'com.moviroo.app',
  tileBuilder: null, // ← plus besoin du filtre
),

                // Route OSRM
                if (_routePoints.isNotEmpty) ...[
                  if (isDark) ...[
                    // Halo extérieur
                    PolylineLayer(polylines: [
                      Polyline(
                        points: _routePoints,
                        color: const Color(0x33CC44FF),
                        strokeWidth: 20,
                      ),
                    ]),
                    // Halo intermédiaire
                    PolylineLayer(polylines: [
                      Polyline(
                        points: _routePoints,
                        color: const Color(0x88AA33EE),
                        strokeWidth: 10,
                      ),
                    ]),
                    // Ligne principale lumineuse
                    PolylineLayer(polylines: [
                      Polyline(
                        points: _routePoints,
                        color: const Color(0xFFDD55FF),
                        strokeWidth: 4.5,
                      ),
                    ]),
                  ] else
                    PolylineLayer(polylines: [
                      Polyline(
                        points: _routePoints,
                        color: AppColors.primaryPurple,
                        strokeWidth: 4.5,
                        borderColor: Colors.black.withOpacity(0.08),
                        borderStrokeWidth: 1.5,
                      ),
                    ]),
                ],

                // Marqueurs
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickup,
                      width: 44,
                      height: 44,
                      child: MapMarker(
                        icon: Icons.circle,
                        color: Colors.pinkAccent,
                        isDark: isDark,
                        isPickup: true,
                      ),
                    ),
                    Marker(
                      point: _dropoff,
                      width: 44,
                      height: 44,
                      child: MapMarker(
                        icon: Icons.circle,
                        color: Colors.white,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Loading spinner ───────────────────────────────────────────
            if (_loadingRoute)
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFDD55FF),
                  ),
                ),
              ),

            // ── Gradient overlay ──────────────────────────────────────────
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [Colors.transparent, Colors.black.withOpacity(0.28)]
                        : [Colors.black.withOpacity(0.08), Colors.black.withOpacity(0.25)],
                  ),
                ),
              ),
            ),

            // ── ETA badge (centre) ────────────────────────────────────────
            if (!_loadingRoute && _durationMins > 0)
              Center(
                child: MapEtaBadge(
                  durationMins: _durationMins,
                  distanceKm: _distanceKm,
                  isDark: isDark,
                ),
              ),

            // ── Badge LIVE MAP ────────────────────────────────────────────
            const Positioned(
              left: 12,
              bottom: 12,
              child: MapLiveBadge(),
            ),

            // ── Zoom +/- ──────────────────────────────────────────────────
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapZoomButton(
                    icon: Icons.add,
                    onTap: _zoomIn,
                    enabled: _zoom < _maxZoom,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  MapZoomButton(
                    icon: Icons.remove,
                    onTap: _zoomOut,
                    enabled: _zoom > _minZoom,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}