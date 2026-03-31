import 'package:flutter/material.dart';

class MapMarker extends StatelessWidget {
  const MapMarker({
    super.key,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isPickup = false,
  });

  final IconData icon;
  final Color    color;
  final bool     isDark;
  final bool     isPickup;

  @override
  Widget build(BuildContext context) {
    if (isPickup) {
      // Marqueur départ style "pin" rose/rouge comme sur l'image
      return Stack(
        alignment: Alignment.center,
        children: [
          // Halo extérieur
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pinkAccent.withOpacity(0.18),
            ),
          ),
          // Cercle blanc
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // Icône
          const Icon(Icons.circle, color: Colors.pinkAccent, size: 16),
        ],
      );
    }

    // Marqueur arrivée : point blanc simple comme sur l'image
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.25),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}