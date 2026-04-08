import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:moviroo/pages/search/models/location_point.dart';
import 'package:moviroo/pages/search/services/geocoding_service.dart';

import '../../../../theme/app_colors.dart';

class MapPickerPage extends StatefulWidget {
  final String title;
  final LatLng? initialPoint;

  const MapPickerPage({
    super.key,
    this.title = 'Choisir une localisation',
    this.initialPoint,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();

  late LatLng _center;
  LocationPoint? _currentPoint;
  bool _loadingGeocode = false;
  Timer? _debounce;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialPoint ?? const LatLng(36.8190, 10.1658);
    _reverseGeocode(_center);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ── Geocoding ──────────────────────────────────────────────────
void _onMapEvent(MapEvent event) {
  if (event is! MapEventMove) return;
  
  // ✅ Accepte seulement les gestes utilisateur
  final  gestureSources = {
    MapEventSource.dragStart,
    MapEventSource.onDrag,
    MapEventSource.dragEnd,
    MapEventSource.multiFingerGestureStart,
    MapEventSource.onMultiFinger,
    MapEventSource.multiFingerEnd,

  };
  
  if (!gestureSources.contains(event.source)) return;

  _center = event.camera.center;
  setState(() => _isDragging = true);

  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 600), () {
    setState(() {
      _isDragging = false;
      _loadingGeocode = true;
    });
    _reverseGeocode(_center);
  });
}
  Future<void> _reverseGeocode(LatLng pos) async {
    final point = await GeocodingService.instance.reverseGeocode(
      pos.latitude,
      pos.longitude,
    );
    if (!mounted) return;
    setState(() {
      _currentPoint = point;
      _loadingGeocode = false;
    });
  }

  // ── Confirm ────────────────────────────────────────────────────
  void _confirm() {
    if (_currentPoint == null) return;
    GeocodingService.instance.saveToHistory(_currentPoint!);
    Navigator.of(context).pop(_currentPoint);
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              minZoom: 3,
              maxZoom: 19,
              onMapEvent: _onMapEvent,  // ✅ fix
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.moviroo.app',
              ),
            ],
          ),

          // ── Centre pin ────────────────────────────────────────
          _CentrePin(isDragging: _isDragging),

          // ── Top bar ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: _TopBar(title: widget.title),
          ),

          // ── Bottom sheet ──────────────────────────────────────
          Positioned(
            bottom: bottomInset,
            left: 0,
            right: 0,
            child: _BottomSheet(
              point: _currentPoint,
              isLoading: _loadingGeocode || _isDragging,
              onConfirm: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════════

class _CentrePin extends StatelessWidget {
  final bool isDragging;
  const _CentrePin({required this.isDragging});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: isDragging ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isDragging ? 10 : 8,
              height: isDragging ? 5 : 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22,
              ),
            ),
            Container(width: 2, height: 14, color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.text(context),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final LocationPoint? point;
  final bool isLoading;
  final VoidCallback onConfirm;

  const _BottomSheet({
    required this.point,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? _ShimmerLine(width: 160, height: 14)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point?.name ?? '—',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                          ),
                          if (point?.address != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              point!.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.subtext(context),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),

          // Coordinates badge
          if (!isLoading && point != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${point!.lat.toStringAsFixed(6)},  ${point!.lng.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isLoading || point == null) ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                disabledBackgroundColor:
                    AppColors.primaryPurple.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirmer cette localisation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerLine({required this.width, required this.height});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.border(context),
            AppColors.surface(context),
            _ctrl.value,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}