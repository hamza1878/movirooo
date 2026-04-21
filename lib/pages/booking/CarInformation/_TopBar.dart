import 'package:flutter/material.dart';
import 'package:moviroo/pages/booking/CarInformation/booking.dart';
import 'package:moviroo/pages/booking/VehicleSelection/vehicle_selection_page.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onBack;

  const TopBar({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack ??
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/vehicle_selection_page');
                  }
                },
          ),
          Expanded(
            child: Text(
              t.translate('booking_summary'),
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