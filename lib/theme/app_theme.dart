import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/theme/belief_theme.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/theme/dot_theme.dart';

abstract class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final primary = isLight ? ColorTokens.primaryLight : ColorTokens.primaryDark;
    final surface = isLight ? ColorTokens.neutral50Light : ColorTokens.neutral50Dark;
    final cardBg = isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;
    final neutral400 = isLight ? ColorTokens.neutral400Light : ColorTokens.neutral400Dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      primary: primary,
      secondary: isLight ? ColorTokens.secondaryLight : ColorTokens.secondaryDark,
      tertiary: isLight ? ColorTokens.tertiaryLight : ColorTokens.tertiaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: _textTheme(isLight),
      extensions: isLight
          ? const [DotTheme.light, BeliefTheme.light]
          : const [DotTheme.dark, BeliefTheme.dark],
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primary.withAlpha(38), // ~15% opacity
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : neutral400,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.nunito(fontSize: 12);
          return states.contains(WidgetState.selected)
              ? base.copyWith(color: primary, fontWeight: FontWeight.w600)
              : base.copyWith(color: neutral400);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? ColorTokens.neutral200Light : ColorTokens.neutral200Dark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  static TextTheme _textTheme(bool isLight) {
    final textColor =
        isLight ? ColorTokens.neutral900Light : ColorTokens.neutral900Dark;

    return TextTheme(
      // Display — Lora
      displayLarge: GoogleFonts.lora(
          fontSize: 57, fontWeight: FontWeight.bold, color: textColor),
      displayMedium: GoogleFonts.lora(
          fontSize: 45, fontWeight: FontWeight.bold, color: textColor),
      displaySmall: GoogleFonts.lora(
          fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
      // Headline — Lora
      headlineLarge: GoogleFonts.lora(
          fontSize: 32, fontWeight: FontWeight.w600, color: textColor),
      headlineMedium: GoogleFonts.lora(
          fontSize: 28, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: GoogleFonts.lora(
          fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      // Title — Lora
      titleLarge: GoogleFonts.lora(
          fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: GoogleFonts.lora(
          fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: GoogleFonts.lora(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      // Body — Nunito
      bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      // Label — Nunito
      labelLarge: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      labelSmall: GoogleFonts.nunito(
          fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
    );
  }
}
