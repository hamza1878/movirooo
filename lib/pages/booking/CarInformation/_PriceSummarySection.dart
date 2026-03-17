import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '_SummaryCard.dart';

class PriceSummarySection extends StatelessWidget {
  const PriceSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: AppColors.primaryPurple, size: 18),
              const SizedBox(width: 8),
              Text(t.translate('price_summary'),
                  style: AppTextStyles.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 14),
          _PriceRow(label: t.translate('outbound_transfer'), value: '€ 107.57'),
          const SizedBox(height: 8),
          _PriceRow(label: t.translate('taxes_fees'), value: t.translate('included')),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.translate('total'),
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.w800)),
              Text('€ 107.57',
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(context)),
        Text(value,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}