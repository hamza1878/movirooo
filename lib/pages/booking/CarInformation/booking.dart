import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:moviroo/pages/booking/CarInformation/_TopBar.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_BookingSummaryCard.dart';
import '_PickerChip.dart';
import '_RouteSection.dart';
import '_DiscountSection.dart';
import '_PriceSummarySection.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  int _pax = 2;
  int _bags = 3;

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
                        style: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.primaryPurple,
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
                    child: Text('${i + min}',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        )),
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

        TopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [

                    BookingSummaryCard(
                      pax: _pax,
                      bags: _bags,
                      onPaxTap: () => _showPicker(
                        title: 'Passengers',
                        current: _pax,
                        min: 1,
                        max: 7,
                        onSelected: (v) => setState(() => _pax = v),
                      ),
                      onBagsTap: () => _showPicker(
                        title: 'Luggage',
                        current: _bags,
                        min: 0,
                        max: 7,
                        onSelected: (v) => setState(() => _bags = v),
                      ),
                    ),

                    const SizedBox(height: 12),
                    RouteSection(pax: _pax),
                    const SizedBox(height: 12),
                    const DiscountSection(),
                    const SizedBox(height: 12),
                    const PriceSummarySection(),
                  ],
                ),
              ),
            ),

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