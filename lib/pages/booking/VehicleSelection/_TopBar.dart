import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class TopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const TopBar({
    super.key,
    this.title = 'Vehicle Selection',
    this.actions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text(context),
              size: 20,
            ),
            onPressed: onBack ??
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/nextdestinationsearch');
                  }
                },
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
          ),

          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}