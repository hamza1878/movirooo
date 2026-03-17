import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../routing/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(context).copyWith(
        color: AppColors.subtext(context),
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.text(context), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: isDark ? BorderSide.none : BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: isDark ? BorderSide.none : BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.bg(context) : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // ── App Logo ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/lsnn.png', width: 120, height: 120, fit: BoxFit.cover),
              ),

              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────
              Text(
                t.translate('welcome_back'),
                style: AppTextStyles.pageTitle(context).copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 40),

              // ── Email ─────────────────────────────────────────────
              _label(context, t.translate('label_email_address')),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColors.subtext(context),
                style: AppTextStyles.bodyMedium(context),
                decoration: _fieldDecoration(
                  context,
                  hint: t.translate('hint_email'),
                  prefixIcon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // ── Password ──────────────────────────────────────────
              _label(context, t.translate('label_password')),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                cursorColor: AppColors.subtext(context),
                style: AppTextStyles.bodyMedium(context),
                decoration: _fieldDecoration(
                  context,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.text(context),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Forgot Password ───────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.translate('forgot_password'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Sign In Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => AppRouter.clearAndGo(context, AppRouter.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(t.translate('sign_in'), style: AppTextStyles.buttonPrimary),
                ),
              ),

              const SizedBox(height: 28),

              // ── Divider ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      t.translate('or_continue_with'),
                      style: AppTextStyles.sectionLabel(context),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border(context))),
                ],
              ),

              const SizedBox(height: 20),

              // ── Google ────────────────────────────────────────────
              _socialButton(
                backgroundColor: AppColors.surface(context),
                borderColor: AppColors.border(context),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/google.png', width: 22, height: 22),
                    const SizedBox(width: 12),
                    Text(
                      t.translate('continue_with_google'),
                      style: AppTextStyles.bodyLarge(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Apple ─────────────────────────────────────────────
              _socialButton(
                backgroundColor: Colors.white,
                borderColor: AppColors.border(context),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/apple.png', width: 22, height: 22),
                    const SizedBox(width: 10),
                    Text(
                      t.translate('continue_with_apple'),
                      style: AppTextStyles.bodyLarge(context).copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Don't have an account? ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.translate('no_account'), style: AppTextStyles.bodyMedium(context)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(
                      t.translate('sign_up'),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTextStyles.sectionLabel(context)),
      );

  Widget _socialButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color borderColor,
    required Widget child,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor),
            ),
          ),
          child: child,
        ),
      );
}