// ════════════════════════════════════════════════════════════════════════════
// ai_assistant_colors.dart
// Supports light & dark mode — same pattern as AppColors
// Usage:  AiColors.bg(context)        ← context-aware
//         AiColors.purple             ← static (same in both modes)
// ════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class AiColors {
  AiColors._();

  // ── Helper ────────────────────────────────────────────────────────────────
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ════════════════════════════════════════════════════════════════════════
  // CONTEXT-AWARE  (change between light / dark)
  // ════════════════════════════════════════════════════════════════════════

  /// Page background
  static Color bg(BuildContext context) => _isDark(context)
      ? const Color(0xFF0A0A1A)   // near-black indigo
      : const Color(0xFFF2F0FA);  // soft lavender white

  /// Card / surface fill
  static Color surface(BuildContext context) => _isDark(context)
      ? const Color(0xFF13132A)
      : const Color(0xFFFFFFFF);

  /// Elevated card (e.g. transcript card)
  static Color card(BuildContext context) => _isDark(context)
      ? const Color(0xFF1A1A2E)
      : const Color(0xFFEFEBFB);

  /// Card border
  static Color cardBord(BuildContext context) => _isDark(context)
      ? const Color(0xFF2A2A45)
      : const Color(0xFFD8D0F0);

  /// Primary text
  static Color textPrimary(BuildContext context) => _isDark(context)
      ? const Color(0xFFEEEEF5)
      : const Color(0xFF1A1A2E);

  /// Secondary / dim text
  static Color textSub(BuildContext context) => _isDark(context)
      ? const Color(0xFF7A7A9E)
      : const Color(0xFF6B6B8A);

  // ── Ring layers (outermost → innermost) ──────────────────────────────────
  static Color ring1(BuildContext context) => _isDark(context)
      ? const Color(0xFF1A1A35)
      : const Color(0xFFDDD5F5);

  static Color ring2(BuildContext context) => _isDark(context)
      ? const Color(0xFF221A40)
      : const Color(0xFFD0C5F0);

  static Color ring3(BuildContext context) => _isDark(context)
      ? const Color(0xFF2D1A55)
      : const Color(0xFFC0B0E8);

  static Color ring4(BuildContext context) => _isDark(context)
      ? const Color(0xFF3D1A75)
      : const Color(0xFFAA90E0);

  // ════════════════════════════════════════════════════════════════════════
  // STATIC  (same in both modes — brand colors never change)
  // ════════════════════════════════════════════════════════════════════════

  // Purple family
  static const purple      = Color(0xFF9B30FF);
  static const purpleLight = Color(0xFFB44DFF);
  static const purpleDim   = Color(0xFF6B21D4);
  static const purpleGlow  = Color(0xFF7C3AED);

  // Pink accent
  static const pink        = Color(0xFFFF2D8B);
  static const pinkLight   = Color(0xFFFF6CAE);

  // Mic button
  static const micBg       = Color(0xFF7C3AED);
  static const micBgLight  = Color(0xFF9B30FF);

  // Transcript highlight word
  static const textHighlight = Color(0xFF9B30FF);

  // State labels
  static const labelListening = Color(0xFFFF6CAE); // pink
  static const labelSaying    = Color(0xFF9B30FF); // purple
}
