import 'package:flutter/material.dart';

class MapEtaBadge extends StatelessWidget {
  const MapEtaBadge({
    super.key,
    required this.durationMins,
    required this.distanceKm,
    required this.isDark,
  });

  final int    durationMins;
  final double distanceKm;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? const Color(0xFF1A1A2E).withOpacity(0.92)
        : Colors.white.withOpacity(0.92);

    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor  = isDark ? Colors.white60 : Colors.black45;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_rounded,
            color: isDark ? const Color.fromARGB(255, 255, 255, 255) : Colors.purple,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$durationMins min',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: subColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}