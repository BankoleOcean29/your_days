import 'package:flutter/material.dart';
import 'package:your_days/theme/color_tokens.dart';

@immutable
class BeliefTheme extends ThemeExtension<BeliefTheme> {
  final Color christian;
  final Color muslim;
  final Color astrology;
  final Color general;

  const BeliefTheme({
    required this.christian,
    required this.muslim,
    required this.astrology,
    required this.general,
  });

  static const light = BeliefTheme(
    christian: ColorTokens.christianLight,
    muslim: ColorTokens.muslimLight,
    astrology: ColorTokens.astrologyLight,
    general: ColorTokens.generalLight,
  );

  static const dark = BeliefTheme(
    christian: ColorTokens.christianDark,
    muslim: ColorTokens.muslimDark,
    astrology: ColorTokens.astrologyDark,
    general: ColorTokens.generalDark,
  );

  /// Returns the accent color for a given [track] string.
  Color forTrack(String track) {
    switch (track) {
      case 'christian':
        return christian;
      case 'muslim':
        return muslim;
      case 'astrology':
        return astrology;
      default:
        return general;
    }
  }

  @override
  BeliefTheme copyWith({
    Color? christian,
    Color? muslim,
    Color? astrology,
    Color? general,
  }) {
    return BeliefTheme(
      christian: christian ?? this.christian,
      muslim: muslim ?? this.muslim,
      astrology: astrology ?? this.astrology,
      general: general ?? this.general,
    );
  }

  @override
  BeliefTheme lerp(BeliefTheme? other, double t) {
    if (other is! BeliefTheme) return this;
    return BeliefTheme(
      christian: Color.lerp(christian, other.christian, t)!,
      muslim: Color.lerp(muslim, other.muslim, t)!,
      astrology: Color.lerp(astrology, other.astrology, t)!,
      general: Color.lerp(general, other.general, t)!,
    );
  }
}
