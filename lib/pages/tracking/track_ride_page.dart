import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
import '_bottom_panel.dart';
import '_trip_completed_overlay.dart';
import 'ride_state.dart';

/// Root page for the Track Ride feature.
///
/// Owns [RideState]. Phase transitions are triggered by your backend/socket
/// events — call [_advanceToArrived], [_advanceToRideStarted],
/// [_advanceToRideEnded] from your socket listener, not from UI buttons.
class TrackRidePage extends StatefulWidget {
  const TrackRidePage({super.key});

  @override
  State<TrackRidePage> createState() => _TrackRidePageState();
}

class _TrackRidePageState extends State<TrackRidePage>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  RideState _state = const RideState(
    phase: RidePhase.driverOnTheWay,
    progress: 0.0,
    etaMins: 7,
    arrivalTime: '14:17',
    distanceLeft: '1.2 mi',
    driverName: 'Alexander Wright',
    vehicleName: 'Tesla Model S',
    vehicleColor: 'White',
    plateNumber: 'ABC-1234',
    pickupAddress: '123 Main Street',
    dropoffAddress: '456 Oak Avenue',
  );

  // ── Simulated progress ticker ─────────────────────────────────────────────
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Ticks progress from 0 → 0.95 over 30 s while on-the-way or in-progress.
    // Replace with real location data in production.
    _progressCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..addListener(() {
            final trackable =
                _state.phase == RidePhase.driverOnTheWay ||
                _state.phase == RidePhase.rideInProgress;
            if (trackable) {
              setState(() {
                _state = _state.copyWith(
                  progress: (_progressCtrl.value * 0.95).clamp(0.0, 0.95),
                );
              });
            }
          })
          ..addStatusListener((status) {
            // Demo-only auto-transition when the simulated progress completes.
            // In production, trigger these from your socket/backend events instead.
            if (status == AnimationStatus.completed) {
              if (_state.phase == RidePhase.driverOnTheWay) {
                _advanceToArrived();
              } else if (_state.phase == RidePhase.rideInProgress) {
                _advanceToRideEnded();
              }
            }
          });

    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Phase transitions — call these from your socket/backend listener ───────

  /// Call when the backend signals the driver has arrived at the pickup point.
  void _advanceToArrived() {
    _progressCtrl.stop();
    HapticFeedback.mediumImpact(); // subtle vibration on arrival
    setState(() {
      _state = _state.copyWith(phase: RidePhase.driverArrived, progress: 1.0);
    });
  }

  /// Call when the driver confirms the passenger is in the car.
  void _advanceToRideStarted() {
    _progressCtrl.reset();
    _progressCtrl.forward();
    setState(() {
      _state = _state.copyWith(
        phase: RidePhase.rideInProgress,
        progress: 0.0,
        etaMins: 12,
        distanceLeft: '3.4 mi',
        arrivalTime: '14:29',
      );
    });
  }

  /// Call when the backend signals the trip has ended.
  void _advanceToRideEnded() {
    _progressCtrl.stop();
    HapticFeedback.lightImpact();
    setState(() {
      _state = _state.copyWith(phase: RidePhase.rideEnded, progress: 1.0);
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Map placeholder — replace with your map widget
            Container(color: const Color(0xFFE8EEF5)),

            // Bottom sheet
            BottomPanel(
              rideState: _state,
              onImHere: _advanceToRideStarted,
              onContinue: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),

            // Back button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.lightText,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // To wire real backend events, do something like this:
            //
            //   socketService.onDriverArrived.listen((_) => _advanceToArrived());
            //   socketService.onRideStarted.listen((_) => _advanceToRideStarted());
            //   socketService.onRideEnded.listen((_) => _advanceToRideEnded());
            //
            // ─────────────────────────────────────────────────────────────

            // Full-page overlay when the trip is complete
            if (_state.phase == RidePhase.rideEnded)
              TripCompletedOverlay(
                rideState: _state,
                onContinue: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
