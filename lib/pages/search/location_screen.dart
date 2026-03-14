import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'LocationCard.dart';
import 'nextdestinationsearch.dart';
import 'RecentSearchItem.dart';
import './DateTimeRow.dart';
import './RiderSheet.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int? _selectedRider;
  List<SuggestionItem> _suggestions = [];

  // ── Shared date/time state (passed down to DateTimeRow) ──────────
  DateTime _pickedDate = DateTime(2026, 3, 14);
  TimeOfDay? _pickedTime; // null = user hasn't explicitly picked a time yet

  final List<Map<String, String>> _riders = [
    {'name': 'Me', 'subtitle': 'Book this ride for yourself'},
    {'name': 'Youssef', 'subtitle': '+216 22 333 444'},
  ];

  final List<RecentSearchItem> _recentSearches = [
    const RecentSearchItem(title: 'Sousse', subtitle: 'Sousse, Tunisia'),
    const RecentSearchItem(
        title: 'The Ferry Building',
        subtitle: '1 Ferry Building, San Francisco'),
    const RecentSearchItem(title: 'Central Park', subtitle: 'New York, NY'),
  ];

  final List<SuggestionItem> _allPlaces = [
    const SuggestionItem(title: 'Sousse', subtitle: 'Sousse, Tunisia'),
    const SuggestionItem(title: 'Tunis Centre', subtitle: 'Tunis, Tunisia'),
    const SuggestionItem(title: 'Sfax', subtitle: 'Sfax, Tunisia'),
    const SuggestionItem(
        title: 'Monastir Airport', subtitle: 'Monastir, Tunisia'),
    const SuggestionItem(title: 'La Marsa', subtitle: 'Tunis, Tunisia'),
    const SuggestionItem(title: 'Hammamet', subtitle: 'Nabeul, Tunisia'),
    const SuggestionItem(title: 'Carthage', subtitle: 'Tunis, Tunisia'),
    const SuggestionItem(title: 'Sidi Bou Said', subtitle: 'Tunis, Tunisia'),
    const SuggestionItem(title: 'Djerba', subtitle: 'Medenine, Tunisia'),
    const SuggestionItem(
        title: 'Tunis Carthage Airport', subtitle: 'Tunis, Tunisia'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fromController.addListener(_onQueryChanged);
    _toController.addListener(_onQueryChanged);
    _fromFocus.addListener(_onQueryChanged);
    _toFocus.addListener(_onQueryChanged);

    _toController.addListener(_onDropOffChanged);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fromController.removeListener(_onQueryChanged);
    _toController.removeListener(_onQueryChanged);
    _toController.removeListener(_onDropOffChanged);
    _fromFocus.removeListener(_onQueryChanged);
    _toFocus.removeListener(_onQueryChanged);
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  // ── Gate: navigate ONLY when pick-up, drop-off AND time are all set ──
  void _onDropOffChanged() {
    final dropOff = _toController.text.trim();
    final pickUp = _fromController.text.trim();

    if (dropOff.isNotEmpty && pickUp.isNotEmpty) {
      // Time must be explicitly picked — not just the default date
      if (_pickedTime == null) return;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final stillFilled = _toController.text.trim().isNotEmpty &&
            _fromController.text.trim().isNotEmpty &&
            _pickedTime != null;

        if (stillFilled) {
          FocusScope.of(context).unfocus();
          Navigator.pushNamed(
            context,
            '/vehicle_selection_page',
            arguments: {
              'pickUp': pickUp,
              'dropOff': dropOff,
              'date': _pickedDate,
              'time': _pickedTime,
            },
          );
        }
      });
    }
  }

  /// Called by DateTimeRow when the user picks a time.
  void _onTimePicked(TimeOfDay time) {
    setState(() => _pickedTime = time);
    // Re-check navigation in case locations were already filled.
    _onDropOffChanged();
  }

  void _onQueryChanged() {
    final String query;
    if (_toFocus.hasFocus) {
      query = _toController.text.trim();
    } else if (_fromFocus.hasFocus) {
      query = _fromController.text.trim();
    } else {
      setState(() => _suggestions = []);
      return;
    }

    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final filtered = _allPlaces
        .where((p) =>
            p.title.toLowerCase().contains(query.toLowerCase()) ||
            (p.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .take(4)
        .toList();

    setState(() => _suggestions = filtered);
  }

  void _onSuggestionTap(SuggestionItem item) {
    if (_toFocus.hasFocus) {
      _toController.text = item.title;
    } else if (_fromFocus.hasFocus) {
      _fromController.text = item.title;
    } else {
      _fillSmartField(item.title);
    }

    setState(() => _suggestions = []);
    FocusScope.of(context).unfocus();
  }

  void _onRecentTap(RecentSearchItem item) {
    _fillSmartField(item.title);
  }

  void _fillSmartField(String locationName) {
    final fromEmpty = _fromController.text.trim().isEmpty;
    if (fromEmpty) {
      _fromController.text = locationName;
    } else {
      _toController.text = locationName;
    }
    setState(() => _suggestions = []);
    FocusScope.of(context).unfocus();
  }

  void _swapLocations() {
    final from = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = from;
  }

  void _clearRecent() => setState(() => _recentSearches.clear());

  Future<void> _showRiderSheet() async {
    final selected = await RiderSheet.show(
      context,
      riders: _riders,
      initialSelected: _selectedRider,
      onRidersChanged: (updated) => setState(() {
        _riders
          ..clear()
          ..addAll(updated);
      }),
    );
    if (selected != null) setState(() => _selectedRider = selected);
  }

  @override
  Widget build(BuildContext context) {
    final String pillLabel =
        (_selectedRider != null && _selectedRider! < _riders.length)
            ? _riders[_selectedRider!]['name']!
            : 'For Me';

    final bool showRecent =
        _suggestions.isEmpty && _recentSearches.isNotEmpty;

    // Show a hint banner when locations are filled but time hasn't been picked
    final bool showTimeBanner = _fromController.text.trim().isNotEmpty &&
        _toController.text.trim().isNotEmpty &&
        _pickedTime == null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Plan your ride',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.text(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Rider pill ───────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _showRiderSheet,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 17, color: AppColors.primaryPurple),
                      const SizedBox(width: 7),
                      Text(
                        pillLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 17, color: AppColors.primaryPurple),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Scrollable body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationCard(
                      fromController: _fromController,
                      toController: _toController,
                      fromFocus: _fromFocus,
                      toFocus: _toFocus,
                      pulseAnim: _pulseAnim,
                      onSwap: _swapLocations,
                      onUseCurrentLocation: () {},
                    ),
                    const SizedBox(height: 10),

                    // DateTimeRow — passes callbacks up so LocationScreen
                    // knows when the user has explicitly picked a time.
                    DateTimeRow(
                      initialDate: _pickedDate,
                      onDateChanged: (d) => setState(() => _pickedDate = d),
                      onTimeChanged: _onTimePicked,
                    ),

                    // ── Hint banner: pick a time to continue ────────
                    if (showTimeBanner) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 16, color: AppColors.primaryPurple),
                            const SizedBox(width: 8),
                            Text(
                              'Please pick a time to continue',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    NextDestinationSearch(
                      suggestions: _suggestions,
                      onSuggestionTap: _onSuggestionTap,
                      onSelectOnMap: () {},
                      onSavedPlaces: () {},
                    ),

                    // ── Recent searches ───────────────────────────
                    if (showRecent) ...[
                      const SizedBox(height: 2),
                      ..._recentSearches.map(
                        (item) => RecentSearchTile(
                          item: item,
                          onTap: () => _onRecentTap(item),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _clearRecent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 14,
                                  color: AppColors.subtext(context)),
                              const SizedBox(width: 4),
                              Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtext(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}