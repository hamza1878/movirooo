import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key});

  void _showVehicleInfo(BuildContext context) {
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
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Logo agence ──────────────────────────────────
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'images/agency_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.business_rounded,
                        color: AppColors.primaryPurple,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Premium Transfer Co.',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber.shade500, size: 14),
                          const SizedBox(width: 3),
                          Text('4.9',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Text('(1.2k avis)',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                  color: AppColors.subtext(context))),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Vérifié',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.border(context)),
            const SizedBox(height: 16),

            // ── Image voiture ────────────────────────────────
            Image.asset('images/bmw.png', height: 110, fit: BoxFit.contain),
            const SizedBox(height: 16),

            Text('Standard Class',
                style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 4),
            Text('Mercedes E Class, BMW 5 or similar',
                style: AppTextStyles.bodySmall(context)),

            const SizedBox(height: 24),

            // ── Specs ─────────────────────────────────────────
            Row(
              children: [
                _SpecItem(icon: Icons.person_outline_rounded,
                    label: 'Passagers', value: 'Jusqu\'à 4'),
                _SpecItem(icon: Icons.luggage_outlined,
                    label: 'Bagages', value: 'Jusqu\'à 3'),
                _SpecItem(icon: Icons.ac_unit_rounded,
                    label: 'Clim', value: 'Incluse'),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: AppColors.border(context)),
            const SizedBox(height: 16),

            // ── Features ──────────────────────────────────────
            _FeatureRow(icon: Icons.wifi_outlined, label: 'WiFi gratuit à bord'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.water_drop_outlined, label: 'Eau offerte'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.child_care_outlined,
                label: 'Siège enfant sur demande'),
            const SizedBox(height: 10),
            _FeatureRow(icon: Icons.flight_outlined,
                label: 'Suivi de vol inclus'),

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
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Compris',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VEHICLE CLASS',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 11,
            )),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => _showVehicleInfo(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [

                

                const SizedBox(width: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('images/bmw.png',
                      width: 75, height: 52, fit: BoxFit.contain),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Standard',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('Premium Transfer Co.',
                          style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Mercedes E Class, BMW 5 or similar',
                          style: AppTextStyles.bodySmall(context)),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right_rounded,
                    color: AppColors.subtext(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


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
              style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.subtext(context), fontSize: 10)),
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