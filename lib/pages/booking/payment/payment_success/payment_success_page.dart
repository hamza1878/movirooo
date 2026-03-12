import 'package:flutter/material.dart';
import 'package:moviroo/routing/router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_SuccessIcon.dart';
import '_ReceiptCard.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Icône succès ───────────────────────────────
              const SuccessIcon(),
              const SizedBox(height: 24),

              // ── Titre ──────────────────────────────────────
              Text(
                'Payment Successful!',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.text(context),
                ),
              ),
              const SizedBox(height: 10),

              // ── Subtitle ───────────────────────────────────
              Text(
                'Your booking has been confirmed. A\nreceipt has been sent to your email.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.subtext(context),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // ── Receipt card ───────────────────────────────
              const ReceiptCard(
                amount: '\$124.50',
                refNumber: '#TR-883920',
                date: 'Oct 24, 2023',
                time: '09:41 AM',
                cardBrand: 'Mastercard',
                cardLast4: '4242',
              ),

              const Spacer(flex: 3),

              // ── Bouton Back to Home ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    AppRouter.push(context, AppRouter.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: AppColors.primaryPurple.withOpacity(0.50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Bouton Download Receipt ────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text(context),
                    side: BorderSide(color: AppColors.border(context), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Download Receipt',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
