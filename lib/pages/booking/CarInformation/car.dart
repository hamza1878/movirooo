import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  int _pax = 2;
  int _bags = 3;

  // ── Picker roulant générique ─────────────────────────────────
  void _showPicker({
    required String title,
    required int current,
    required int min,
    required int max,
    required ValueChanged<int> onSelected,
  }) {
    int temp = current;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: AppTextStyles.bodyMedium(context)
                            .copyWith(color: AppColors.subtext(context))),
                  ),
                  Text(title,
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                      onSelected(temp);
                      Navigator.pop(context);
                    },
                    child: Text('Done',
                        style: AppTextStyles.bodyMedium(context)
                            .copyWith(color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: current - min,
                ),
                itemExtent: 52,
                onSelectedItemChanged: (i) => temp = i + min,
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: AppColors.primaryPurple.withOpacity(0.10),
                ),
                children: List.generate(
                  max - min + 1,
                  (i) => Center(
                    child: Text(
                      '${i + min}',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── TopBar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text('Booking Summary',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge(context)
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 17)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [

                    // ── Carte voiture ──────────────────────────
                    _Card(
                      child: Row(
                        children: [
                          Image.asset('images/bmw.png',
                              width: 90, height: 60, fit: BoxFit.contain),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Economy',
                                    style: AppTextStyles.bodyLarge(context)
                                        .copyWith(fontWeight: FontWeight.w800,
                                            fontSize: 18)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // ── PAX picker ──
                                    _PickerChip(
                                      icon: Icons.person_outline_rounded,
                                      label: '$_pax pax',
                                      onTap: () => _showPicker(
                                        title: 'Passengers',
                                        current: _pax,
                                        min: 1,
                                        max: 7,
                                        onSelected: (v) =>
                                            setState(() => _pax = v),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // ── BAGS picker ──
                                    _PickerChip(
                                      icon: Icons.luggage_outlined,
                                      label: '$_bags luggage',
                                      onTap: () => _showPicker(
                                        title: 'Luggage',
                                        current: _bags,
                                        min: 0,
                                        max: 7,
                                        onSelected: (v) =>
                                            setState(() => _bags = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Route ──────────────────────────────────
                    _Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.send_outlined,
                                  color: AppColors.primaryPurple, size: 16),
                              const SizedBox(width: 8),
                              Text('Thu, 12 Feb 2026 • 13:00',
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _RouteStop(
                            dot: _DotFilled(),
                            title: 'Enfidha Hammamet Airport (NBE)',
                            subtitle: 'Enfidha, Tunisia',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Container(
                              width: 1.5,
                              height: 24,
                              color: AppColors.border(context),
                            ),
                          ),
                          _RouteStop(
                            dot: _DotOutline(),
                            title: 'Tunis Carthage Airport (TUN)',
                            subtitle: 'Tunis, Tunisia',
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatItem(label: 'DISTANCE', value: '114 KM'),
                              _StatItem(label: 'ETA', value: '14:17'),
                              _StatItem(
                                  label: 'PAX',
                                  value: '$_pax ADULT${_pax > 1 ? 'S' : ''}'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Discount code ──────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  color: AppColors.primaryPurple, size: 18),
                              const SizedBox(width: 8),
                              Text('Discount code',
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: AppTextStyles.bodyMedium(context),
                                  decoration: InputDecoration(
                                    hintText: 'Enter code',
                                    hintStyle: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                            color: AppColors.subtext(context)),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface(context),
                                  foregroundColor: AppColors.text(context),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                child: Text('APPLY',
                                    style: AppTextStyles.bodySmall(context)
                                        .copyWith(fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Price Summary ──────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  color: AppColors.primaryPurple, size: 18),
                              const SizedBox(width: 8),
                              Text('PRICE SUMMARY',
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _PriceRow(label: 'Outbound transfer', value: '€ 107.57'),
                          const SizedBox(height: 8),
                          _PriceRow(label: 'Taxes & fees', value: 'Included'),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: AppTextStyles.bodyLarge(context)
                                      .copyWith(fontWeight: FontWeight.w800)),
                              Text('€ 107.57',
                                  style: AppTextStyles.bodyLarge(context)
                                      .copyWith(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Confirm button ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: AppColors.primaryPurple.withOpacity(0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirm booking',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets helpers ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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

// ── Chip cliquable pour PAX / Bagages ────────────────────────────────────────
class _PickerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryPurple),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  final Widget dot;
  final String title;
  final String subtitle;
  const _RouteStop({required this.dot, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: dot,
        ),
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
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          shape: BoxShape.circle,
        ),
      );
}

class _DotOutline extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.subtext(context), width: 2),
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.subtext(context), fontSize: 10,
                    letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w800)),
      ],
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
        Text(value, style: AppTextStyles.bodyMedium(context)
            .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}