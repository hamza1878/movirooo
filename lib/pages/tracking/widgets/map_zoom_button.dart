import 'package:flutter/material.dart';

class MapZoomButton extends StatelessWidget {
  const MapZoomButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.isDark,
  });

  final IconData     icon;
  final VoidCallback onTap;
  final bool         enabled;
  final bool         isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.75)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}