import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';
class RecentSearch {
  final String title;
  final String subtitle;

  const RecentSearch({
    required this.title,
    required this.subtitle,
  });
}
const List<RecentSearch> recentSearchData = [
  RecentSearch(
    title: 'Golden Gate Bridge',
    subtitle: 'San Francisco, CA 94129',
  ),
  RecentSearch(
    title: 'The Ferry Building',
    subtitle: '1 Ferry Building, San Francisco',
  ),
  RecentSearch(
    title: 'Central Park',
    subtitle: 'New York, NY',
  ),
  
  
];class RecentSearchItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const RecentSearchItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.border(context),
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppColors.subtext(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          Icon(
            Icons.north_east_rounded,
            color: AppColors.subtext(context),
            size: 18,
          ),
        ],
      ),
    );
  }
}