import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final Widget child;
  const SummaryCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: child,
    );
  }
}