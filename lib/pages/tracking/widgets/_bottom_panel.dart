import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '_driver_row.dart';
import '_eta_row.dart';
import '_im_here_button.dart';
import '../_pickup_drop_row.dart';
import '../_trip_summary_card.dart';
import '../animated_progress_bar.dart';
import '../ride_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BottomPanel
// ─────────────────────────────────────────────────────────────────────────────

class BottomPanel extends StatefulWidget {
  final RideState rideState;
  final VoidCallback? onContinue;

  /// Called when the passenger taps "I'm Here" during the [RidePhase.driverArrived] phase.
  final VoidCallback? onImHere;

  /// Pickup location label shown in the pickup/drop row.
  final String pickupLabel;

  /// Drop-off location label shown in the pickup/drop row.
  final String dropLabel;

  const BottomPanel({
    super.key,
    required this.rideState,
    this.onContinue,
    this.onImHere,
    this.pickupLabel = 'Pickup location',
    this.dropLabel = 'Drop-off location',
  });

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  late final DraggableScrollableController _sheetCtrl;

  bool get _isArrivalOrLater =>
      widget.rideState.phase == RidePhase.driverArrived ||
      widget.rideState.phase == RidePhase.rideInProgress ||
      widget.rideState.phase == RidePhase.rideEnded;

  double _targetSize(RidePhase phase) {
    switch (phase) {
      case RidePhase.driverArrived:
        return 0.60;
      case RidePhase.rideEnded:
        return 0.75;
      default:
        return 0.50;
    }
  }

  @override
  void initState() {
    super.initState();
    _sheetCtrl = DraggableScrollableController();
  }

  @override
  void didUpdateWidget(BottomPanel old) {
    super.didUpdateWidget(old);
    if (widget.rideState.phase != old.rideState.phase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _sheetCtrl.isAttached) {
          _sheetCtrl.animateTo(
            _targetSize(widget.rideState.phase),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      controller: _sheetCtrl,
      initialChildSize: _targetSize(widget.rideState.phase),
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.18, 0.50, 0.60, 0.75, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.border(context))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                if (widget.rideState.phase == RidePhase.rideEnded)
                  TripSummaryCard(
                    rideState: widget.rideState,
                    pickupLabel: widget.pickupLabel,
                    dropLabel: widget.dropLabel,
                    onContinue: widget.onContinue,
                  )
                else ...[
                  EtaRow(rideState: widget.rideState),

                  const SizedBox(height: 16),

                  AnimatedRideProgressBar(
                    phase: widget.rideState.phase,
                    progress: widget.rideState.progress,
                  ),

                  const SizedBox(height: 20),

                  DriverRow(
                    driverName: widget.rideState.driverName,
                    vehicleName: widget.rideState.vehicleName,
                    isArrived: _isArrivalOrLater,
                  ),

                  const SizedBox(height: 20),

                  if (widget.rideState.phase == RidePhase.driverArrived) ...[
                    ImHereButton(onTap: widget.onImHere ?? () {}),
                    const SizedBox(height: 20),
                  ],

                  PickupDropRow(
                    pickupLabel: widget.pickupLabel,
                    dropLabel: widget.dropLabel,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
