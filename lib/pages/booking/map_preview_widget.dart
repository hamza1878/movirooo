// lib/features/booking/widgets/map_preview_widget.dart
// ─────────────────────────────────────────────────────────────────
// Dynamic MapPreviewWidget driven by LocationInputController.
//
// Changes vs original:
//  • Pickup / dropoff read from controller (live updates via listener)
//  • Tap pickup marker  → re-opens MapPickerPage for origin
//  • Tap dropoff marker → re-opens MapPickerPage for destination
//  • Route auto-reloads when points change
//  • Falls back to default coords when controller has no points yet
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:moviroo/pages/booking/location_input_controller.dart';
import 'package:moviroo/pages/booking/map_picker_page.dart';
import 'package:moviroo/pages/search/models/location_point.dart';
import 'package:moviroo/pages/tracking/widgets/map_eta_badge.dart';
import 'package:moviroo/pages/tracking/widgets/map_live_badge.dart';
import 'package:moviroo/pages/tracking/widgets/map_marker.dart';
import 'package:moviroo/pages/tracking/widgets/map_zoom_button.dart';
import 'package:moviroo/pages/tracking/widgets/route_service.dart';
import 'package:moviroo/theme/app_colors.dart';



class MapPreviewWidget extends StatefulWidget {
  /// Inject the shared controller so the map reacts to location picks
  final LocationInputController controller;

  const MapPreviewWidget({
    super.key,
    required this.controller,
  });

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  final MapController _mapController = MapController();

  // Default fallback coords (Ariana → Hammamet)
  static const _defaultPickup  = LatLng(36.848097, 10.217551);
  static const _defaultDropoff = LatLng(36.420177, 10.553902);

  double _zoom = 9;
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  List<LatLng> _routePoints  = [];
  double       _distanceKm   = 0;
  int          _durationMins = 0;
  bool         _loadingRoute = true;

  LatLng get _pickup  =>
      widget.controller.origin?.latLng ?? _defaultPickup;
  LatLng get _dropoff =>
      widget.controller.destination?.latLng ?? _defaultDropoff;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _loadRoute();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // Reload route whenever origin or destination changes
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() => _loadingRoute = true);
    final result = await RouteService.getRoute(_pickup, _dropoff);
    if (!mounted) return;
    setState(() {
      _routePoints  = result?.points       ?? [_pickup, _dropoff];
      _distanceKm   = result?.distanceKm   ?? 0;
      _durationMins = result?.durationMins ?? 0;
      _loadingRoute = false;
    });

    // Re-centre the map to fit both markers
    _fitBounds();
  }

  void _fitBounds() {
    final bounds = LatLngBounds.fromPoints([_pickup, _dropoff]);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    } catch (_) {}
  }

  void _zoomIn()  {
    if (_zoom >= _maxZoom) return;
    setState(() => _zoom++);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  void _zoomOut() {
    if (_zoom <= _minZoom) return;
    setState(() => _zoom--);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  // ── Re-pick a point by opening the map picker ────────────────
  Future<void> _repickOrigin() async {
    final picked = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: 'Modifier le départ',
          initialPoint: _pickup,
        ),
      ),
    );
    if (picked != null) {
      widget.controller.setOrigin(picked);
    }
  }

  Future<void> _repickDestination() async {
    final picked = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: 'Modifier la destination',
          initialPoint: _dropoff,
        ),
      ),
    );
    if (picked != null) {
      widget.controller.setDestination(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

            // ── Map ─────────────────────────────────────────────
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
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.moviroo.app',
                ),

                // Route polyline
                if (_routePoints.isNotEmpty) ...[
                  if (isDark) ...[
                    PolylineLayer(polylines: [Polyline(points: _routePoints, color: const Color(0x33CC44FF), strokeWidth: 20)]),
                    PolylineLayer(polylines: [Polyline(points: _routePoints, color: const Color(0x88AA33EE), strokeWidth: 10)]),
                    PolylineLayer(polylines: [Polyline(points: _routePoints, color: const Color(0xFFDD55FF), strokeWidth: 4.5)]),
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

                // Tappable markers
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickup,
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: _repickOrigin,
                        child: MapMarker(
                          icon: Icons.circle,
                          color: Colors.pinkAccent,
                          isDark: isDark,
                          isPickup: true,
                        ),
                      ),
                    ),
                    Marker(
                      point: _dropoff,
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: _repickDestination,
                        child: MapMarker(
                          icon: Icons.circle,
                          color: const Color.fromARGB(255, 8, 184, 37),
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Loading ─────────────────────────────────────────
            if (_loadingRoute)
              const Center(
                child: SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFDD55FF),
                  ),
                ),
              ),

            // ── Gradient overlay ────────────────────────────────
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

            // ── Point labels (top-left) ─────────────────────────
            Positioned(
              top: 10,
              left: 10,
              child: _PointLabels(
                origin:      widget.controller.origin,
                destination: widget.controller.destination,
              ),
            ),

            // ── ETA badge ───────────────────────────────────────
            if (!_loadingRoute && _durationMins > 0)
              Center(
                child: MapEtaBadge(
                  durationMins: _durationMins,
                  distanceKm: _distanceKm,
                  isDark: isDark,
                ),
              ),

            // ── LIVE badge ──────────────────────────────────────
            const Positioned(left: 12, bottom: 12, child: MapLiveBadge()),

            // ── Zoom buttons ────────────────────────────────────
            Positioned(
              right: 12, bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapZoomButton(icon: Icons.add,    onTap: _zoomIn,  enabled: _zoom < _maxZoom, isDark: isDark),
                  const SizedBox(height: 4),
                  MapZoomButton(icon: Icons.remove, onTap: _zoomOut, enabled: _zoom > _minZoom, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating point-name labels ────────────────────────────────
class _PointLabels extends StatelessWidget {
  final LocationPoint? origin;
  final LocationPoint? destination;
  const _PointLabels({this.origin, this.destination});

  @override
  Widget build(BuildContext context) {
    if (origin == null && destination == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (origin != null)
          _Label(text: origin!.name, dot: Colors.pinkAccent),
        if (destination != null)
          _Label(text: destination!.name, dot: const Color.fromARGB(255, 8, 184, 37)),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color dot;
  const _Label({required this.text, required this.dot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}