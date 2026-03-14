import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const SectionLabel({
    super.key,
    required this.label,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.sectionLabel(context),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                if (actionIcon != null) ...[
                  Icon(actionIcon,
                      size: 15, color: AppColors.subtext(context)),
                  const SizedBox(width: 5),
                ],
                Text(
                  actionLabel!,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}