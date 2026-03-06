import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class PassengerCard extends StatelessWidget {
  const PassengerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          PassengerRow(
            icon: Icons.person_outline_rounded,
            label: 'Main passenger',
            value: 'Aymen Ben Nacer',
            editable: false,
          ),
          Divider(height: 1, color: AppColors.border(context)),
          PassengerRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'aymenpower99@gmail.com',
            editable: true,
          ),
          Divider(height: 1, color: AppColors.border(context)),
          PassengerRow(
            icon: Icons.phone_outlined,
            label: 'Phone number',
            value: '+21694338510',
            editable: true,
          ),
        ],
      ),
    );
  }
}

class PassengerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool editable;

  const PassengerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.editable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmall(context)
                        .copyWith(color: AppColors.subtext(context))),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (editable)
            Icon(Icons.edit_outlined,
                size: 18, color: AppColors.subtext(context)),
        ],
      ),
    );
  }
}