import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

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



class RideBookingPage extends StatefulWidget {
  const RideBookingPage({super.key});

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  final ScrollController _scroll = ScrollController();
  double _mapHeight = 320.0;
static const double _mapMin = 120.0;
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

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: Duration.zero,
              height: _mapHeight,
              child: MapSection(height: _mapHeight),
            ),
          ),
        ],
      ),
    ],
  );
}
}
class MapSection extends StatelessWidget {
  final double height;
  const MapSection({super.key, required this.height});
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
            'images/map_preview.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter, // keeps top visible as it shrinks
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
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.45),
                ],
              ),
            ),
          ),

         

          // Destination popup (bottom)
         
        ],
      ),
    );
  }
}