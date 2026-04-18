import 'package:flutter/material.dart';
import 'package:moviroo/pages/tabs%20%5Bpassenger%5D/home/ai_assistant/ai_assistant_page.dart';
import 'package:moviroo/routing/router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class HomeSearchBar extends StatelessWidget {
  final double height;
  final double borderRadius;

  const HomeSearchBar({
    super.key,
    this.height = 60,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => AppRouter.push(context, AppRouter.nextDestinationSearchRoute),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: AppColors.subtext(context), size: 25),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.translate('where_to'),
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.subtext(context),
                ),
              ),
            ),
            
   GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiAssistantPage(
        language: 'FR',
        // ✅ Plus besoin de navigatorKey
      )),
    );
  },
  child: Container(
    width: 44,
    height: 44,
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        colors: [
          Color(0xFFA855F7),
          Color(0xFF7C3AED),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0x667C3AED),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    ),
    child: const Icon(
      Icons.mic_rounded,
      color: Colors.white,
      size: 20,
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}