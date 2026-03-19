import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DriverRow extends StatelessWidget {
  final String driverName;
  final String vehicleName;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onChatTap;

  const DriverRow({
    super.key,
    required this.driverName,
    required this.vehicleName,
    this.onPhoneTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.5),
              width: 2,
            ),
            color: const Color(0xFF2A1A4E),
          ),
          child: ClipOval(
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primaryPurple.withValues(alpha: 0.7),
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Name + vehicle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vehicleName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              asset: 'images/icons/phone-call.png',
              onTap: onPhoneTap ?? () {},
            ),
            const SizedBox(width: 10),
            _ActionButton(
              asset: 'images/icons/chat.png',
              onTap: onChatTap ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  const _ActionButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.darkBorder,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: ImageIcon(
            AssetImage(asset),
            size: 20,
            color: AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }
}