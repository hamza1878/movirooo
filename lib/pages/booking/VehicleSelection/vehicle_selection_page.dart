import 'package:flutter/material.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_CarCard.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_RouteInfoBar.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_TopBar.dart';
import 'package:moviroo/pages/booking/VehicleSelection/_VatNote.dart';
import 'package:moviroo/routing/router.dart';
import 'package:moviroo/theme/app_text_styles.dart';
import '../../../../theme/app_colors.dart';

class VehicleSelectionPage extends StatefulWidget {
  const VehicleSelectionPage({super.key});

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  final ScrollController _scroll = ScrollController();
  double _mapHeight = 300.0;
  static const double _mapMin = 110.0;
  static const double _mapMax = 300.0;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scroll.offset.clamp(0.0, _mapMax - _mapMin);
    setState(() => _mapHeight = _mapMax - offset);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _showVehicleInfo(BuildContext context, CarOption car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Image.asset(car.image, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 16),

            Text(car.name,
                style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 4),
            Text('Mercedes E Class, BMW 5 or similar',
                style: AppTextStyles.bodySmall(context)),

            const SizedBox(height: 24),

            Row(
              children: [
                _SpecItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Passengers',
                    value: 'Up to ${car.seats}'),
                _SpecItem(
                    icon: Icons.luggage_outlined,
                    label: 'Luggage',
                    value: 'Up to ${car.bags}'),
                _SpecItem(
                    icon: Icons.ac_unit_rounded,
                    label: 'A/C',
                    value: 'Included'),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: AppColors.border(context)),
            const SizedBox(height: 16),

            _FeatureRow(icon: Icons.wifi_outlined, label: 'Free WiFi onboard'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.water_drop_outlined, label: 'Complimentary water'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.child_care_outlined, label: 'Child seat available on request'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.flight_outlined, label: 'Flight tracking included'),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Got it',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [

          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: _mapMax)),

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      RouteInfoBar(),
                      const SizedBox(height: 6),
                      VatNote(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => CarCard(
                    car: cars[i],
                    isSelected: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                    onInfoTap: () => _showVehicleInfo(context, cars[i]),
                  ),
                  childCount: cars.length,
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(height: _selectedIndex != null ? 90 : 24),
              ),
            ],
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: _mapHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'images/map_preview.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.bg(context)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: TopBar(),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            bottom: _selectedIndex != null ? 24 : -90,
            left: 20, right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _selectedIndex != null ? 1.0 : 0.0,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => AppRouter.clearAndGo(context, AppRouter.booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: AppColors.primaryPurple.withOpacity(0.40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('More Information',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.subtext(context), fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyMedium(context)),
      ],
    );
  }
}