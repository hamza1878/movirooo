import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_SummaryCard.dart';
import '_PickerChip.dart';

class BookingSummaryCard extends StatelessWidget {
  final int pax;
  final int bags;
  final VoidCallback onPaxTap;
  final VoidCallback onBagsTap;

  const BookingSummaryCard({
    super.key,
    required this.pax,
    required this.bags,
    required this.onPaxTap,
    required this.onBagsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Row(
        children: [
          Image.asset('images/bmw.png',
              width: 90, height: 60, fit: BoxFit.contain),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Economy',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PickerChip(
                      icon: Icons.person_outline_rounded,
                      label: '$pax pax',
                      onTap: onPaxTap,
                    ),
                    const SizedBox(width: 8),
                    PickerChip(
                      icon: Icons.luggage_outlined,
                      label: '$bags lug',
                      onTap: onBagsTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}