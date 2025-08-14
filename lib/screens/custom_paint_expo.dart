import 'package:flutter/material.dart';
import 'dart:math' as math;

class DotPainter extends CustomPainter {

  final int columns = 20;
  final int rows = 19;
  final int currentDayOfYear;

  DotPainter({required this.currentDayOfYear});


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Color(0xff9FA8DA);
    paint.style = PaintingStyle.fill;

    final double dotRadius = 5.0;
    final double spacingX = size.width / (columns + 1);
    final double spacingY = size.height / (rows + 1);
    int dayNumber = 0;

    for (int y = 0; y < rows; y++) {
      // Inner loop for the columns (X-axis)
      for (int x = 0; x < columns; x++) {
        dayNumber++;
        if (dayNumber > 365) {
          return;
        } // Stop drawing after 365 dots

        // Color the dot based on its sequential number
        if (dayNumber < currentDayOfYear) {
          paint.color = Colors.grey;
        } else if (dayNumber == currentDayOfYear) {
          paint.color = Colors.red; // Use red for the current day
        } else {
          paint.color = Colors.black;
        }

        // Calculate position for the current dot
          final double xPosition = spacingX * (x + 1);
          final double yPosition = spacingY * (y + 1);

          final offset = Offset(xPosition, yPosition);
          canvas.drawCircle(offset, dotRadius, paint);

      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPainter oldDelegate) {
    return oldDelegate.currentDayOfYear != currentDayOfYear ||
        oldDelegate.isLeapYear != isLeapYear;
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  
}