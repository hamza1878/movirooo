import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../theme/app_colors.dart';

class MapPreviewWidget extends StatelessWidget {
  const MapPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [

            /// 🗺️ MAP (OpenStreetMap)
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(36.8065, 10.1815),
                initialZoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),

                /// 📍 MARKERS
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(36.848097, 10.217551),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                    ),
                    Marker(
                      point: LatLng(36.420177, 10.553902),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// 🌑 Overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.38),
                  ],
                ),
              ),
            ),

            /// 🟣 LIVE MAP badge
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE MAP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}