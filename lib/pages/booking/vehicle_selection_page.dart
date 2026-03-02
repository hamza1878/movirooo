import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

// ════════════════════════════════════════════════════════════════════════════
// RIDE BOOKING PAGE
//
//  • Map (image) shrinks as user scrolls down
//  • Car list scrolls below the map
//  • Each car card taps → navigate to next page
//  • "Continue" button → navigate with selected car
// ════════════════════════════════════════════════════════════════════════════

// ── GOOGLE MAPS API — uncomment when you have the key ──────────────────────
// STEP 1 : pubspec.yaml
//   dependencies:
//     google_maps_flutter: ^2.5.0
//     geolocator: ^10.1.0
//
// STEP 2 : android/app/src/main/AndroidManifest.xml  (inside <application>)
//   <meta-data android:name="com.google.android.geo.API_KEY"
//              android:value="YOUR_KEY"/>
//
// STEP 3 : ios/Runner/AppDelegate.swift
//   import GoogleMaps
//   GMSServices.provideAPIKey("YOUR_KEY")
//
// STEP 4 : ios/Runner/Info.plist
//   <key>NSLocationWhenInUseUsageDescription</key>
//   <string>Used to show your position on the map</string>
// ──────────────────────────────────────────────────────────────────────────

class RideBookingPage extends StatefulWidget {
  const RideBookingPage({super.key});

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  final ScrollController _scroll = ScrollController();
  double _mapHeight = 320.0;          // starting map height
  static const double _mapMin = 120.0; // smallest the map gets
  static const double _mapMax = 320.0;
  int _selectedCar = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scroll.offset.clamp(0.0, _mapMax - _mapMin);
    setState(() => _mapHeight = _mapMax - offset);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // ── Car data ─────────────────────────────────────────────────────────────
  static const _cars = [
    _CarOption(
      name: 'Economy',
      image: 'images/bmw.png',
      seats: 3,
      bags: 3,
      price: '€107.57',
      badge: 'BEST VALUE',
      badgeColor: Color(0xFF9B30FF),
    ),
    _CarOption(
      name: 'Business',
      image: 'images/bmw.png',
      seats: 3,
      bags: 2,
      price: '€154.00',
      badge: 'COMFORT',
      badgeColor: Color(0xFF2563EB),
    ),
    _CarOption(
      name: 'Van / SUV',
      image: 'images/bmw.png',
      seats: 6,
      bags: 5,
      price: '€189.90',
      badge: 'SPACIOUS',
      badgeColor: Color(0xFF059669),
    ),
    _CarOption(
      name: 'Premium',
      image: 'images/bmw.png',
      seats: 3,
      bags: 3,
      price: '€230.00',
      badge: 'LUXURY',
      badgeColor: Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          CustomScrollView(
            controller: _scroll,
            slivers: [
              // ── Map area (shrinks on scroll) ───────────────────────────
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration.zero, // instant — driven by scroll
                  height: _mapHeight,
                  child: _MapSection(height: _mapHeight),
                ),
              ),

              // ── Route info chips ───────────────────────────────────────
              SliverToBoxAdapter(child: _RouteInfoBar()),

              // ── Filter chips (Book for me / Extras) ───────────────────
              SliverToBoxAdapter(child: _FilterRow()),

              // ── VAT note ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _VatNote()),

              // ── Car list ───────────────────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _CarCard(
                    car: _cars[i],
                    isSelected: _selectedCar == i,
                    onTap: () {
                      setState(() => _selectedCar = i);
                      // Navigate to car detail / confirmation page
                      Navigator.pushNamed(
                        context,
                        '/car-detail',
                        arguments: _cars[i],
                      );
                    },
                  ),
                  childCount: _cars.length,
                ),
              ),

              // Bottom padding for Continue button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── Back button (floats over map) ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // ── Continue button (always at bottom) ────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _ContinueButton(
              car: _cars[_selectedCar],
              onTap: () => Navigator.pushNamed(
                context,
                '/booking-confirm',
                arguments: _cars[_selectedCar],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MAP SECTION
// ════════════════════════════════════════════════════════════════════════════
class _MapSection extends StatelessWidget {
  final double height;
  const _MapSection({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // ── VERSION A : local image ────────────────────────────────────
          // Replace with your own map screenshot
          Image.asset(
            'assets/images/map_preview.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter, // keeps top visible as it shrinks
            errorBuilder: (_, __, ___) => const _FallbackMap(),
          ),

          // ── VERSION B : Google Maps API ────────────────────────────────
          // Uncomment below and remove Image.asset above
          // Also import 'package:google_maps_flutter/google_maps_flutter.dart'
          //
          // _GoogleMapView(),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
              ),
            ),
          ),

          // Origin popup (top)
          Positioned(
            top: 60, left: 60,
            child: _LocationPopup(
              title: 'Tunis Carthage Air...',
              subtitle: 'Tunis, Tunisia',
              isOrigin: true,
            ),
          ),

          // Destination popup (bottom)
          Positioned(
            bottom: 28, left: 60,
            child: _LocationPopup(
              title: 'Enfidha Hammame...',
              subtitle: 'Enfidha, Tunisia',
              isOrigin: false,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google Maps VERSION B widget ──────────────────────────────────────────
// Uncomment this entire class when you have the API key
//
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
//
// class _GoogleMapView extends StatefulWidget {
//   @override
//   State<_GoogleMapView> createState() => _GoogleMapViewState();
// }
//
// class _GoogleMapViewState extends State<_GoogleMapView> {
//   GoogleMapController? _ctrl;
//   static const _tunis   = LatLng(36.8510, 10.2271); // Tunis Carthage Airport
//   static const _enfidha = LatLng(36.0757, 10.4386); // Enfidha Airport
//
//   static const _darkStyle = '''[
//     {"elementType":"geometry",          "stylers":[{"color":"#1a1a2e"}]},
//     {"elementType":"labels.text.fill",  "stylers":[{"color":"#9b30ff"}]},
//     {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a2e"}]},
//     {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a3e"}]},
//     {"featureType":"road","elementType":"geometry.stroke",
//      "stylers":[{"color":"#9b30ff"},{"weight":0.5}]},
//     {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d0d1a"}]},
//     {"featureType":"poi","stylers":[{"visibility":"off"}]}
//   ]''';
//
//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       initialCameraPosition: const CameraPosition(
//         target: LatLng(36.4500, 10.3000), // centre between the two airports
//         zoom: 9,
//       ),
//       onMapCreated: (c) { _ctrl = c; c.setMapStyle(_darkStyle); },
//       myLocationEnabled: false,
//       zoomControlsEnabled: false,
//       mapToolbarEnabled: false,
//       polylines: {
//         Polyline(
//           polylineId: const PolylineId('route'),
//           points: const [_tunis, _enfidha],
//           color: const Color(0xFF9B30FF),
//           width: 3,
//         ),
//       },
//       markers: {
//         Marker(markerId: const MarkerId('origin'),      position: _tunis,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)),
//         Marker(markerId: const MarkerId('destination'), position: _enfidha,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)),
//       },
//     );
//   }
// }

// ════════════════════════════════════════════════════════════════════════════
// LOCATION POPUP (shown over map)
// ════════════════════════════════════════════════════════════════════════════
class _LocationPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOrigin;
  const _LocationPopup({
    required this.title,
    required this.subtitle,
    required this.isOrigin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C26).withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOrigin)
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF9B30FF),
              ),
            )
          else
            const Icon(Icons.location_on, color: Color(0xFF9B30FF), size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 11)),
            ],
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.50), size: 16),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ROUTE INFO BAR  (54 min · 72 km)
// ════════════════════════════════════════════════════════════════════════════
class _RouteInfoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _InfoChip(icon: Icons.directions_car_outlined, label: '54 min · 72 km'),
          const SizedBox(width: 12),
          _InfoChip(icon: Icons.alt_route_rounded, label: '53 min · 71.4 km'),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.subtext(context), size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FILTER ROW  (Book for me · Extras & notes)
