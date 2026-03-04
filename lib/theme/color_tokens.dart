import 'package:flutter/material.dart';

abstract class ColorTokens {
  // ── Primary — Terracotta ───────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFFC4654A);
  static const Color primaryDark = Color(0xFFE8896E);

  // ── Secondary — Warm Amber ─────────────────────────────────────────────────
  static const Color secondaryLight = Color(0xFFD4944A);
  static const Color secondaryDark = Color(0xFFE8B06E);

  // ── Tertiary — Sage Green ──────────────────────────────────────────────────
  static const Color tertiaryLight = Color(0xFF7A9E7E);
  static const Color tertiaryDark = Color(0xFF9EC4A2);

  // ── Neutrals — warm-tinted scale (light) ──────────────────────────────────
  static const Color neutral50Light = Color(0xFFFAF7F4);
  static const Color neutral100Light = Color(0xFFF0EBE5);
  static const Color neutral200Light = Color(0xFFE0D8D0);
  static const Color neutral300Light = Color(0xFFC8BDB2);
  static const Color neutral400Light = Color(0xFFAA9E94);
  static const Color neutral500Light = Color(0xFF9A8E87);
  static const Color neutral600Light = Color(0xFF7A6E67);
  static const Color neutral700Light = Color(0xFF5A4E47);
  static const Color neutral800Light = Color(0xFF3E342C);
  static const Color neutral900Light = Color(0xFF1A1412);

  // ── Neutrals — warm-tinted scale (dark) ───────────────────────────────────
  static const Color neutral50Dark = Color(0xFF1A1412);
  static const Color neutral100Dark = Color(0xFF2A2220);
  static const Color neutral200Dark = Color(0xFF3A302C);
  static const Color neutral300Dark = Color(0xFF5A4E42);
  static const Color neutral400Dark = Color(0xFF7A6E62);
  static const Color neutral500Dark = Color(0xFF9A8E82);
  static const Color neutral600Dark = Color(0xFFBAB0A8);
  static const Color neutral700Dark = Color(0xFFD4CCC4);
  static const Color neutral800Dark = Color(0xFFE8E0D8);
  static const Color neutral900Dark = Color(0xFFFAF7F4);

  // ── Dot colors ────────────────────────────────────────────────────────────
  static const Color dotExhaustedLight = Color(0xFFD4C4B8);
  static const Color dotTodayLight = Color(0xFFC4654A);
  static const Color dotRemainingLight = Color(0xFF3E342C);

  static const Color dotExhaustedDark = Color(0xFF5A4E42);
  static const Color dotTodayDark = Color(0xFFE8896E);
  static const Color dotRemainingDark = Color(0xFFE8DDD4);

  // ── Belief accent colors ───────────────────────────────────────────────────
  static const Color christianLight = Color(0xFF8E7EB4);
  static const Color muslimLight = Color(0xFF5AA88E);
  static const Color astrologyLight = Color(0xFFB8864A);
  static const Color generalLight = Color(0xFF968478);

  static const Color christianDark = Color(0xFFA898CE);
  static const Color muslimDark = Color(0xFF7EC8AE);
  static const Color astrologyDark = Color(0xFFD4A26E);
  static const Color generalDark = Color(0xFFB8A698);

  // ── Warm shadow ───────────────────────────────────────────────────────────
  static const Color shadowWarm = Color(0x1A5A3C28); // rgba(90,60,40,0.1)
}
