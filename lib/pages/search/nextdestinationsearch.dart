import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class SuggestionItem {
  final String title;
  final String? subtitle;

  const SuggestionItem({required this.title, this.subtitle});
}

// ════════════════════════════════════════════════════════════════════════════
// NextDestinationSearch — now StatefulWidget
// + isSelected highlight on suggestion tiles
// + AnimatedSize Confirmer button appears on selection
// ════════════════════════════════════════════════════════════════════════════
class NextDestinationSearch extends StatefulWidget {
  final VoidCallback? onSelectOnMap;
  final VoidCallback? onSavedPlaces;
  final List<SuggestionItem> suggestions;
  final void Function(SuggestionItem)? onSuggestionTap;

  /// Called when user taps "Confirmer" — navigate to next page here
  final void Function(SuggestionItem)? onConfirm;

  const NextDestinationSearch({
    super.key,
    this.onSelectOnMap,
    this.onSavedPlaces,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.onConfirm,
  });

  @override
  State<NextDestinationSearch> createState() => _NextDestinationSearchState();
}

class _NextDestinationSearchState extends State<NextDestinationSearch> {
  SuggestionItem? _selected;

  void _handleSuggestionTap(SuggestionItem item) {
    setState(() => _selected = item);
    widget.onSuggestionTap?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      children: [

        // ── Suggestions (max 4) ───────────────────────────────────────────
        if (widget.suggestions.isNotEmpty) ...[
          ...widget.suggestions.take(4).map(
            (item) => Column(
              children: [
                _SuggestionTile(
                  item: item,
                  isSelected: _selected == item,       // ← highlight
                  onTap: () => _handleSuggestionTap(item),
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

        // ── Static action tiles ───────────────────────────────────────────
        _ActionTile(
          icon: Icons.map_outlined,
          title: t.translate('select_on_map'),
          subtitle: t.translate('select_on_map_sub'),
          onTap: widget.onSelectOnMap ?? () {},
        ),
        Divider(
          height: 1, thickness: 0.5, indent: 64,
          color: AppColors.border(context),
        ),
        _ActionTile(
          icon: Icons.star_outline_rounded,
          title: t.translate('saved_places'),
          subtitle: t.translate('saved_places_sub'),
          onTap: widget.onSavedPlaces ?? () {},
        ),

        // ── Confirmer button — slides in when a suggestion is selected ────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _selected != null
              ? _ConfirmButton(
                  item: _selected!,
                  onTap: () => widget.onConfirm?.call(_selected!),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONFIRM BUTTON
// ════════════════════════════════════════════════════════════════════════════
class _ConfirmButton extends StatelessWidget {
  final SuggestionItem item;
  final VoidCallback onTap;
  const _ConfirmButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUGGESTION TILE — unchanged except isSelected param
// ════════════════════════════════════════════════════════════════════════════
class _SuggestionTile extends StatelessWidget {
  final SuggestionItem item;
  final bool isSelected;            // ← NEW
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryPurple.withOpacity(0.18)
                      : AppColors.primaryPurple.withOpacity(0.08),
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
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.text(context),
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
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.subtext(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ACTION TILE — unchanged
// ════════════════════════════════════════════════════════════════════════════
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