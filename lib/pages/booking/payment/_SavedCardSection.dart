import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class SavedCardSection extends StatefulWidget {
  final VoidCallback onUseNewCard;
  const SavedCardSection({super.key, required this.onUseNewCard});

  @override
  State<SavedCardSection> createState() => _SavedCardSectionState();
}

class _SavedCardSectionState extends State<SavedCardSection> {
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ── Carte enregistrée ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CARTE ENREGISTRÉE',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  )),
              const SizedBox(height: 12),

              // Card row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primaryPurple.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.credit_card_rounded,
                          color: AppColors.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•••• •••• •••• 4444',
                              style: AppTextStyles.bodyMedium(context)
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryPurple, size: 20),
                    const SizedBox(width: 8),
                    Icon(Icons.delete_outline_rounded,
                        color: AppColors.subtext(context), size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Utiliser une nouvelle carte
              GestureDetector(
                onTap: widget.onUseNewCard,
                child: Text(
                  'Utiliser une nouvelle carte',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── CVV ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card_outlined,
                      color: AppColors.primaryPurple, size: 18),
                  const SizedBox(width: 8),
                  Text('ENTREZ LE CVV',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.subtext(context),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Text('CVV',
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.subtext(context))),
              const SizedBox(height: 6),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: '123',
                    counterText: '',
                    hintStyle: AppTextStyles.bodyMedium(context)
                        .copyWith(color: AppColors.subtext(context)),
                    filled: true,
                    fillColor: AppColors.bg(context),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.primaryPurple, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}