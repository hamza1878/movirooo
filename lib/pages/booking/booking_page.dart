// lib/features/booking/booking_page.dart
// ─────────────────────────────────────────────────────────────────
// Example page that wires together:
//   • LocationInputController  (shared state)
//   • NextDestinationSearch    (search + map picker)
//   • MapPreviewWidget         (live dynamic map)
//   • Price API call           (FastAPI /price/quick)
//
// Drop this into your Navigator and it works end-to-end.
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moviroo/pages/booking/map_preview_widget.dart';
import 'package:moviroo/pages/search/models/location_point.dart';
import 'package:moviroo/pages/search/nextdestinationsearch.dart';

import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'location_input_controller.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // ── Shared controller — persists across widget rebuilds ───────
  final _locationCtrl = LocationInputController();

  // ── Pricing state ──────────────────────────────────────────
  Map<String, dynamic>? _priceResult;
  bool  _loadingPrice = false;
  String? _priceError;

  // ── API base URL — change to your server's IP when testing ───
  static const _apiBase = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _locationCtrl.loadHistory();
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  // ── Call pricing API once both points are set ─────────────────
  Future<void> _fetchPrice(LocationPoint origin, LocationPoint destination) async {
    setState(() { _loadingPrice = true; _priceError = null; });

    try {
      final body = {
        ..._locationCtrl.pricingParams,
        'car_type': 'comfort',
      };

      final res = await http.post(
        Uri.parse('$_apiBase/price/quick'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        setState(() {
          _priceResult = jsonDecode(res.body) as Map<String, dynamic>;
          _loadingPrice = false;
        });
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      setState(() {
        _priceError = e.toString();
        _loadingPrice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        title: Text(
          'Réserver un trajet',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Live map preview ─────────────────────────────────
            // Re-renders whenever controller notifies (origin / dest changed)
            AnimatedBuilder(
              animation: _locationCtrl,
              builder: (_, __) => SizedBox(
                height: 220,
                child: MapPreviewWidget(controller: _locationCtrl),
              ),
            ),

            const SizedBox(height: 16),

            // ── Search / location selection ───────────────────────
            NextDestinationSearch(
              controller: _locationCtrl,
              onBothPointsReady: (origin, dest) {
                _fetchPrice(origin, dest);
              }, onSavedPlaces: () {  }, onSelectOnMap: () {  },
            ),

            const SizedBox(height: 16),

            // ── Price result ─────────────────────────────────────
            if (_loadingPrice)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              ),

            if (_priceError != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Erreur API : $_priceError',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),

            if (_priceResult != null && !_loadingPrice)
              _PriceCard(data: _priceResult!),

            // ── Debug: raw python tuples ─────────────────────────
            AnimatedBuilder(
              animation: _locationCtrl,
              builder: (_, __) {
                if (!_locationCtrl.isReady) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordonnées (format API)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _locationCtrl.pythonTuples,
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
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Price result card
// ════════════════════════════════════════════════════════════════
class _PriceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PriceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final price    = (data['final_price'] as num?)?.toDouble() ?? 0;
    final surge    = (data['surge_multiplier'] as num?)?.toDouble() ?? 1;
    final distKm   = (data['distance_km'] as num?)?.toDouble() ?? 0;
    final durMin   = (data['duration_min'] as num?)?.toDouble() ?? 0;
    final mlUsed   = data['ml_used'] as bool? ?? false;
    final wth      = data['weather'] as Map<String, dynamic>? ?? {};
    final geo      = data['geo_origin'] as Map<String, dynamic>?;
    final seasonal = (data['time_flags'] as Map<String, dynamic>?)?['season'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} TND',
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
                      ),
                    ),
                    Text(
                      'Surge ×${surge.toStringAsFixed(3)}  •  ${mlUsed ? "ML" : "Règles"}',
                      style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distKm.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text(context)),
                    ),
                    Text(
                      '${durMin.toStringAsFixed(0)} min',
                      style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (geo != null) ...[
                  Icon(Icons.location_city_rounded, size: 14, color: AppColors.subtext(context)),
                  const SizedBox(width: 4),
                  Text(
                    geo['ville']?.toString() ?? '?',
                    style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.subtext(context)),
                const SizedBox(width: 4),
                Text(
                  '${wth['label'] ?? ''} ${wth['temperature'] ?? ''}°C',
                  style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                ),
                const SizedBox(width: 12),
                Text(
                  seasonal,
                  style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}