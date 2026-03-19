import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/app_text_styles.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'email_verify_modal.dart'; // ← Step 2

/// Step 1 — "Verify Your Email"
/// Shows explanation text and a "Send Verification Code" button.
/// On tap → closes itself and opens [EmailVerifyModal] (Step 2).
class EmailSendModal extends StatefulWidget {
  const EmailSendModal({super.key});

  @override
  State<EmailSendModal> createState() => _EmailSendModalState();
}

class _EmailSendModalState extends State<EmailSendModal> {
  bool _isSending = false;

  Future<void> _handleSend() async {
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 1)); // TODO: real API call
    if (!mounted) return;
    setState(() => _isSending = false);

    // Close Step 1 then open Step 2
    Navigator.of(context).pop();
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmailVerifyModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close button ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.text(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Mail icon ─────────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              t('Verify Your Email'),
              style: AppTextStyles.pageTitle(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              t(
                "We'll send a 6-digit verification code to your registered email address.",
              ),
              style: AppTextStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // ── Send button ───────────────────────────────────────────────
            GestureDetector(
              onTap: _isSending ? null : _handleSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: _isSending ? null : AppColors.purpleGradient,
                  color: _isSending
                      ? const Color(0xFF7C3AED).withOpacity(0.4)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        t('Send Verification Code'),
                        style: AppTextStyles.buttonPrimary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}