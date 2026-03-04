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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [

          // ── 1. SCROLL ──────────────────────────────────────────
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: _mapMax),
              ),
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
                  ),
                  childCount: cars.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: _selectedIndex != null ? 90 : 24),
              ),
            ],
          ),

          // ── 2. MAP ─────────────────────────────────────────────
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
                          colors: [
                            Colors.transparent,
                            AppColors.bg(context),
                          ],
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
            left: 20,
            right: 20,
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
                      Text(
                        'More Information',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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