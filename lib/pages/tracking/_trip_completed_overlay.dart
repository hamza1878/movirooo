import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import 'ride_state.dart';

// -----------------------------------------------------------------------------
// Full-page trip-completed overlay — light mode, no scroll
// -----------------------------------------------------------------------------

class TripCompletedOverlay extends StatefulWidget {
  final RideState rideState;
  final VoidCallback onContinue;

  const TripCompletedOverlay({
    super.key,
    required this.rideState,
    required this.onContinue,
  });

  @override
  State<TripCompletedOverlay> createState() => _TripCompletedOverlayState();
}

class _TripCompletedOverlayState extends State<TripCompletedOverlay> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const green  = Color(0xFF16A34A);
    const amber  = Color(0xFFD97706);
    const purple = AppColors.primaryPurple;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 32 * (1 - t)),
          child: child,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // -- Animated check icon -----------------------------------
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFDCFCE7),
                        border: Border.all(
                          color: green.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: green,
                        size: 44,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // -- Title -------------------------------------------------
                Text(
                  l10n.translate('trip_completed'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have arrived at your destination',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.lightSubtext,
                  ),
                ),

                const Spacer(flex: 2),

                // -- Stats row ---------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.route_rounded,
                        label: 'Distance',
                        value: widget.rideState.distanceLeft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.schedule_rounded,
                        label: 'Arrived at',
                        value: widget.rideState.arrivalTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // -- Driver card -------------------------------------------
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.iconBgLight,
                          border: Border.all(
                            color: purple.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Icon(
                            Icons.person_rounded,
                            color: purple,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rideState.driverName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightText,
                              ),
                            ),
                            Text(
                              widget.rideState.vehicleName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.lightSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Icon(
                                i < _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: i < _rating
                                    ? amber
                                    : const Color(0xFFD1D5DB),
                                size: 24,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // -- Route card --------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: purple,
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 26,
                            color: AppColors.lightBorder,
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: amber, width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AddressLine(
                              label: 'PICKUP',
                              address: widget.rideState.pickupAddress.isNotEmpty
                                  ? widget.rideState.pickupAddress
                                  : 'Pickup location',
                              labelColor: purple,
                            ),
                            const SizedBox(height: 8),
                            _AddressLine(
                              label: 'DROP-OFF',
                              address: widget.rideState.dropoffAddress.isNotEmpty
                                  ? widget.rideState.dropoffAddress
                                  : 'Drop-off location',
                              labelColor: amber,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // -- Continue button ---------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.translate('continue'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.iconBgLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 17),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppColors.lightSubtext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class _AddressLine extends StatelessWidget {
  final String label;
  final String address;
  final Color labelColor;
  const _AddressLine({
    super.key,
    required this.label,
    required this.address,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          address,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Aliases for any external callers
class OverlayStatChip extends _StatChip {
  const OverlayStatChip({
    super.key,
    required super.icon,
    required super.label,
    required super.value,
  });
}

class LocationLine extends _AddressLine {
  const LocationLine({
    super.key,
    required super.label,
    required super.address,
    required super.labelColor,
  });
}
