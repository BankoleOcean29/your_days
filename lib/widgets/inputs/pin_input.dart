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

/// 3×4 numeric keypad — spec: 64×64dp buttons, radius.full (circles), 28dp SemiBold.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(context, ['1', '2', '3']),
        _row(context, ['4', '5', '6']),
        _row(context, ['7', '8', '9']),
        _row(context, ['', '0', '⌫']),
      ],
    );
  }

  Widget _row(BuildContext context, List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys
            .map((k) => _PinKey(
                  label: k,
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
  final VoidCallback? onTap;

  const _PinKey({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // Pressed/resting background — neutral.100 per spec
    final keyBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral200Dark;
    final textColor =
        isLight ? ColorTokens.neutral800Light : ColorTokens.neutral800Dark;
    final disabledColor =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;

    if (label.isEmpty) {
      // Empty placeholder cell — matches the 64dp width + 12dp margin each side
      return const SizedBox(width: 64, height: 64);
    }

    final isIcon = label == '⌫';
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 64,
        height: 64,
        // 12dp margin each side = 24dp total gap between keys
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isEnabled ? keyBg : Colors.transparent,
          // radius.full on a square = perfect circle
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isIcon
            ? Icon(
                Icons.backspace_outlined,
                size: 24,
                color: isEnabled ? textColor : disabledColor,
              )
            : Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? textColor : disabledColor,
                ),
              ),
      ),
    );
  }
}
