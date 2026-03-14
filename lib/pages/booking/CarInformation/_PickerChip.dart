import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class PickerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PickerChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryPurple),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }
}