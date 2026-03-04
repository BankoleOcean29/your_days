import 'package:flutter/material.dart';
import 'package:your_days/theme/color_tokens.dart';

@immutable
class DotTheme extends ThemeExtension<DotTheme> {
  final Color exhausted;
  final Color today;
  final Color remaining;

  const DotTheme({
    required this.exhausted,
    required this.today,
    required this.remaining,
  });

  static const light = DotTheme(
    exhausted: ColorTokens.dotExhaustedLight,
    today: ColorTokens.dotTodayLight,
    remaining: ColorTokens.dotRemainingLight,
  );

  static const dark = DotTheme(
    exhausted: ColorTokens.dotExhaustedDark,
    today: ColorTokens.dotTodayDark,
    remaining: ColorTokens.dotRemainingDark,
  );

  @override
  DotTheme copyWith({Color? exhausted, Color? today, Color? remaining}) {
    return DotTheme(
      exhausted: exhausted ?? this.exhausted,
      today: today ?? this.today,
      remaining: remaining ?? this.remaining,
    );
  }

  @override
  DotTheme lerp(DotTheme? other, double t) {
    if (other is! DotTheme) return this;
    return DotTheme(
      exhausted: Color.lerp(exhausted, other.exhausted, t)!,
      today: Color.lerp(today, other.today, t)!,
      remaining: Color.lerp(remaining, other.remaining, t)!,
    );
  }
}
