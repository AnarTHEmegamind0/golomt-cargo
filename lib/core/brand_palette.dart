import 'package:flutter/material.dart';

class BrandPalette {
  const BrandPalette._();

  // ─────────────────────────────────────────────────────────────────────────
  // PRIMARY - buttons, navigation, links
  // ─────────────────────────────────────────────────────────────────────────
  static const electricBlue = Color(0xFF1A6FFF);
  static const navyBlue = Color(0xFF0D4FD4); // hover/pressed state
  static const skyBlue = Color(0xFF5B9BFF);

  // ─────────────────────────────────────────────────────────────────────────
  // SUPPORTING - status indicators
  // ─────────────────────────────────────────────────────────────────────────
  static const logoOrange = Color(0xFFFF7A20); // "замдаа" status, progress
  static const successGreen = Color(0xFF16A34A);
  static const errorRed = Color(0xFFDC2626);

  // ─────────────────────────────────────────────────────────────────────────
  // BACKGROUND & NEUTRAL
  // ─────────────────────────────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF); // cards
  static const softBlueBackground = Color(0xFFF4F7FC); // page background
  static const primaryText = Color(
    0xFF0D1F45,
  ); // dark navy text (not pure black)
  static const mutedText = Color(0xFF5F6F90);

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN DARK THEME - dashboard backdrop
  // ─────────────────────────────────────────────────────────────────────────
  static const adminDarkBg = Color(0xFF1B3C78);
  static const adminDarkerBg = Color(0xFF15356D);
  static const adminDarkestBg = Color(0xFF102C5D);

  // ─────────────────────────────────────────────────────────────────────────
  // GLASS EFFECTS - frosted surfaces
  // ─────────────────────────────────────────────────────────────────────────
  static const glassWhite08 = Color(0x24FFFFFF);
  static const glassBorder12 = Color(0x33FFFFFF);
  static const glassHover16 = Color(0x3DFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // ROW ALTERNATING - compact list rows
  // ─────────────────────────────────────────────────────────────────────────
  static const rowEven = Color(0xFFFFFFFF);
  static const rowOdd = Color(0xFFF8FAFD);
  static const rowHover = Color(0xFFF0F4FF);
  static const rowBorder = Color(0xFFE8ECF4);
}