// ════════════════════════════════════════════════════════════════════════════
class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _DropdownChip(
              icon: Icons.person_outline_rounded,
              label: 'Book for me',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DropdownChip(
              icon: Icons.description_outlined,
              label: 'Extras & notes',
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DropdownChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.text(context), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.subtext(context), size: 20),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// VAT NOTE
// ════════════════════════════════════════════════════════════════════════════
class _VatNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.primaryPurple, size: 16),
          const SizedBox(width: 6),
          Text('All prices include VAT, fees and tolls',
              style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CAR CARD
// ════════════════════════════════════════════════════════════════════════════
class _CarCard extends StatelessWidget {
  final _CarOption car;
  final bool isSelected;
  final VoidCallback onTap;
  const _CarCard({
    required this.car,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Car image
            SizedBox(
              width: 110,
              height: 70,
              child: Image.asset(
                car.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.subtext(context),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name,
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          color: AppColors.subtext(context), size: 14),
                      const SizedBox(width: 3),
                      Text('${car.seats}',
                          style: AppTextStyles.bodySmall(context)),
                      const SizedBox(width: 10),
                      Icon(Icons.work_outline_rounded,
                          color: AppColors.subtext(context), size: 14),
                      const SizedBox(width: 3),
                      Text('${car.bags}',
                          style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: car.badgeColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      car.badge,
                      style: TextStyle(
                        color: car.badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(car.price,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text(context),
                    )),
                const SizedBox(height: 2),
                Text('Total price',
                    style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTINUE BUTTON
// ════════════════════════════════════════════════════════════════════════════
class _ContinueButton extends StatelessWidget {
  final _CarOption car;
  final VoidCallback onTap;
  const _ContinueButton({required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text('Continue', style: AppTextStyles.buttonPrimary),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FALLBACK MAP (decorative — shown when image not set)
// ════════════════════════════════════════════════════════════════════════════
class _FallbackMap extends StatelessWidget {
  const _FallbackMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D1A),
      child: CustomPaint(painter: _FallbackPainter()),
    );
  }
}

class _FallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 0.7;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Roads
    final road = Paint()
      ..color = const Color(0xFF252540)
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(0, 100), Offset(size.width, 180), road);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.55, size.height), road);
    // Route
    final route = Paint()
      ..color = const Color(0xFF9B30FF)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.20, size.height * 0.18)
      ..cubicTo(size.width * 0.35, size.height * 0.40,
          size.width * 0.55, size.height * 0.60,
          size.width * 0.75, size.height * 0.82);
    canvas.drawPath(path, route);
    // Dots
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.18),
        6, Paint()..color = const Color(0xFF9B30FF));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.82),
        6, Paint()..color = const Color(0xFF9B30FF));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.82),
        3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════════════════════════
// CAR OPTION MODEL
// ════════════════════════════════════════════════════════════════════════════
class _CarOption {
  final String name;
  final String image;
  final int seats;
  final int bags;
  final String price;
  final String badge;
  final Color badgeColor;

  const _CarOption({
    required this.name,
    required this.image,
    required this.seats,
    required this.bags,
    required this.price,
    required this.badge,
    required this.badgeColor,
  });
}