import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _pushEnabled = false;
  bool _smsEnabled = false;
  bool _emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _SubPageTopBar(title: t('notifications')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Single notification card ───────────────────
                    _NotificationGroupCard(
                      title: t('notifications'),
                      description: t('notifications_description'),
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      items: [
                        _NotificationToggleItem(
                          label: t('push_notifications'),
                          value: _pushEnabled,
                          onChanged: (v) =>
                              setState(() => _pushEnabled = v),
                        ),
                        _NotificationToggleItem(
                          label: t('sms_messages'),
                          value: _smsEnabled,
                          onChanged: (v) =>
                              setState(() => _smsEnabled = v),
                        ),
                        _NotificationToggleItem(
                          label: t('email_notifications'),
                          value: _emailEnabled,
                          onChanged: (v) =>
                              setState(() => _emailEnabled = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification group card ───────────────────────────────────────────────────

class _NotificationGroupCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isDark;
  final List<_NotificationToggleItem> items;

  const _NotificationGroupCard({
    required this.title,
    required this.description,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.settingsItem(context)),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),

          // ── Toggle rows with dividers ──────────────────────
          ...List.generate(items.length, (i) {
            return Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border(context),
                ),
                _ToggleRow(
                  item: items[i],
                  isDark: isDark,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Toggle item data ──────────────────────────────────────────────────────────

class _NotificationToggleItem {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });
}

// ── Toggle row widget ─────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final _NotificationToggleItem item;
  final bool isDark;

  const _ToggleRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(item.label, style: AppTextStyles.settingsItem(context)),
          ),
          Switch(
            value: item.value,
            onChanged: item.onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primaryPurple,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor:
                isDark ? const Color(0xFF333340) : AppColors.lightBorder,
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SubPageTopBar extends StatelessWidget {
  final String title;
  const _SubPageTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: AppColors.text(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle(context),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}