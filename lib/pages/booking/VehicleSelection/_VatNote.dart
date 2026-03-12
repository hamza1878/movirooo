import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';

class VatNote extends StatelessWidget {
  const VatNote({super.key});

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