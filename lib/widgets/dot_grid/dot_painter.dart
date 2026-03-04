import 'package:flutter/material.dart';

/// Renders the 365/366-dot year grid using a single canvas pass.
///
/// Colors are passed in from the parent so this painter has no theme
/// dependency — the caller reads [DotTheme] from context and passes colors.
class DotPainter extends CustomPainter {
  final int currentDayOfYear;
  final int totalDays;
  final double todayScale; // drives the pulse animation on today's dot
  final Color exhaustedColor;
  final Color todayColor;
  final Color remainingColor;

  static const int _columns = 20;
  static const int _rows = 19;

  const DotPainter({
    required this.currentDayOfYear,
    required this.totalDays,
    required this.todayScale,
    required this.exhaustedColor,
    required this.todayColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Square spacing: Y pitch matches X pitch for a uniform feel.
    final double spacingX = size.width / (_columns + 1);
    final double spacingY = size.height / (_rows + 1);
    final double baseRadius = spacingX * 0.35;

    final paint = Paint()..style = PaintingStyle.fill;

    int dayNumber = 0;

    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _columns; col++) {
        dayNumber++;
        if (dayNumber > totalDays) return;

        final double xPos = spacingX * (col + 1);
        final double yPos = spacingY * (row + 1);
        final bool isToday = dayNumber == currentDayOfYear;
        final double radius = isToday ? baseRadius * todayScale : baseRadius;

        paint.color = dayNumber < currentDayOfYear
            ? exhaustedColor
            : isToday
                ? todayColor
                : remainingColor;

        canvas.drawCircle(Offset(xPos, yPos), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPainter old) {
    return old.currentDayOfYear != currentDayOfYear ||
        old.totalDays != totalDays ||
        old.todayScale != todayScale ||
        old.exhaustedColor != exhaustedColor ||
        old.todayColor != todayColor ||
        old.remainingColor != remainingColor;
  }
}
