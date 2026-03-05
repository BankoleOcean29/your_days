import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/constants.dart';

/// Four-dot PIN indicator — spec: 12dp dots, 16dp gap.
class PinDots extends StatelessWidget {
  final int filled;
  final bool hasError;
  final Animation<double>? shakeAnimation;

  const PinDots({
    super.key,
    required this.filled,
    this.hasError = false,
    this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final emptyBorder =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;
    final dotColor = hasError ? Theme.of(context).colorScheme.error : primary;

    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.kPinLength, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          // 8dp margin each side = 16dp gap between dots (spec)
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? dotColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? dotColor : emptyBorder,
              width: 2,
            ),
          ),
        );
      }),
    );

    if (shakeAnimation == null) return dots;

    return AnimatedBuilder(
      animation: shakeAnimation!,
      builder: (_, child) => Transform.translate(
        offset: Offset(shakeAnimation!.value, 0),
        child: child,
      ),
      child: dots,
    );
  }
}

/// 3×4 numeric keypad — keys scale to fit any screen width.
/// Each key is a circle; the diameter is computed from available width so the
/// three-column layout always fits without overflow, capped at 76 dp so the
/// keypad never grows taller than necessary on large screens.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final bool enabled;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.enabled = true,
  });

  // Fixed horizontal margin on each side of every key (matches original spec).
  static const double _keyMargin = 14.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each column = availableWidth / 3.
        // Key diameter = column width minus the two margins; clamped so it
        // never exceeds the original 76 dp (prevents height growth on wide
        // screens) and never goes below 48 dp (keeps it usable on tiny ones).
        final keySize =
            (constraints.maxWidth / 3 - _keyMargin * 2).clamp(48.0, 76.0);
        final fontSize = (keySize * 0.4).clamp(20.0, 30.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(context, ['1', '2', '3'], keySize, fontSize),
            _row(context, ['4', '5', '6'], keySize, fontSize),
            _row(context, ['7', '8', '9'], keySize, fontSize),
            _row(context, ['', '0', '⌫'], keySize, fontSize),
          ],
        );
      },
    );
  }

  Widget _row(
      BuildContext context, List<String> keys, double keySize, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys
            .map((k) => _PinKey(
                  label: k,
                  keySize: keySize,
                  fontSize: fontSize,
                  onTap: k.isEmpty
                      ? null
                      : k == '⌫'
                          ? (enabled ? onDelete : null)
                          : (enabled ? () => onDigit(k) : null),
                ))
            .toList(),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final double keySize;
  final double fontSize;
  final VoidCallback? onTap;

  const _PinKey({
    required this.label,
    required this.keySize,
    required this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final keyBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral200Dark;
    final textColor =
        isLight ? ColorTokens.neutral800Light : ColorTokens.neutral800Dark;
    final disabledColor =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;

    if (label.isEmpty) {
      // Invisible placeholder — same footprint as a real key.
      return SizedBox(width: keySize + PinKeypad._keyMargin * 2, height: keySize);
    }

    final isIcon = label == '⌫';
    final isEnabled = onTap != null;

    return MouseRegion(
      cursor: isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          if (isEnabled) {
            HapticFeedback.lightImpact();
            onTap!();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: keySize,
          height: keySize,
          margin: const EdgeInsets.symmetric(horizontal: PinKeypad._keyMargin),
          decoration: BoxDecoration(
            color: isEnabled ? keyBg : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isIcon
              ? Icon(
                  Icons.backspace_outlined,
                  size: fontSize,
                  color: isEnabled ? textColor : disabledColor,
                )
              : Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? textColor : disabledColor,
                  ),
                ),
        ),
      ),
    );
  }
}
