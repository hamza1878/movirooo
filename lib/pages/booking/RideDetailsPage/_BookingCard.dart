import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Badge ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: Colors.amber.shade600, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Payment pending',
                        style: TextStyle(
                          color: Colors.amber.shade600,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Booking ID ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#78438620',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            const ClipboardData(text: '78438620'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking ID copied'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bg(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.border(context)),
                        ),
                        child: Icon(Icons.copy_outlined,
                            size: 18,
                            color: AppColors.subtext(context)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Date ───────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.subtext(context)),
                    const SizedBox(width: 6),
                    Text('13 February 2026, 13:00',
                        style: AppTextStyles.bodySmall(context)),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Route stops ────────────────────────────────
                _RouteStop(
                  dot: _DotFilled(),
                  title: 'Tunis Carthage Airport (TUN)',
                  subtitle: 'Tunis, Tunisia',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Container(
                    width: 1.5, height: 28,
                    color: AppColors.primaryPurple.withOpacity(0.4),
                  ),
                ),
                _RouteStop(
                  dot: _DotFilled(),
                  title: 'Enfidha Hammamet Airport (NBE)',
                  subtitle: 'Enfidha, Tunisia',
                ),
              ],
            ),
          ),

          // ── Map preview ────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20)),
            child: Image.asset(
              'images/map_preview.png',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
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
        Padding(padding: const EdgeInsets.only(top: 3), child: dot),
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
        width: 13, height: 13,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          shape: BoxShape.circle,
        ),
      );
}