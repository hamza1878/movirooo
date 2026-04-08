// lib/features/booking/widgets/next_destination_search.dart
// ─────────────────────────────────────────────────────────────────
// Complete rewrite that integrates:
//  • "Select on map" → opens MapPickerPage → fills input field
//  • Text search     → Nominatim autocomplete → fills input field
//  • History reuse   → tap recent location → fills input field
//  • Two-step flow:  origin first, then destination
//  • On completion:  returns two LocationPoints to parent via
//                    onBothPointsReady callback
// ─────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:moviroo/pages/booking/location_input_controller.dart';
import 'package:moviroo/pages/booking/map_picker_page.dart';
import 'package:moviroo/pages/search/models/location_point.dart';
import 'package:moviroo/pages/search/services/geocoding_service.dart';

import '../../../../theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════
// Public widget
// ═══════════════════════════════════════════════════════════════
class NextDestinationSearch extends StatefulWidget {
  /// Called when both origin AND destination are confirmed
  final void Function(LocationPoint origin, LocationPoint destination)?
      onBothPointsReady;

  /// Legacy: called when a suggestion is tapped (single-step mode)
  final void Function(SuggestionItem)? onSuggestionTap;
  final void Function(SuggestionItem)? onConfirm;

  /// Pre-existing suggestions (shown before the user types)
  final List<SuggestionItem> suggestions;

  /// Shared controller — inject from parent for state persistence
  final LocationInputController? controller;

  const NextDestinationSearch({
    super.key,
    this.onBothPointsReady,
    this.onSuggestionTap,
    this.onConfirm,
    this.suggestions = const [],
    this.controller, required Null Function() onSavedPlaces, required Null Function() onSelectOnMap,
  });

  @override
  State<NextDestinationSearch> createState() => _NextDestinationSearchState();
}

// ─────────────────────────────────────────────────────────────
// Which step the user is on
// ─────────────────────────────────────────────────────────────
enum _Step { origin, destination, done }

class _NextDestinationSearchState extends State<NextDestinationSearch> {
  late final LocationInputController _ctrl;

  _Step _step = _Step.origin;

  final _originCtrl = TextEditingController();
  final _destCtrl   = TextEditingController();
  final _originFocus = FocusNode();
  final _destFocus   = FocusNode();

  List<LocationPoint> _searchResults = [];
  List<LocationPoint> _history       = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? LocationInputController();
    _ctrl.loadHistory().then((_) {
      if (mounted) setState(() => _history = _ctrl.history);
    });

    // Restore text if controller already has points
    if (_ctrl.origin != null) {
      _originCtrl.text = _ctrl.origin!.name;
    }
    if (_ctrl.destination != null) {
      _destCtrl.text = _ctrl.destination!.name;
    }

    _originFocus.addListener(_onFocusChange);
    _destFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  // ── Focus routing ───────────────────────────────────────────
  void _onFocusChange() {
    if (_originFocus.hasFocus) setState(() => _step = _Step.origin);
    if (_destFocus.hasFocus)   setState(() => _step = _Step.destination);
  }

