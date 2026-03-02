import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

// ════════════════════════════════════════════════════════════════════════════
// MAP PREVIEW WIDGET
//
//  VERSION A — Image (no API needed) ← USE THIS NOW
//  VERSION B — Google Maps API       ← uncomment when you have the API key
// ════════════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────────────
// WHEN READY FOR VERSION B — add to pubspec.yaml:
//   dependencies:
//     google_maps_flutter: ^2.5.0
//     geolocator: ^10.1.0
//     permission_handler: ^11.0.1
//
// ANDROID — android/app/src/main/AndroidManifest.xml inside <application>:
//   <meta-data android:name="com.google.android.geo.API_KEY"
//              android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
//
// IOS — ios/Runner/AppDelegate.swift:
//   import GoogleMaps
//   GMSServices.provideAPIKey("YOUR_KEY")
//
// IOS — ios/Runner/Info.plist:
//   <key>NSLocationWhenInUseUsageDescription</key>
//   <string>We need your location to show the map</string>
// ────────────────────────────────────────────────────────────────────────────


// ════════════════════════════════════════════════════════════════════════════
// VERSION A — IMAGE  (use this now, no API needed)
// ════════════════════════════════════════════════════════════════════════════
class MapPreview extends StatelessWidget {
  const MapPreview({super.key});

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

            // ── OPTION 1 : local asset ───────────────────────────────────
            // 1. Put a map screenshot in  assets/images/map_preview.png
            // 2. Add under flutter > assets in pubspec.yaml:
            //      - assets/images/map_preview.png
            Image.asset(
              'images/map_preview.png',
              fit: BoxFit.cover,
            ),

            // ── OPTION 2 : static Google Maps image (no plugin needed) ───
            // Just swap Image.asset above with Image.network below.
            // Fill in your API key — no plugin install required.
            //
            // Image.network(
            //   'https://maps.googleapis.com/maps/api/staticmap'
            //   '?center=36.8065,10.1815'
            //   '&zoom=13'
            //   '&size=600x300'
            //   '&maptype=roadmap'
            //   '&style=element:geometry|color:0x1a1a2e'
            //   '&style=element:labels.text.fill|color:0x9b30ff'
            //   '&key=YOUR_API_KEY',
            //   fit: BoxFit.cover,
            //   errorBuilder: (_, __, ___) => const _FallbackMapGrid(),
            // ),

            // ── Dark gradient overlay ────────────────────────────────────
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

            // ── LIVE MAP badge ───────────────────────────────────────────
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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