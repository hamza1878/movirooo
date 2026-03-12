import 'package:flutter/material.dart';
import 'package:moviroo/pages/tabs%20%5Bpassenger%5D/trajet/trajet_models.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class TripCardHeader extends StatelessWidget {
  final RideModel ride;
  const TripCardHeader({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: AppColors.iconBg(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _vehicleIcon(ride.vehicleIcon),
            color: AppColors.primaryPurple,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.vehicleType,
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${ride.date} • ${ride.vehicleName}',
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(fontSize: 12)),
            ],
          ),
        ),
        Text(
          '\$${ride.price.toStringAsFixed(2)}',
          style: AppTextStyles.priceMedium(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }

  IconData _vehicleIcon(String type) {
    switch (type) {
      case 'economy':
        return Icons.electric_bolt_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
