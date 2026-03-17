import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── LEFT: text content ─────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // pill label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryPurple),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'MOVIROO MEMBERSHIP',
                      style: AppTextStyles.sectionLabel(context).copyWith(
                        color: AppColors.primaryPurple,
                        fontSize: 9,
                      ),
                    ),
                  ),

                  // headline
                  Text(
                    'Get 500 to your\nfirst discount',
                    style: AppTextStyles.pageTitle(context).copyWith(
                      color: AppColors.text(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),

                  // CTA button
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── RIGHT: car image ───────────────────────────────────────
          Expanded(
            flex: 4,
            child: Transform.translate(
              offset: const Offset(-10, 0),
              child: SizedBox.expand(
                child: Image.asset(
                  'images/car.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}