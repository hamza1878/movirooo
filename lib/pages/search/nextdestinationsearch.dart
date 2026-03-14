import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class SuggestionItem {
  final String title;
  final String? subtitle;

  const SuggestionItem({required this.title, this.subtitle});
}

class NextDestinationSearch extends StatelessWidget {
  final VoidCallback? onSelectOnMap;
  final VoidCallback? onSavedPlaces;
  final List<SuggestionItem> suggestions;
  final void Function(SuggestionItem)? onSuggestionTap;

  const NextDestinationSearch({
    super.key,
    this.onSelectOnMap,
    this.onSavedPlaces,
    this.suggestions = const [],
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Suggestions (max 4, visible only while typing) ──
        if (suggestions.isNotEmpty) ...[
          ...suggestions.take(4).map(
                (item) => Column(
                  children: [
                    _SuggestionTile(
                      item: item,
                      onTap: () => onSuggestionTap?.call(item),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 64,
                      color: AppColors.border(context),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 8),
        ],

        // ── Static action tiles ──
        _ActionTile(
          icon: Icons.map_outlined,
          title: 'Select on map',
          subtitle: 'Choose a location on the map',
          onTap: onSelectOnMap ?? () {},
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          indent: 64,
          color: AppColors.border(context),
        ),
        _ActionTile(
          icon: Icons.star_outline_rounded,
          title: 'Saved places',
          subtitle: 'Home, work, and favorites',
          onTap: onSavedPlaces ?? () {},
        ),
      ],
    );
  }
}

// ── Suggestion tile ───────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final SuggestionItem item;
  final VoidCallback onTap;

  const _SuggestionTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 22,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text(context),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.subtext(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppColors.primaryPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.subtext(context),
            ),
          ],
        ),
      ),
    );
  }
}