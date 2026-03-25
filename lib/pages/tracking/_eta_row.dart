import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import 'ride_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ETA / headline row
// ─────────────────────────────────────────────────────────────────────────────

class EtaRow extends StatelessWidget {
  final RideState rideState;
  const EtaRow({super.key, required this.rideState});

  String _headline(RidePhase phase, AppLocalizations l10n, int mins) {
    switch (phase) {
      case RidePhase.driverOnTheWay:
        return l10n.translate('eta_mins_away').replaceAll('{mins}', '$mins');
      case RidePhase.driverArrived:
        return l10n.translate('driver_arrived');
      case RidePhase.rideInProgress:
        return l10n.translate('ride_in_progress');
      case RidePhase.rideEnded:
        return l10n.translate('trip_completed');
    }
  }

  Color _headlineColor(RidePhase phase) {
    switch (phase) {
      case RidePhase.driverArrived:
      case RidePhase.rideEnded:
        return const Color(0xFF4ADE80);
      default:
        return AppColors.lightText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = rideState.phase;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  _headline(phase, l10n, rideState.etaMins),
                  key: ValueKey(phase),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _headlineColor(phase),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  key: ValueKey(phase),
                  phase == RidePhase.driverOnTheWay
                      ? l10n
                            .translate('arriving_at')
                            .replaceAll('{time}', rideState.arrivalTime)
                            .replaceAll('{distance}', rideState.distanceLeft)
                      : phase == RidePhase.driverArrived
                      ? l10n.translate('meet_at_pickup')
                      : phase == RidePhase.rideInProgress
                      ? l10n
                            .translate('arriving_at')
                            .replaceAll('{time}', rideState.arrivalTime)
                            .replaceAll('{distance}', rideState.distanceLeft)
                      : '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.lightSubtext,
                  ),
                ),
              ),
            ],
          ),
        ),
        PremiumBadge(label: l10n.translate('vehicle_class_premium')),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium badge
// ─────────────────────────────────────────────────────────────────────────────

class PremiumBadge extends StatelessWidget {
  final String label;
  const PremiumBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryPurple,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
