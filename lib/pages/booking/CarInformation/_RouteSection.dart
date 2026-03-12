import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_SummaryCard.dart';

class RouteSection extends StatelessWidget {
  final int pax;
  const RouteSection({super.key, required this.pax});

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.send_outlined,
                  color: AppColors.primaryPurple, size: 16),
              const SizedBox(width: 8),
              Text('Thu, 12 Feb 2026 • 13:00',
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // Stop départ
          _RouteStop(
            dot: _DotFilled(),
            title: 'Enfidha Hammamet Airport (NBE)',
            subtitle: 'Enfidha, Tunisia',
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(
              width: 1.5, height: 24,
              color: AppColors.border(context),
            ),
          ),
          // Stop arrivée
          _RouteStop(
            dot: _DotOutline(),
            title: 'Tunis Carthage Airport (TUN)',
            subtitle: 'Tunis, Tunisia',
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: 'DISTANCE', value: '114 KM'),
              _StatItem(label: 'ETA', value: '14:17'),
              _StatItem(
                  label: 'PAX',
                  value: '$pax ADULT${pax > 1 ? 'S' : ''}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  final Widget dot;
  final String title;
  final String subtitle;
  const _RouteStop(
      {required this.dot, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: dot),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.bodySmall(context)),
          ],
        ),
      ],
    );
  }
}

class _DotFilled extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          shape: BoxShape.circle,
        ),
      );
}

class _DotOutline extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.subtext(context), width: 2),
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.subtext(context),
                fontSize: 10,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}