import 'package:flutter/material.dart';

class AppColors {
  // ── PRIMARY COLORS (Electric Blue + Lime Green from HiHR logo) ──
  static const Color primary = Color(0xFF1E3AE2); // Main electric blue (buttons, active states)
  static const Color primaryDark = Color(0xFF1526A8); // Darker blue for pressed/hover
  static const Color primaryDeep = Color(0xFF0D1B7A); // Deepest blue (headers/drawer)
  static const Color primaryLight = Color(0xFF5C74F0); // Lighter blue accent

  // ── ACCENT COLORS (Lime green dot from logo — used across cards, logos, categories) ──
  static const Color lime = Color(0xFFA6D608); // Signature lime green (logo dot)
  static const Color limeSoft = Color(0xFFE3F5A8);
  static const Color pink = Color(0xFFF48FB1);
  static const Color pinkSoft = Color(0xFFFFD6E7);
  static const Color coral = Color(0xFFFF8A75);
  static const Color coralSoft = Color(0xFFFFD9CF);
  static const Color mint = Color(0xFF3DDC97);
  static const Color mintSoft = Color(0xFFC8F7E6);

  // cycling accent list (for cards / logos / categories)
  static const List<Color> accents = [primary, lime, coral, mint, pink];
  static const List<Color> accentsSoft = [
    Color(0xFFDCE3FF),
    limeSoft,
    coralSoft,
    mintSoft,
    pinkSoft,
  ];

  // ── HEADER / DRAWER (solid electric blue, no gradient — matches logo bg) ──
  static const Color headerColor = primaryDeep;
  static const Color drawerColor = primaryDeep;

  // Gradient (used on splash/illustration screens)
  static const Color gradientStart = Color(0xFF1E3AE2); // Electric blue
  static const Color gradientEnd = Color(0xFF0D1B7A); // Deep blue
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color scaffoldBackground = Color(0xFFF7F8FF); // Very light blue-white

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Headings
  static const Color textSecondary = Color(0xFF6B7280); // Subtext/description (gray)
  static const Color textHint = Color(0xFF9CA3AF); // Hint text in fields

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0); // Input field borders
  static const Color divider = Color(0xFFEEEEEE);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonText = Color(0xFFFFFFFF);

  // Selected/Active States
  static const Color selected = primary;
  static const Color unselected = Color(0xFFBDBDBD);

  // Social Login Icons Background
  static const Color socialIconBg = Color.fromRGBO(245, 245, 245, 1);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // OTP Box
  static const Color otpBoxBg = Color(0xFFF1F5F9);
  static const Color otpBoxBorder = Color(0xFFCBD5E1);

  // Map/Location Screen
  static const Color mapPinRed = Color(0xFFE53935);
  static const Color mapPinBlue = primary;
}