import 'package:flutter/material.dart';
import 'package:moviroo/pages/booking/CarInformation/booking.dart';
import 'package:moviroo/pages/booking/VehicleSelection/vehicle_selection_page.dart';
import '../../../../theme/app_text_styles.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
         IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  },
),
  

   
          Expanded(
            child: Text(
              'Booking Summary',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}