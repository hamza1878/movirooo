import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_PaymentSummaryCard.dart';
import '_SavedCardSection.dart';
import '_NewCardForm.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _hasSavedCard = true;
  bool _useNewCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paiement',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w800, fontSize: 18)),
                      Text('Réservation #78438620',
                          style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.subtext(context))),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  children: [

                    const PaymentSummaryCard(),
                    const SizedBox(height: 16),

                    if (_hasSavedCard && !_useNewCard) ...[
                      SavedCardSection(
                        onUseNewCard: () =>
                            setState(() => _useNewCard = true),
                      ),
                    ] else ...[
                      NewCardForm(
                        onSaved: () => setState(() {
                          _hasSavedCard = true;
                          _useNewCard = false;
                        }),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 14, color: AppColors.subtext(context)),
                        const SizedBox(width: 6),
                        Text('Paiement sécurisé avec chiffrement 256-bit',
                            style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.subtext(context))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.credit_card_outlined, size: 20),
                  label: const Text('Payer 85.00 TND',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: AppColors.primaryPurple.withOpacity(0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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