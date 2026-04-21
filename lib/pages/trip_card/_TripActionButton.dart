import 'package:flutter/material.dart';
import 'package:moviroo/pages/tabs%20%5Bpassenger%5D/trajet/trajet_models.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class TripActionButton extends StatelessWidget {
  final RideModel ride;
  const TripActionButton({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    switch (ride.status) {

      case RideStatus.upcoming:
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/trip-card');
                  }
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.near_me_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Track Ride',
                          style: AppTextStyles.buttonPrimary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _MoreButton(),
          ],
        );

      case RideStatus.completed:
        return _OutlineBtn(
          label: 'Book Again',
          color: AppColors.primaryPurple,
          onTap: () {},
        );

      case RideStatus.cancelled:
        return _OutlineBtn(
          label: 'Cancelled',
          color: AppColors.error,
          onTap: () {},
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Icon(Icons.more_horiz_rounded,
            color: AppColors.subtext(context), size: 22),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              )),
        ),
      ),
    );
  }
}