  // ── Search ──────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await GeocodingService.instance.search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    });
  }

  // ── Select a LocationPoint from search / history / map ──────
  void _selectPoint(LocationPoint point) {
    if (_step == _Step.origin) {
      _ctrl.setOrigin(point);
      _originCtrl.text = point.name;
      setState(() {
        _searchResults = [];
        _step = _Step.destination;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _destFocus.requestFocus();
      });
    } else {
      _ctrl.setDestination(point);
      _destCtrl.text = point.name;
      setState(() {
        _searchResults = [];
        _step = _Step.done;
      });
      FocusScope.of(context).unfocus();
      if (_ctrl.isReady) {
        widget.onBothPointsReady?.call(_ctrl.origin!, _ctrl.destination!);
      }
    }
    setState(() => _history = _ctrl.history);
  }

  // ── Open map picker ─────────────────────────────────────────
  Future<void> _openMapPicker() async {
    FocusScope.of(context).unfocus();

    final initial = _step == _Step.origin
        ? _ctrl.origin?.latLng
        : _ctrl.destination?.latLng ?? _ctrl.origin?.latLng;

    final picked = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          title: _step == _Step.origin
              ? 'Choisir le point de départ'
              : 'Choisir la destination',
          initialPoint: initial,
        ),
      ),
    );
    if (picked != null) _selectPoint(picked);
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final activeText = _step == _Step.origin ? _originCtrl.text : _destCtrl.text;
    final showSuggestions = _searchResults.isNotEmpty;
    final showHistory = !showSuggestions &&
        _history.isNotEmpty &&
        (_originFocus.hasFocus || _destFocus.hasFocus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Input row: origin + destination ────────────────────
        _InputRow(
          originCtrl:  _originCtrl,
          destCtrl:    _destCtrl,
          originFocus: _originFocus,
          destFocus:   _destFocus,
          activeStep:  _step,
          onOriginChanged: (_) => _onSearchChanged(_originCtrl.text),
          onDestChanged:   (_) => _onSearchChanged(_destCtrl.text),
          onClearOrigin:   () { _ctrl.clearOrigin(); _originCtrl.clear(); setState(() => _step = _Step.origin); },
          onClearDest:     () { _ctrl.clearDestination(); _destCtrl.clear(); setState(() => _step = _Step.destination); },
          onSwap:          _ctrl.isReady ? () {
            _ctrl.swapPoints();
            _originCtrl.text = _ctrl.origin!.name;
            _destCtrl.text   = _ctrl.destination!.name;
            setState(() {});
          } : null,
        ),

        const SizedBox(height: 4),

        // ── Loading indicator ──────────────────────────────────
        if (_searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(
              minHeight: 1.5,
              color: AppColors.primaryPurple,
              backgroundColor: Colors.transparent,
            ),
          ),

        // ── Search results ─────────────────────────────────────
        if (showSuggestions) ...[
          const SizedBox(height: 4),
          ..._searchResults.map((p) => _LocationTile(
                point: p,
                icon: Icons.search_rounded,
                onTap: () => _selectPoint(p),
              )),
          const SizedBox(height: 8),
        ],

        // ── History ────────────────────────────────────────────
        if (showHistory) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
            child: Text(
              'Récents',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.subtext(context),
              ),
            ),
          ),
          ..._history.take(4).map((p) => _LocationTile(
                point: p,
                icon: Icons.history_rounded,
                onTap: () => _selectPoint(p),
              )),
          const SizedBox(height: 8),
        ],

        // ── Static action tiles ────────────────────────────────
        _ActionTile(
          icon: Icons.map_outlined,
          title: t.translate('select_on_map'),
          subtitle: t.translate('select_on_map_sub'),
          onTap: _openMapPicker,
        ),
        Divider(
          height: 1, thickness: 0.5, indent: 64,
          color: AppColors.border(context),
        ),
        _ActionTile(
          icon: Icons.star_outline_rounded,
          title: t.translate('saved_places'),
          subtitle: t.translate('saved_places_sub'),
          onTap: () {},
        ),

        // ── Pricing params debug card (visible once both set) ──
        if (_ctrl.isReady) ...[
          const SizedBox(height: 12),
          _PricingParamsCard(ctrl: _ctrl),
        ],

        // ── Confirm button ─────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _ctrl.isReady
              ? _ConfirmButton(
                  label: '${_ctrl.origin!.name} → ${_ctrl.destination!.name}',
                  onTap: () => widget.onBothPointsReady
                      ?.call(_ctrl.origin!, _ctrl.destination!),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Input row
// ═══════════════════════════════════════════════════════════════
class _InputRow extends StatelessWidget {
  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final FocusNode originFocus;
  final FocusNode destFocus;
  final _Step activeStep;
  final ValueChanged<String> onOriginChanged;
  final ValueChanged<String> onDestChanged;
  final VoidCallback onClearOrigin;
  final VoidCallback onClearDest;
  final VoidCallback? onSwap;

  const _InputRow({
    required this.originCtrl,
    required this.destCtrl,
    required this.originFocus,
    required this.destFocus,
    required this.activeStep,
    required this.onOriginChanged,
    required this.onDestChanged,
    required this.onClearOrigin,
    required this.onClearDest,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          // Origin
          _InputField(
            controller: originCtrl,
            focus: originFocus,
            hint: 'Point de départ',
            isActive: activeStep == _Step.origin,
            dotColor: Colors.pinkAccent,
            onChanged: onOriginChanged,
            onClear: onClearOrigin,
          ),
          Divider(height: 1, thickness: 0.5, color: AppColors.border(context)),
          // Destination
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: destCtrl,
                  focus: destFocus,
                  hint: 'Destination',
                  isActive: activeStep == _Step.destination,
                  dotColor: AppColors.primaryPurple,
                  onChanged: onDestChanged,
                  onClear: onClearDest,
                ),
              ),
              if (onSwap != null)
                GestureDetector(
                  onTap: onSwap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.subtext(context),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final String hint;
  final bool isActive;
  final Color dotColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _InputField({
    required this.controller,
    required this.focus,
    required this.hint,
    required this.isActive,
    required this.dotColor,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? dotColor : dotColor.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text(context),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.subtext(context),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.subtext(context)),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Location tile (search result or history item)
// ═══════════════════════════════════════════════════════════════
class _LocationTile extends StatelessWidget {
  final LocationPoint point;
  final IconData icon;
  final VoidCallback onTap;

  const _LocationTile({
    required this.point,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primaryPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ),
                      if (point.address != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          point.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtext(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${point.lat.toStringAsFixed(4)}, ${point.lng.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 10, color: AppColors.subtext(context)),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1, thickness: 0.5, indent: 64,
          color: AppColors.border(context),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Pricing params debug card
// ═══════════════════════════════════════════════════════════════
class _PricingParamsCard extends StatelessWidget {
  final LocationInputController ctrl;
  const _PricingParamsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, size: 14, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
              Text(
                'Paramètres API Pricing',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ctrl.pythonTuples,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: AppColors.text(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Confirm button
// ═══════════════════════════════════════════════════════════════
class _ConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ConfirmButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Legacy SuggestionItem — kept for backward-compat
// ═══════════════════════════════════════════════════════════════
class SuggestionItem {
  final String title;
  final String? subtitle;
  const SuggestionItem({required this.title, this.subtitle});
}

// ═══════════════════════════════════════════════════════════════
// Action tile (static bottom items)
// ═══════════════════════════════════════════════════════════════
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppColors.primaryPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.subtext(context)),
          ],
        ),
      ),
    );
  }
}