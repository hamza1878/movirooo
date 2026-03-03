import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';

class RouteInfoBar extends StatelessWidget {
  const RouteInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          InfoChip(icon: Icons.directions_car_outlined, label: '54 min · 72 km'),
          const SizedBox(width: 12),
          InfoChip(icon: Icons.alt_route_rounded, label: '53 min · 71.4 km'),
        ],
      ),
    );
  }
}
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoChip({required this.icon, required this.label});

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
